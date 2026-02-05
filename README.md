# AI CLI Helper (Neovim)

在 Neovim 中快速获取文件路径（可含行号），并将内容发送到终端输入框，方便配合 AI CLI 工具使用。

版本：`0.1.0`（见 `CHANGELOG.md`）

## 功能
- 复制当前文件路径（可含行号，支持选区）
- 从项目视图复制文件路径（不含行号，适用于 netrw/文件树光标所在文件）
- 发送路径到 `cursor-agent` 终端输入框（不自动执行）
- 聚焦到 `cursor-agent` 终端
- 若终端不存在，会自动创建并启动 `cursor-agent`

## 安装
### lazy.nvim
```lua
{
  "gitliu-my/plugins_dev",
  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. "/nvim/ai-cli-helper.nvim")
    require("ai_cli_helper").setup({})
  end,
}
```

### LazyVim 快速配置
在 `~/.config/nvim/lua/plugins/ai-cli-helper.lua` 新建配置：
```lua
return {
  {
    "gitliu-my/plugins_dev",
    lazy = false,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. "/nvim/ai-cli-helper.nvim")
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
  "gitliu-my/plugins_dev",
  rtp = "nvim/ai-cli-helper.nvim",
})
```

## 默认快捷键
- Send Path With Lines：`<leader>as`
- Copy Path With Lines：`<leader>ap`
- Copy File Path：`<leader>aP`
- Send File Path：`<leader>aS`
- Focus Terminal：`<leader>at`

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
    open_cmd = "botright split",
    height = 12,
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
    copy_path_with_lines = "<leader>ap",
    send_path_with_lines = "<leader>as",
    copy_file_path = "<leader>aP",
    send_file_path = "<leader>aS",
    focus_terminal = "<leader>at",
  },
})
```

## 输出示例
- `src/main/.../file.yaml#L9`
- `src/main/.../file.yaml#L9-L12`

## 版本与更新日志
- 版本号位于 `lua/ai_cli_helper/version.lua`
- 更新功能后请同步修改 `CHANGELOG.md`
