local M = {}

local default_config = {
  terminal = {
    name = "cursor-agent",
    start_command = "cursor-agent",
    open_cmd = "botright vsplit",
    height = 12,
    width = 80,
    focus = true,
    send_delay_ms = 400,
  },
  path = {
    root_strategy = "git", -- "git" | "cwd" | "none"
  },
  clipboard = {
    use_system = true,
  },
  keymaps = {
    enabled = true,
    prefix = "<leader>ca",
    copy_path_with_lines = "<leader>cap",
    send_path_with_lines = "<leader>cas",
    copy_file_path = "<leader>caP",
    send_file_path = "<leader>caS",
    focus_terminal = "<leader>cat",
  },
}

local config = vim.deepcopy(default_config)
local commands_created = false
local version = require("ai_cli_helper.version").version

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "AI CLI Helper" })
end

local function apply_keymaps()
  if not config.keymaps.enabled then
    return
  end

  local opts = { noremap = true, silent = true }

  local prefix = config.keymaps.prefix
  if prefix and prefix ~= "" then
    vim.keymap.set("n", prefix, function() end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: prefix" }))
  end

  vim.keymap.set("n", config.keymaps.copy_path_with_lines, function()
    M.copy_path_with_lines(false)
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Copy path with lines" }))

  vim.keymap.set("v", config.keymaps.copy_path_with_lines, function()
    M.copy_path_with_lines(true)
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Copy path with lines (visual)" }))

  vim.keymap.set("n", config.keymaps.send_path_with_lines, function()
    M.send_path_with_lines(false)
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Send path with lines" }))

  vim.keymap.set("v", config.keymaps.send_path_with_lines, function()
    M.send_path_with_lines(true)
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Send path with lines (visual)" }))

  vim.keymap.set("n", config.keymaps.copy_file_path, function()
    M.copy_file_path()
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Copy file path" }))

  vim.keymap.set("n", config.keymaps.send_file_path, function()
    M.send_file_path()
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Send file path" }))

  vim.keymap.set("n", config.keymaps.focus_terminal, function()
    M.focus_terminal()
  end, vim.tbl_extend("force", opts, { desc = "AI CLI Helper: Focus terminal" }))
end

local function create_commands()
  if commands_created then
    return
  end
  vim.api.nvim_create_user_command("AiCliHelperCopyPathWithLines", function()
    M.copy_path_with_lines(false)
  end, {})

  vim.api.nvim_create_user_command("AiCliHelperSendPathWithLines", function()
    M.send_path_with_lines(false)
  end, {})

  vim.api.nvim_create_user_command("AiCliHelperCopyFilePath", function()
    M.copy_file_path()
  end, {})

  vim.api.nvim_create_user_command("AiCliHelperSendFilePath", function()
    M.send_file_path()
  end, {})

  vim.api.nvim_create_user_command("AiCliHelperFocusTerminal", function()
    M.focus_terminal()
  end, {})
  commands_created = true
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  apply_keymaps()
  create_commands()
end

function M.copy_path_with_lines(use_visual)
  local path = require("ai_cli_helper.path").get_path_with_lines(config, use_visual)
  if not path then
    notify("无法获取文件路径。", vim.log.levels.WARN)
    return
  end
  require("ai_cli_helper.path").copy_to_clipboard(path, config)
  notify("已复制： " .. path)
end

function M.send_path_with_lines(use_visual)
  local path = require("ai_cli_helper.path").get_path_with_lines(config, use_visual)
  if not path then
    notify("无法获取文件路径。", vim.log.levels.WARN)
    return
  end
  require("ai_cli_helper.terminal").send(path, config)
end

function M.copy_file_path()
  local path = require("ai_cli_helper.path").get_file_path(config)
  if not path then
    notify("无法获取文件路径。", vim.log.levels.WARN)
    return
  end
  require("ai_cli_helper.path").copy_to_clipboard(path, config)
  notify("已复制： " .. path)
end

function M.send_file_path()
  local path = require("ai_cli_helper.path").get_file_path(config)
  if not path then
    notify("无法获取文件路径。", vim.log.levels.WARN)
    return
  end
  require("ai_cli_helper.terminal").send(path, config)
end

function M.focus_terminal()
  require("ai_cli_helper.terminal").focus(config)
end

function M.get_config()
  return config
end

function M.get_version()
  return version
end

M.version = version

return M
