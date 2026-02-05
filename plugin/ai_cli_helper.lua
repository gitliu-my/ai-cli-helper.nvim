if vim.g.ai_cli_helper_loaded == 1 then
  return
end
vim.g.ai_cli_helper_loaded = 1

require("ai_cli_helper").setup()
