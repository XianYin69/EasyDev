@echo off
setlocal
:: 设置标题
title SuperSpace 打包工具启动器

:: 检查当前目录下是否存在脚本
if not exist "%~dp0pack-tool.ps1" (
    echo [错误] 找不到 pack-tool.ps1 文件！
    echo 请确保批处理和脚本放在同一个文件夹。
    pause
    exit /b
)

echo ----------------------------------------------------
echo   启动中...
echo ----------------------------------------------------
echo.

:: 使用 PowerShell 运行脚本
:: -ExecutionPolicy Bypass: 绕过系统脚本禁用策略
:: -WindowStyle Normal: 确保能看到控制台输出（方便调试）
powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0pack-tool.ps1""' -Verb RunAs}"

if %errorlevel% neq 0 (
    echo [提示] 如果弹出 UWP 确认框，请选择“是”以管理员权限运行。
)

echo 启动指令已发送。
timeout /t 3