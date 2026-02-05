# AI CLI Helper (Neovim)

在 Neovim 中快速获取文件路径（可含行号），并将内容发送到终端输入框，方便配合 AI CLI 工具使用。

版本：`0.1.3`（见 `CHANGELOG.md`）

## 功能
- 复制当前文件路径（可含行号，支持选区）
- 从项目视图复制文件路径（不含行号，适用于 netrw/文件树光标所在文件）
- 发送路径到 `cursor-agent` 终端输入框（不自动执行）
- 聚焦到 `cursor-agent` 终端
- 终端内支持 `Ctrl+h/j/k/l` 切换窗口
- 终端内支持 `Esc Esc` 退出终端模式
- 若终端不存在，会自动创建并启动 `cursor-agent`

## 安装
### lazy.nvim
```lua
{
  "gitliu-my/ai-cli-helper.nvim",
  config = function()
    require("ai_cli_helper").setup({})
  end,
}
```

### LazyVim 快速配置
在 `~/.config/nvim/lua/plugins/ai-cli-helper.lua` 新建配置：
```lua
return {
  {
    "gitliu-my/ai-cli-helper.nvim",
    config = function()
      require("ai_cli_helper").setup({
        terminal = {
          name = "cursor-agent",
          start_command = "cursor-agent",
        },
      })
    end,
  },
}
```

### packer.nvim
```lua
use({
  "gitliu-my/ai-cli-helper.nvim",
})
```

## 默认快捷键
- 前缀：`<leader>ca`
- Send Path With Lines：`<leader>cas`
- Send File Path：`<leader>caS`
- Copy Path With Lines：`<leader>cac`
- Copy File Path：`<leader>caC`
- Focus Terminal：`<leader>cat`

## 命令
- `:AiCliHelperCopyPathWithLines`
- `:AiCliHelperSendPathWithLines`
- `:AiCliHelperCopyFilePath`
- `:AiCliHelperSendFilePath`
- `:AiCliHelperFocusTerminal`

## 配置
```lua
require("ai_cli_helper").setup({
  terminal = {
    name = "cursor-agent",
    start_command = "cursor-agent",
    open_cmd = "botright vsplit",
    width = 80,
    focus = true,
    send_delay_ms = 400,
    window_nav = true,
    escape_exit = true,
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
    copy_path_with_lines = "<leader>cac",
    send_path_with_lines = "<leader>cas",
    copy_file_path = "<leader>caC",
    send_file_path = "<leader>caS",
    focus_terminal = "<leader>cat",
  },
})
```

## 输出示例
- `src/main/.../file.yaml#L9`
- `src/main/.../file.yaml#L9-L12`

## 版本与更新日志
- 版本号位于 `lua/ai_cli_helper/version.lua`
- 更新功能后请同步修改 `CHANGELOG.md`
