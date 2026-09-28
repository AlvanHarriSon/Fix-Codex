# Fix-Codex

Codex Desktop 卡在转圈界面时的 Windows 自动恢复脚本。

面向“后台仍在运行，但桌面前端一直转圈、无响应或不更新”的现象，提供一次重启进程的恢复尝试。本仓库保留用户提供的 `Fix-Codex.ps1` 原始内容。

这是社区临时恢复方法，不是 OpenAI 官方补丁。后台进程存在不代表后端健康；本脚本也不能确认前端已经恢复，不能据此确定故障根因。

## 运行前

- 适用于 Windows，并依赖 Windows PowerShell、`Get-Process` 和开始菜单应用注册。
- 保存工作，确认可以中断正在进行的 Codex 任务。请从独立的 Windows PowerShell 窗口运行，避免在 Codex 内部终端执行。
- 脚本按名称强制结束所有匹配 `codex` 的进程，名称匹配不区分大小写。它没有区分桌面前端、后端和独立 CLI，也没有按用户或会话筛选；以管理员身份运行可能扩大影响范围。
- 脚本不删除聊天记录、配置或缓存，不修改注册表和持久执行策略。但强制结束进程可能丢失未保存状态。

## 使用

下载后可以把 `Fix-Codex.ps1` 放到桌面。再次卡住时，右键脚本 → **使用 PowerShell 运行**（Windows 11 可能需要先选择“显示更多选项”）。

可能看到以下输出：

```text
Fixing Codex...
Stopped stuck Codex backend.
Codex backend restarted successfully.
Return to the Codex window.
```

脚本不会删除 `.codex`、不会清空历史记录、不会 Reset 应用。它通过结束同名进程并尝试重新启动应用进行恢复。

如果执行策略阻止运行，或希望保留输出便于排查：

1. 从本仓库下载并检查 `Fix-Codex.ps1`，或通过 **Code → Download ZIP** 下载并解压。
2. 在脚本所在文件夹打开独立的 Windows PowerShell 窗口。
3. 确认可以中断相关进程后执行：

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Fix-Codex.ps1
   ```

   `Bypass` 只针对这次启动的 PowerShell 进程，不修改系统的持久执行策略；组织管理策略仍可能阻止执行。

4. 返回桌面应用，手动检查聊天能否打开、输入框能否响应以及任务输出能否继续显示。

如果脚本保存在桌面，也可以使用以下命令。通过系统获取桌面位置，兼容桌面被重定向到 OneDrive 的情况：

```powershell
$desktopPath = [Environment]::GetFolderPath('Desktop')
powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $desktopPath 'Fix-Codex.ps1')
```

## 脚本实际做了什么

1. 查找名为 `codex` 的进程，并使用 `Stop-Process -Force` 结束它们。
2. 等待 5 秒；如果再次发现同名进程，就显示 `Codex backend restarted successfully.` 并退出。
3. 如果未发现同名进程，从开始菜单中选取名称包含 `Codex` 的第一个应用，通过 `explorer.exe shell:AppsFolder\<AppID>` 请求启动。
4. 如果没有找到应用，提示手动打开。

## 如何判断结果

| 脚本显示 | 实际能说明什么 |
| --- | --- |
| `Codex backend restarted successfully.` | 检测到同名进程；不等于前端已恢复，也不能证明是重启后的新进程。 |
| `Done.` | 已走到启动分支末尾；未检查应用是否成功启动。 |
| `Could not find Codex in the Start menu.` | 自动发现失败，需要手动打开应用。 |

原脚本全局使用 `SilentlyContinue`，可能隐藏结束进程或启动应用时的错误。因此，绿色文字或退出码 0 都不能作为修复成功的判据。最终应以界面恢复交互为准。

## 已知限制

- 不能保证应用会在 5 秒内自动重新启动进程。
- 安装了多个名称包含 Codex 的应用时，可能选中错误的开始菜单项目；应用改名或未注册时也可能无法找到。
- 权限不足、网络或认证故障、前端渲染异常等问题不一定能通过重启解决。
- 本次整理仅通过 PowerShell 语法解析及原文件 SHA-256 一致性检查，没有执行脚本、复现故障或验证真实恢复效果。尚未建立已验证的应用版本列表。

## 仍然卡住时

先检查是否存在待处理的批准请求。若界面还能操作，可以尝试新聊天；持续卡住时，在可中断任务后手动退出并重新打开应用。参考 [OpenAI 官方故障排查说明](https://learn.chatgpt.com/docs/reference/troubleshooting)。

提交问题时，请使用本仓库 Issue 模板，描述应用版本、Windows 版本、复现步骤、脚本输出以及前端是否恢复。分享日志之前移除令牌、邮箱、本地个人路径和私人聊天内容。

## 材料来源

- 用户提供的 `Fix-Codex.ps1`，原样收录。
- 用户描述的症状：后端成功运行，但前端卡死。
- 用户补充的对话摘录：结束进程、等待 5 秒、必要时重新启动，以及桌面右键运行的方法。完整分享页面未能读取；本文依据所提供的摘录和脚本整理，不将示例输出视为实际修复验证。

原脚本 SHA-256：`3D6B00D02A6A2471BC75213EEFFE8CE618B8771AC05C886E781EE19890969166`。
