local M = {}

local function find_terminal_buf(name)
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.bo[bufnr].buftype == "terminal" then
      local ok, value = pcall(vim.api.nvim_buf_get_var, bufnr, "ai_cli_helper_terminal_name")
      if ok and value == name then
        return bufnr
      end
    end
  end
  return nil
end

local function find_terminal_win(bufnr)
  if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
    return nil, nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == bufnr then
      return win, vim.api.nvim_win_get_tabpage(win)
    end
  end
  return nil, nil
end

local function apply_terminal_keymaps(cfg, bufnr)
  if cfg.terminal.window_nav == false then
    return
  end
  local opts = { buffer = bufnr, noremap = true, silent = true }
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
  if cfg.terminal.escape_exit ~= false then
    vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], opts)
  end
end

local function apply_window_options(bufnr, cfg)
  local win = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_win_set_option, win, "winfixbuf", true)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    pcall(vim.api.nvim_buf_set_option, bufnr, "buflisted", false)
    pcall(vim.api.nvim_buf_set_option, bufnr, "bufhidden", "hide")
    pcall(vim.api.nvim_buf_set_name, bufnr, cfg.terminal.name)
  end
end

local function open_terminal_window(cfg, bufnr)
  local prev_win = vim.api.nvim_get_current_win()
  local existing, existing_tab = find_terminal_win(bufnr)
  if existing then
    if existing_tab then
      vim.api.nvim_set_current_tabpage(existing_tab)
    end
    vim.api.nvim_set_current_win(existing)
    if cfg.terminal.open_cmd and cfg.terminal.open_cmd:find("vsplit", 1, true) then
      if cfg.terminal.width and cfg.terminal.width > 0 then
        pcall(vim.cmd, "vertical resize " .. cfg.terminal.width)
      end
    elseif cfg.terminal.height and cfg.terminal.height > 0 then
      pcall(vim.cmd, "resize " .. cfg.terminal.height)
    end
    apply_window_options(bufnr, cfg)
    return prev_win
  end
  if cfg.terminal.open_cmd and cfg.terminal.open_cmd ~= "" then
    vim.cmd(cfg.terminal.open_cmd)
  end
  if cfg.terminal.open_cmd and cfg.terminal.open_cmd:find("vsplit", 1, true) then
    if cfg.terminal.width and cfg.terminal.width > 0 then
      pcall(vim.cmd, "vertical resize " .. cfg.terminal.width)
    end
  elseif cfg.terminal.height and cfg.terminal.height > 0 then
    pcall(vim.cmd, "resize " .. cfg.terminal.height)
  end
  if bufnr then
    vim.api.nvim_set_current_buf(bufnr)
  else
    vim.cmd("enew")
  end
  apply_window_options(bufnr, cfg)
  return prev_win
end

local function create_terminal(cfg)
  open_terminal_window(cfg, nil)
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].swapfile = false

  local command = cfg.terminal.start_command
  local job_id = vim.fn.termopen(command)

  vim.api.nvim_buf_set_var(bufnr, "ai_cli_helper_terminal_name", cfg.terminal.name)
  vim.api.nvim_buf_set_var(bufnr, "ai_cli_helper_terminal_job", job_id)
  apply_terminal_keymaps(cfg, bufnr)

  return bufnr, true
end

local function ensure_terminal(cfg)
  local bufnr = find_terminal_buf(cfg.terminal.name)
  if bufnr then
    open_terminal_window(cfg, bufnr)
    apply_terminal_keymaps(cfg, bufnr)
    return bufnr, false
  end
  return create_terminal(cfg)
end

local function get_job_id(bufnr)
  local ok, job_id = pcall(vim.api.nvim_buf_get_var, bufnr, "terminal_job_id")
  if ok and job_id then
    return job_id
  end
  local ok2, stored = pcall(vim.api.nvim_buf_get_var, bufnr, "ai_cli_helper_terminal_job")
  if ok2 and stored then
    return stored
  end
  return nil
end

local function send_to_terminal(bufnr, text)
  local job_id = get_job_id(bufnr)
  if not job_id then
    vim.notify("Terminal 通道不可用。", vim.log.levels.ERROR, { title = "AI CLI Helper" })
    return
  end
  vim.fn.chansend(job_id, text)
end

local function ensure_trailing_space(text)
  if text == "" then
    return " "
  end
  if text:sub(-1) == " " then
    return text
  end
  return text .. " "
end

local function ensure_at_prefix(text)
  if text == "" then
    return "@"
  end
  if text:sub(1, 1) == "@" then
    return text
  end
  return "@" .. text
end

function M.send(text, cfg)
  if not text or text == "" then
    return
  end

  local prev_win
  local bufnr
  local created
  prev_win = vim.api.nvim_get_current_win()
  bufnr, created = ensure_terminal(cfg)

  local payload = ensure_trailing_space(ensure_at_prefix(text))
  if created then
    vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) then
        send_to_terminal(bufnr, payload)
      end
    end, cfg.terminal.send_delay_ms or 400)
  else
    send_to_terminal(bufnr, payload)
  end

  if not cfg.terminal.focus and vim.api.nvim_win_is_valid(prev_win) then
    vim.api.nvim_set_current_win(prev_win)
  end
end

function M.focus(cfg)
  local bufnr = find_terminal_buf(cfg.terminal.name)
  if bufnr then
    open_terminal_window(cfg, bufnr)
    apply_terminal_keymaps(cfg, bufnr)
    return
  end
  create_terminal(cfg)
end

return M
