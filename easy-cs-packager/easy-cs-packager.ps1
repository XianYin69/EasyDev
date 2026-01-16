# 1. 初始化
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
$ErrorActionPreference = "Stop" 

try {
    # 2. 界面布局
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "EazyDev-cs 打包工具"; $f.Size = "820,1050"; $f.StartPosition = "CenterScreen"; $f.BackColor = "White"

    # --- 路径选择区 ---
    $l1 = New-Object System.Windows.Forms.Label; $l1.Text = "项目根目录:"; $l1.Location = "30,20"; $l1.AutoSize = $true; $f.Controls.Add($l1)
    $tSrc = New-Object System.Windows.Forms.TextBox; $tSrc.Location = "130,17"; $tSrc.Width = 550; $f.Controls.Add($tSrc)
    $bSrc = New-Object System.Windows.Forms.Button; $bSrc.Text = "..."; $bSrc.Location = "700,15"; $bSrc.Size = "50,25"; $f.Controls.Add($bSrc)

    $l2 = New-Object System.Windows.Forms.Label; $l2.Text = "输出目录:"; $l2.Location = "30,50"; $l2.AutoSize = $true; $f.Controls.Add($l2)
    $tOut = New-Object System.Windows.Forms.TextBox; $tOut.Location = "130,47"; $tOut.Width = 550; $f.Controls.Add($tOut)
    $bOut = New-Object System.Windows.Forms.Button; $bOut.Text = "..."; $bOut.Location = "700,45"; $bOut.Size = "50,25"; $f.Controls.Add($bOut)

    # --- 元数据展示区 ---
    $grpMd = New-Object System.Windows.Forms.GroupBox; $grpMd.Text = ".AppxManifest 项目元数据"; $grpMd.Location = "30,85"; $grpMd.Size = "740,140"; $f.Controls.Add($grpMd)
    $lm1 = New-Object System.Windows.Forms.Label; $lm1.Text = "包名:"; $lm1.Location = "15,35"; $lm1.AutoSize = $true; $grpMd.Controls.Add($lm1)
    $tN = New-Object System.Windows.Forms.TextBox; $tN.Location = "60,32"; $tN.Width = 200; $grpMd.Controls.Add($tN)
    $lm2 = New-Object System.Windows.Forms.Label; $lm2.Text = "版本:"; $lm2.Location = "280,35"; $lm2.AutoSize = $true; $grpMd.Controls.Add($lm2)
    $tV = New-Object System.Windows.Forms.TextBox; $tV.Location = "320,32"; $tV.Width = 120; $grpMd.Controls.Add($tV)
    $lm3 = New-Object System.Windows.Forms.Label; $lm3.Text = "发布者:"; $lm3.Location = "15,68"; $lm3.AutoSize = $true; $grpMd.Controls.Add($lm3)
    $tP = New-Object System.Windows.Forms.TextBox; $tP.Location = "80,65"; $tP.Width = 630; $grpMd.Controls.Add($tP)

    $lm4 = New-Object System.Windows.Forms.Label; $lm4.Text = "证书密码:"; $lm4.Location = "15,103"; $lm4.AutoSize = $true; $grpMd.Controls.Add($lm4)
    $tPass = New-Object System.Windows.Forms.TextBox; $tPass.Location = "80,100"; $tPass.Width = 200; $tPass.Text = "1234"; $tPass.PasswordChar = "*"; $grpMd.Controls.Add($tPass)

    # --- 策略区 ---
    $grpOp = New-Object System.Windows.Forms.GroupBox; $grpOp.Text = "架构选择与策略"; $grpOp.Location = "30,235"; $grpOp.Size = "740,100"; $f.Controls.Add($grpOp)
    $cX64 = New-Object System.Windows.Forms.CheckBox; $cX64.Text = "x64"; $cX64.Location = "20,30"; $cX64.Checked = $true; $grpOp.Controls.Add($cX64)
    $cArm = New-Object System.Windows.Forms.CheckBox; $cArm.Text = "ARM64"; $cArm.Location = "130,30"; $cArm.Checked = $true; $grpOp.Controls.Add($cArm)
    $cX86 = New-Object System.Windows.Forms.CheckBox; $cX86.Text = "x86"; $cX86.Location = "240,30"; $cX86.Checked = $true; $grpOp.Controls.Add($cX86)
    $cTrim = New-Object System.Windows.Forms.CheckBox; $cTrim.Text = "裁剪"; $cTrim.Location = "20,65"; $grpOp.Controls.Add($cTrim)
    $cAOT = New-Object System.Windows.Forms.CheckBox; $cAOT.Text = "AOT"; $cAOT.Location = "130,65"; $grpOp.Controls.Add($cAOT)
    $cZip = New-Object System.Windows.Forms.CheckBox; $cZip.Text = "生成 Zip"; $cZip.Location = "240,65"; $cZip.Checked = $true; $grpOp.Controls.Add($cZip)
    $cMsix = New-Object System.Windows.Forms.CheckBox; $cMsix.Text = "生成 MSIX"; $cMsix.Location = "340,65"; $cMsix.Checked = $true; $grpOp.Controls.Add($cMsix)
    $cBund = New-Object System.Windows.Forms.CheckBox; $cBund.Text = "合成 Bundle"; $cBund.Location = "450,65"; $cBund.Checked = $true; $grpOp.Controls.Add($cBund)
    $cSign = New-Object System.Windows.Forms.CheckBox; $cSign.Text = "PKI 签名"; $cSign.Location = "560,65"; $cSign.Checked = $true; $grpOp.Controls.Add($cSign)

    $log = New-Object System.Windows.Forms.TextBox; $log.Multiline = $true; $log.Location = "30,350"; $log.Size = "740,380"; $log.BackColor = "Black"; $log.ForeColor = "Lime"; $log.ScrollBars = "Vertical"; $f.Controls.Add($log)
    
    # --- 进度条 ---
    $prog = New-Object System.Windows.Forms.ProgressBar; $prog.Location = "30,740"; $prog.Size = "740,30"; $prog.Minimum = 0; $prog.Maximum = 100; $f.Controls.Add($prog)

    $btnGo = New-Object System.Windows.Forms.Button; $btnGo.Text = "开始任务"; $btnGo.Location = "250,780"; $btnGo.Size = "340,80"; $btnGo.BackColor = "SkyBlue"; $f.Controls.Add($btnGo)

    # --- 底部超链接 (恢复) ---
    $lnk = New-Object System.Windows.Forms.LinkLabel; $lnk.Text = "相关链接：如何创建用于包签名的证书"; $lnk.Location = "30,875"; $lnk.AutoSize = $true
    $lnk.Add_Click({ [System.Diagnostics.Process]::Start("https://learn.microsoft.com/zh-cn/windows/msix/package/create-certificate-package-signing") })
    $f.Controls.Add($lnk)

    # 3. 辅助函数
    function Invoke-ProcessAsync($cmd, $paramStr, $workDir) {
        $psi = New-Object System.Diagnostics.ProcessStartInfo -Property @{ FileName = $cmd; Arguments = $paramStr; WorkingDirectory = $workDir; CreateNoWindow = $true; UseShellExecute = $false }
        $proc = [System.Diagnostics.Process]::Start($psi)
        while (!$proc.HasExited) { [System.Windows.Forms.Application]::DoEvents(); Start-Sleep -Milliseconds 100 }
        return $proc.ExitCode
    }

    function Get-SDKTool($name) {
        $sdkArch = if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") { "x64" } else { "arm64" }
        $tool = Get-ChildItem "C:\Program Files (x86)\Windows Kits\*\bin\*\$sdkArch\$name" -ErrorAction SilentlyContinue | Sort-Object -Property FullName -Descending | Select-Object -First 1
        if (!$tool) { throw "找不到 SDK 工具: $name。请确认是否安装了 Windows SDK。" }
        return $tool.FullName
    }

    # 4. 事件绑定
    $bSrc.Add_Click({ 
        $d = New-Object System.Windows.Forms.FolderBrowserDialog; if($d.ShowDialog() -eq "OK"){ 
            $tSrc.Text = $d.SelectedPath
            $xmlP = Join-Path $d.SelectedPath "Package.appxmanifest"
            if(Test-Path $xmlP){ 
                [xml]$x = Get-Content $xmlP; $tN.Text = $x.Package.Identity.Name; $tV.Text = $x.Package.Identity.Version; $tP.Text = $x.Package.Identity.Publisher
            }
        } 
    })
    $bOut.Add_Click({ $d = New-Object System.Windows.Forms.FolderBrowserDialog; if($d.ShowDialog() -eq "OK"){ $tOut.Text = $d.SelectedPath } })

    $btnGo.Add_Click({
        try {
            $btnGo.Enabled = $false; $log.Clear(); $prog.Value = 0; $msixPaths = @(); $archList = @(); $src = $tSrc.Text; $out = $tOut.Text
            if(!$src -or !$out){ [System.Windows.Forms.MessageBox]::Show("请选择目录"); $btnGo.Enabled = $true; return }
            
            if($cX64.Checked){$archList+="x64"} 
            if($cArm.Checked){$archList+="arm64"} 
            if($cX86.Checked){$archList+="x86"}
            
            # 计算总步数 (兼容低版本PS)
            $step_bundle = if($cBund.Checked){ 1 } else { 0 }
            $step_sign = if($cSign.Checked){ 1 } else { 0 }
            $totalSteps = ($archList.Count * 2) + $step_bundle + $step_sign
            $currentStep = 0

            $pfxPath = Join-Path $out "ModernCert.pfx"
            $secPass = ConvertTo-SecureString -String $tPass.Text -Force -AsPlainText

            # 动态构造 dotnet publish 参数
            $dotNetArgs = "publish -c Release"
            if($cTrim.Checked){ $dotNetArgs += " /p:PublishTrimmed=true" }
            if($cAOT.Checked){ $dotNetArgs += " /p:PublishAot=true" }

            if($cSign.Checked){
                $currentStep++
                $cert = New-SelfSignedCertificate -Type Custom -KeyUsage DigitalSignature -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}") -Subject $tP.Text -FriendlyName "EazyDev Auto Sign" -ErrorAction Stop
                Export-PfxCertificate -cert $cert -FilePath $pfxPath -Password $secPass | Out-Null
                $log.AppendText("证书已生成`r`n")
                $prog.Value = [int][math]::Min(100, ($currentStep / $totalSteps * 100))
            }

            foreach($arch in $archList){
                $log.AppendText(">>> 正在处理 $arch...`r`n"); [System.Windows.Forms.Application]::DoEvents()
                $pDir = Join-Path $out "Pub_$arch"; New-Item -ItemType Directory -Path $pDir -Force | Out-Null
                
                $currentStep++
                $fullCmd = "$dotNetArgs -r win-$arch --self-contained true -o `"$pDir`""
                Invoke-ProcessAsync "dotnet" $fullCmd $src
                $prog.Value = [int][math]::Min(100, ($currentStep / $totalSteps * 100))

                if($cMsix.Checked){
                    Invoke-ProcessAsync "dotnet" "publish -c Release -r win-$arch /p:GenerateAppxPackageOnBuild=true" $src
                    $rawMsix = Get-ChildItem (Join-Path $src "bin") -Filter "*.msix" -Recurse | Where-Object {$_.FullName -match $arch} | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
                    if($rawMsix){
                        $finalMsix = Join-Path $out "$($tN.Text)_$arch.msix"
                        Copy-Item $rawMsix.FullName -Destination $finalMsix -Force
                        if($cSign.Checked){ 
                            $st = Get-SDKTool "signtool.exe"
                            & $st sign /fd SHA256 /f $pfxPath /p $tPass.Text /t http://timestamp.digicert.com $finalMsix | Out-Null
                            $log.AppendText("$arch 签名完成`r`n")
                        }
                        $msixPaths += $finalMsix
                    }
                }
                
                if($cZip.Checked){
                    Compress-Archive -Path "$pDir\*" -DestinationPath "$out\$($tN.Text)_$arch.zip" -Force
                    $log.AppendText("$arch Zip 完成`r`n")
                }

                $currentStep++
                $prog.Value = [int][math]::Min(100, ($currentStep / $totalSteps * 100))
            }

            if($cBund.Checked -and $msixPaths.Count -gt 1){
                $log.AppendText(">>> 正在合成 Bundle...`r`n")
                $map = Join-Path $out "b_map.txt"; "[Files]" | Out-File $map -Encoding utf8
                foreach($p in $msixPaths){ "`"$p`" `"$(Split-Path $p -Leaf)`"" | Out-File $map -Append -Encoding utf8 }
                $bundle = Join-Path $out "$($tN.Text)_Full.msixbundle"
                $ma = Get-SDKTool "makeappx.exe"; & $ma bundle /f $map /p $bundle /o | Out-Null
                if($cSign.Checked){ $st = Get-SDKTool "signtool.exe"; & $st sign /fd SHA256 /f $pfxPath /p $tPass.Text /t http://timestamp.digicert.com $bundle | Out-Null }
                $log.AppendText("所有任务完成`r`n")
            }
            
            $prog.Value = 100
            [System.Windows.Forms.MessageBox]::Show("执行完毕。")
        } catch {
            [System.Windows.Forms.MessageBox]::Show("错误：$($_.Exception.Message)")
        } finally {
            $btnGo.Enabled = $true
        }
    })

    $f.ShowDialog()
} catch {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("脚本初始化失败：$($_.Exception.Message)")
}