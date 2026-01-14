# 1. 初始化 (加载所有必要库)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = "SilentlyContinue"

# 2. 界面定义 (手动补全所有缺失的标题 Label)
$f = New-Object System.Windows.Forms.Form
$f.Text = "EazyDev-cs多架构多功能打包工具"; $f.Size = "820,950"; $f.StartPosition = "CenterScreen"; $f.BackColor = "White"
$uiFont = New-Object System.Drawing.Font("Segoe UI", 9)
$f.Font = $uiFont

# --- 路径选择区 ---
$l1 = New-Object System.Windows.Forms.Label; $l1.Text = "项目根目录:"; $l1.Location = "30,30"; $l1.AutoSize = $true; $f.Controls.Add($l1)
$tSrc = New-Object System.Windows.Forms.TextBox; $tSrc.Location = "130,27"; $tSrc.Width = 550; $f.Controls.Add($tSrc)
$bSrc = New-Object System.Windows.Forms.Button; $bSrc.Text = "..."; $bSrc.Location = "700,25"; $bSrc.Size = "50,25"; $f.Controls.Add($bSrc)

$l2 = New-Object System.Windows.Forms.Label; $l2.Text = "输出目录:"; $l2.Location = "30,65"; $l2.AutoSize = $true; $f.Controls.Add($l2)
$tOut = New-Object System.Windows.Forms.TextBox; $tOut.Location = "130,62"; $tOut.Width = 550; $f.Controls.Add($tOut)
$bOut = New-Object System.Windows.Forms.Button; $bOut.Text = "..."; $bOut.Location = "700,60"; $bOut.Size = "50,25"; $f.Controls.Add($bOut)

# --- 元数据详情区 (补全标签) ---
$grp = New-Object System.Windows.Forms.GroupBox; $grp.Text = "AppxManifest 应用元数据"; $grp.Location = "30,105"; $grp.Size = "740,100"; $f.Controls.Add($grp)

$l3 = New-Object System.Windows.Forms.Label; $l3.Text = "包名:"; $l3.Location = "15,35"; $l3.AutoSize = $true; $grp.Controls.Add($l3)
$tN = New-Object System.Windows.Forms.TextBox; $tN.Location = "60,32"; $tN.Width = 200; $grp.Controls.Add($tN)

$l4 = New-Object System.Windows.Forms.Label; $l4.Text = "版本:"; $l4.Location = "280,35"; $l4.AutoSize = $true; $grp.Controls.Add($l4)
$tV = New-Object System.Windows.Forms.TextBox; $tV.Location = "320,32"; $tV.Width = 120; $grp.Controls.Add($tV)

$l5 = New-Object System.Windows.Forms.Label; $l5.Text = "家族名:"; $l5.Location = "15,68"; $l5.AutoSize = $true; $grp.Controls.Add($l5)
$tF = New-Object System.Windows.Forms.TextBox; $tF.Location = "60,65"; $tF.Width = 650; $tF.ReadOnly = $true; $grp.Controls.Add($tF)

# --- 架构选择 ---
$gA = New-Object System.Windows.Forms.GroupBox; $gA.Text = "构建设置"; $gA.Location = "30,215"; $gA.Size = "740,70"; $f.Controls.Add($gA)
$cX64 = New-Object System.Windows.Forms.CheckBox; $cX64.Text = "x64"; $cX64.Location = "20,30"; $cX64.Checked = $true; $gA.Controls.Add($cX64)
$cArm = New-Object System.Windows.Forms.CheckBox; $cArm.Text = "ARM64"; $cArm.Location = "120,30"; $cArm.Checked = $true; $gA.Controls.Add($cArm)
$cX86 = New-Object System.Windows.Forms.CheckBox; $cX86.Text = "x86"; $cX86.Location = "220,30"; $gA.Controls.Add($cX86)
$cB = New-Object System.Windows.Forms.CheckBox; $cB.Text = "Mapping 合成 Bundle"; $cB.Location = "350,30"; $cB.Checked = $true; $gA.Controls.Add($cB)

