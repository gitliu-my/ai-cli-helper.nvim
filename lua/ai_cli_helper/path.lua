local M = {}

local function realpath(path)
  return vim.loop.fs_realpath(path) or path
end

local function find_git_root(path)
  local dir = vim.fn.fnamemodify(path, ":p:h")
  local git_dir = vim.fn.finddir(".git", dir .. ";")
  if git_dir == "" then
    return nil
  end
  return vim.fn.fnamemodify(git_dir, ":p:h")
end

local function resolve_root(path, config)
  local strategy = config.path.root_strategy
  if strategy == "git" then
    return find_git_root(path) or vim.fn.getcwd()
  end
  if strategy == "cwd" then
    return vim.fn.getcwd()
  end
  return nil
end

local function relativize(path, root)
  if not root or root == "" then
    return path
  end
  local abs_path = realpath(path)
  local abs_root = realpath(root)
  if abs_path:sub(1, #abs_root + 1) == abs_root .. "/" then
    return abs_path:sub(#abs_root + 2)
  end
  return path
end

local function normalize_range(start_line, end_line)
  if not start_line or not end_line or start_line == 0 or end_line == 0 then
    return nil
  end
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  return start_line, end_line
end

local function get_visual_range_marks()
  local start = vim.fn.getpos("'<")
  local finish = vim.fn.getpos("'>")
  return normalize_range(start[2], finish[2])
end

function M.get_visual_range_live()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local s, e = normalize_range(start_line, end_line)
  return { s, e }
end

local function get_buffer_path()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == nil or bufname == "" then
    return nil
  end
  return realpath(bufname)
end

local function resolve_cfile()
  local cfile = vim.fn.expand("<cfile>")
  if cfile == nil or cfile == "" then
    return nil
  end
  if vim.fn.filereadable(cfile) == 1 or vim.fn.isdirectory(cfile) == 1 then
    return realpath(cfile)
  end

  local bufname = vim.api.nvim_buf_get_name(0)
  local base = bufname ~= "" and vim.fn.fnamemodify(bufname, ":p:h") or vim.fn.getcwd()
  local candidate = vim.fn.fnamemodify(base .. "/" .. cfile, ":p")
  if vim.fn.filereadable(candidate) == 1 or vim.fn.isdirectory(candidate) == 1 then
    return realpath(candidate)
  end

  return nil
end

function M.get_path_with_lines(config, use_visual, range)
  local path = get_buffer_path()
  if not path then
    return nil
  end

  local start_line
  local end_line
  if range and range[1] and range[2] then
    start_line, end_line = range[1], range[2]
  elseif use_visual then
    start_line, end_line = get_visual_range_marks()
  end
  if not start_line then
    start_line = vim.api.nvim_win_get_cursor(0)[1]
    end_line = start_line
  end

  local root = resolve_root(path, config)
  local relative = relativize(path, root)
  if start_line == end_line then
    return string.format("%s#L%d", relative, start_line)
  end
  return string.format("%s#L%d-L%d", relative, start_line, end_line)
end

function M.get_file_path(config)
  local path = get_buffer_path() or resolve_cfile()
  if not path then
    return nil
  end
  local root = resolve_root(path, config)
  return relativize(path, root)
end

function M.copy_to_clipboard(text, config)
  if config.clipboard.use_system then
    pcall(vim.fn.setreg, "+", text)
  end
  vim.fn.setreg('"', text)
end

return M