# --- 日志 ---
$log = New-Object System.Windows.Forms.TextBox; $log.Multiline = $true; $log.Location = "30,300"; $log.Size = "740,480"; $log.BackColor = "Black"; $log.ForeColor = "Lime"; $log.Font = New-Object System.Drawing.Font("Consolas", 9); $log.ScrollBars = "Vertical"; $log.ReadOnly = $true; $f.Controls.Add($log)

$btnGo = New-Object System.Windows.Forms.Button; $btnGo.Text = "确认并开始任务"; $btnGo.Location = "30,800"; $btnGo.Size = "740,80"; $btnGo.BackColor = "LightBlue"; $f.Controls.Add($btnGo)

# 3. 逻辑绑定 (交互逻辑)
$bSrc.Add_Click({ $d = New-Object System.Windows.Forms.FolderBrowserDialog; if($d.ShowDialog() -eq "OK"){ 
    $tSrc.Text = $d.SelectedPath; $xmlP = Join-Path $d.SelectedPath "Package.appxmanifest"
    if(Test-Path $xmlP){ [xml]$x = Get-Content $xmlP; $tN.Text = $x.Package.Identity.Name; $tV.Text = $x.Package.Identity.Version; $tF.Text = "$($tN.Text)_Family" }
} })
$bOut.Add_Click({ $d = New-Object System.Windows.Forms.FolderBrowserDialog; if($d.ShowDialog() -eq "OK"){ $tOut.Text = $d.SelectedPath } })

$btnGo.Add_Click({
    $log.Clear(); $log.AppendText("开始任务...`r`n")
    $msixs = @(); $archs = @()
    if($cX64.Checked){$archs+="x64"} if($cArm.Checked){$archs+="arm64"} if($cX86.Checked){$archs+="x86"}
    
    foreach($a in $archs){
        $log.AppendText("编译 $a...`r`n"); [System.Windows.Forms.Application]::DoEvents()
        $p = Join-Path $tOut.Text "Pub_$a"
        $csp = Get-ChildItem $tSrc.Text -Filter "*.csproj" | Select-Object -First 1
        Start-Process dotnet -ArgumentList "publish `"$($csp.FullName)`" -c Release -r win-$a --self-contained true -o `"$p`" /p:GenerateAppxPackageOnBuild=true /p:AppxPackageSigningEnabled=false" -Wait -NoNewWindow
        
        $m = Get-ChildItem (Join-Path $tSrc.Text "bin") -Filter "*.msix" -Recurse | Where-Object {$_.FullName -match $a} | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if($m){ $dst = Join-Path $tOut.Text "$($tN.Text)_$($tV.Text)_$a.msix"; Copy-Item $m.FullName -Destination $dst -Force; $msixs += $dst; $log.AppendText("$a MSIX 完成`r`n") }
    }

    if($cB.Checked -and $msixs.Count -gt 1){
        $log.AppendText("合成 Bundle...`r`n")
        $map = Join-Path $tOut.Text "bundle_mapping.txt"; "[Files]" | Out-File $map -Encoding utf8
        foreach($m in $msixs){ "`"$m`" `"$(Split-Path $m -Leaf)`"" | Out-File $map -Append -Encoding utf8 }
        
        $sk = switch ($env:PROCESSOR_ARCHITECTURE) { "AMD64" {"x64"} "ARM64" {"arm64"} default {"x64"} }
        $exe = Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\bin\*\$sk\makeappx.exe" | Sort-Object FullName -Descending | Select-Object -First 1
        if($exe){ 
            $bp = Join-Path $tOut.Text "$($tN.Text)_$($tV.Text)_Bundle.msixbundle"
            & $exe.FullName bundle /f $map /p $bp /o | Out-Null
            $log.AppendText("Bundle 成功: $bp`r`n") 
        }
    }
    [System.Windows.Forms.MessageBox]::Show("完成！")
})

$f.ShowDialog()