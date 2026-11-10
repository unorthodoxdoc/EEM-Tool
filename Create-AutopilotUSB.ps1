<#
.SYNOPSIS
    Creates a bootable USB stick for Windows Autopilot hardware hash extraction from WinPE.
.DESCRIPTION
    GUI tool that prepares a USB drive with all files needed to extract the
    Windows Autopilot hardware hash from a device running WinPE without loading
    the full Windows OS. Copies the extraction script, OA3 tool, config files,
    and PCPKsp.dll, and configures startnet.cmd to auto-launch on boot.
.NOTES
    - Requires WPF (.NET Framework) available in the PowerShell host.
    - Source files (oa3tool.exe, PCPKsp.dll) must exist on the local machine.
    - To make the USB bootable into WinPE, either provide a WinPE source folder containing extracted WinPE files (boot/, sources/, etc.) or check "Install ADK PE Addon via winget" to download Microsoft's official WinPE files automatically.
    - The USB drive will be formatted; all data on it will be lost.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [String] $SourceFolder,

    [Parameter(Mandatory = $false)]
    [String] $Oa3ToolPath,

    [Parameter(Mandatory = $false)]
    [String] $PcpkspPath
)

# Default source paths for binary files
$DefaultOa3ToolPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\Licensing\OA30\oa3tool.exe"
$DefaultPcpkspPath = "C:\Windows\System32\PCPKsp.dll"

# Ensure required binary files are present in the script's root folder.
# Only copy if they are not already there.
$scriptRoot = $PSScriptRoot

$oa3ToolInRoot = Join-Path $scriptRoot "oa3tool.exe"
if (-not (Test-Path $oa3ToolInRoot)) {
    $src = $Oa3ToolPath
    if (-not $src -or -not (Test-Path $src)) {
        $src = $DefaultOa3ToolPath
    }
    if (Test-Path $src) {
        Copy-Item $src $oa3ToolInRoot -Force
    }
}

$pcpkspInRoot = Join-Path $scriptRoot "PCPKsp.dll"
if (-not (Test-Path $pcpkspInRoot)) {
    $src = $PcpkspPath
    if (-not $src -or -not (Test-Path $src)) {
        $src = $DefaultPcpkspPath
    }
    if (Test-Path $src) {
        Copy-Item $src $pcpkspInRoot -Force
    }
}

# Base64-encoded embedded file contents
$b64ExtractScript = "PCMKLlNZTk9QU0lTCiAgICBFeHRyYWN0cyB0aGUgV2luZG93cyBBdXRvcGlsb3QgaGFyZHdhcmUgaGFzaCBmcm9tIGEgZGV2aWNlIHJ1bm5pbmcgV2luUEUuCi5ERVNDUklQVElPTgogICAgUnVucyBmcm9tIGEgVVNCIHN0aWNrIGluIGEgV2luUEUgZW52aXJvbm1lbnQuIFVzZXMgdGhlIE9BMyBUb29sIGZyb20gdGhlCiAgICBXaW5kb3dzIEFESyB0byBnZW5lcmF0ZSB0aGUgaGFyZHdhcmUgaGFzaC4gQ29waWVzIFBDUEtzcC5kbGwgaW50byB0aGUKICAgIFdpblBFIHN5c3RlbTMyIGFuZCByZWdpc3RlcnMgaXQgdmlhIHJ1bmRsbDMyIHNvIHRoZSBoYXNoIGluY2x1ZGVzIFRQTQogICAgaW5mb3JtYXRpb24gKHJlcXVpcmVkIGZvciBzZWxmLWRlcGxveWluZyBBdXRvcGlsb3QgcHJvZmlsZXMpLgogICAgT3V0cHV0cyBhIENTViBmaWxlIHdpdGggdGhlIGRldmljZSBzZXJpYWwgbnVtYmVyIGFuZCBoYXJkd2FyZSBoYXNoLgouTk9URVMKICAgIC0gTXVzdCBiZSBydW4gZnJvbSBhIFBvd2VyU2hlbGwgcHJvbXB0IGluIFdpblBFLgogICAgLSBBbGwgc3VwcG9ydGluZyBmaWxlcyAob2EzdG9vbC5leGUsIE9BMy5jZmcsIGlucHV0LnhtbCwgUENQS3NwLmRsbCkKICAgICAgbXVzdCBiZSBpbiB0aGUgc2FtZSBmb2xkZXIgYXMgdGhpcyBzY3JpcHQgb24gdGhlIFVTQiBkcml2ZS4KICAgIC0gVGhlIGhhc2ggaXMgZ2VuZXJhdGVkIGxvY2FsbHk7IG5vIG5ldHdvcmsgY29ubmVjdGlvbiBpcyByZXF1aXJlZC4KIz4KCltDbWRsZXRCaW5kaW5nKCldCnBhcmFtKAogICAgW1BhcmFtZXRlcihNYW5kYXRvcnkgPSAkZmFsc2UpXQogICAgW1N0cmluZ10gJE91dHB1dEZpbGUgPSAiIiwKCiAgICBbUGFyYW1ldGVyKE1hbmRhdG9yeSA9ICRmYWxzZSldCiAgICBbU3RyaW5nXSAkR3JvdXBUYWcgPSAiIgopCgokc2NyaXB0Um9vdCA9ICRQU1NjcmlwdFJvb3QKJGlzV2luUEUgPSAkZW52OlN5c3RlbVJvb3QgLWVxICJYOlxXaW5kb3dzIgoKaWYgKC1ub3QgJGlzV2luUEUpIHsKICAgIFdyaXRlLUVycm9yICJUaGlzIHNjcmlwdCBtdXN0IGJlIHJ1biBmcm9tIHdpdGhpbiBXaW5QRSAoWDpcV2luZG93cykuIgogICAgZXhpdCAxCn0KCiMgRGV0ZWN0IFVTQiBkcml2ZSAodGhlIGRyaXZlIHRoaXMgc2NyaXB0IGlzIHJ1bm5pbmcgZnJvbSkKJHVzYkRyaXZlID0gJG51bGwKJHNjcmlwdERyaXZlID0gKEdldC1JdGVtICRzY3JpcHRSb290KS5Ecml2ZS5Sb290CgppZiAoVGVzdC1QYXRoICRzY3JpcHREcml2ZSkgewogICAgJHVzYkRyaXZlID0gJHNjcmlwdERyaXZlCn0gZWxzZSB7CiAgICAkdXNiRHJpdmUgPSAoR2V0LVBTRHJpdmUgfCBXaGVyZS1PYmplY3QgewogICAgICAgICRfLlByb3ZpZGVyIC1lcSAiRmlsZVN5c3RlbSIgLWFuZCAkXy5Sb290IC1tYXRjaCAiXlthLXpdOlxcIgogICAgfSB8IEZvckVhY2gtT2JqZWN0IHsKICAgICAgICAkZHJpdmUgPSBHZXQtSXRlbSAkXy5Sb290CiAgICAgICAgaWYgKCRkcml2ZS5Ecml2ZVR5cGUgLWVxIDIpIHsgJF8uUm9vdCB9CiAgICB9IHwgU2VsZWN0LU9iamVjdCAtRmlyc3QgMSkKfQoKaWYgKC1ub3QgJHVzYkRyaXZlKSB7CiAgICBXcml0ZS1FcnJvciAiQ291bGQgbm90IGRldGVybWluZSBVU0IgZHJpdmUgbGV0dGVyLiBQbGVhc2Ugc3BlY2lmeSAtT3V0cHV0RmlsZSBleHBsaWNpdGx5LiIKICAgIGV4aXQgMQp9CgojIENvcHkgUENQS3NwLmRsbCB0byBXaW5QRSBzeXN0ZW0zMiBhbmQgcmVnaXN0ZXIgaXQgKGVuYWJsZXMgVFBNIGluIGhhc2gpCiRwY3Brc3BTb3VyY2UgPSBKb2luLVBhdGggJHNjcmlwdFJvb3QgIlBDUEtzcC5kbGwiCiRwY3Brc3BEZXN0ID0gIlg6XFdpbmRvd3NcU3lzdGVtMzJcUENQS3NwLmRsbCIKCmlmIChUZXN0LVBhdGggJHBjcGtzcFNvdXJjZSkgewogICAgaWYgKC1ub3QgKFRlc3QtUGF0aCAkcGNwa3NwRGVzdCkpIHsKICAgICAgICBDb3B5LUl0ZW0gJHBjcGtzcFNvdXJjZSAkcGNwa3NwRGVzdCAtRm9yY2UKICAgIH0KICAgICYgcnVuZGxsMzIgJHBjcGtzcERlc3QsRGxsSW5zdGFsbAogICAgaWYgKCRMQVNURVhJVENPREUgLW5lIDApIHsKICAgICAgICBXcml0ZS1XYXJuaW5nICJydW5kbGwzMiByZWdpc3RyYXRpb24gb2YgUENQS3NwLmRsbCBmYWlsZWQgKGV4aXQgY29kZSAkTEFTVEVYSVRDT0RFKS4gSGFzaCBtYXkgbGFjayBUUE0gaW5mby4iCiAgICB9Cn0gZWxzZSB7CiAgICBXcml0ZS1XYXJuaW5nICJQQ1BLc3AuZGxsIG5vdCBmb3VuZCBuZXh0IHRvIHNjcmlwdC4gSGFzaCB3aWxsIGJlIGdlbmVyYXRlZCB3aXRob3V0IFRQTSBpbmZvcm1hdGlvbi4iCn0KCiMgQ2xlYW4gdXAgYW55IHN0YWxlIG91dHB1dCBmcm9tIGEgcHJldmlvdXMgcnVuCiR4bWxPdXRwdXQgPSBKb2luLVBhdGggJHNjcmlwdFJvb3QgIk9BMy54bWwiCiRiaW5PdXRwdXQgPSBKb2luLVBhdGggJHNjcmlwdFJvb3QgIk9BMy5iaW4iCgppZiAoVGVzdC1QYXRoICR4bWxPdXRwdXQpIHsgUmVtb3ZlLUl0ZW0gJHhtbE91dHB1dCAtRm9yY2UgfQppZiAoVGVzdC1QYXRoICRiaW5PdXRwdXQpIHsgUmVtb3ZlLUl0ZW0gJGJpbk91dHB1dCAtRm9yY2UgfQoKIyBHZXQgdGhlIGRldmljZSBzZXJpYWwgbnVtYmVyIGZyb20gV01JCnRyeSB7CiAgICAkc2VyaWFsID0gKEdldC1XbWlPYmplY3QgLUNsYXNzIFdpbjMyX0JJT1MgLUVycm9yQWN0aW9uIFN0b3ApLlNlcmlhbE51bWJlci5UcmltKCkKfSBjYXRjaCB7CiAgICBXcml0ZS1XYXJuaW5nICJDb3VsZCBub3QgcmVhZCBzZXJpYWwgbnVtYmVyIGZyb20gV01JOiAkKCRfLkV4Y2VwdGlvbi5NZXNzYWdlKSIKICAgICRzZXJpYWwgPSAiVU5LTk9XTiIKfQoKIyBSdW4gdGhlIE9BMyBUb29sIHRvIGdlbmVyYXRlIHRoZSBoYXJkd2FyZSBoYXNoCiRvYTNUb29sID0gSm9pbi1QYXRoICRzY3JpcHRSb290ICJvYTN0b29sLmV4ZSIKJG9hM0NmZyA9IEpvaW4tUGF0aCAkc2NyaXB0Um9vdCAiT0EzLmNmZyIKCmlmICgtbm90IChUZXN0LVBhdGggJG9hM1Rvb2wpKSB7CiAgICBXcml0ZS1FcnJvciAib2EzdG9vbC5leGUgbm90IGZvdW5kIGF0ICRvYTNUb29sLiBDb3B5IGl0IGZyb20gdGhlIFdpbmRvd3MgQURLIHRvIHRoZSBVU0Igc3RpY2suIgogICAgZXhpdCAxCn0KCmlmICgtbm90IChUZXN0LVBhdGggJG9hM0NmZykpIHsKICAgIFdyaXRlLUVycm9yICJPQTMuY2ZnIG5vdCBmb3VuZCBhdCAkb2EzQ2ZnLiIKICAgIGV4aXQgMQp9CgomIGNkICRzY3JpcHRSb290CgpXcml0ZS1Ib3N0ICJSdW5uaW5nIE9BMyB0b29sIHRvIGdlbmVyYXRlIGhhcmR3YXJlIGhhc2guLi4iIC1Gb3JlZ3JvdW5kQ29sb3IgQ3lhbgokb2EzUHJvY2VzcyA9IFN0YXJ0LVByb2Nlc3MgLUZpbGVQYXRoICRvYTNUb29sIGAKICAgIC1Bcmd1bWVudExpc3QgIi9SZXBvcnQiLCAiL0NvbmZpZ0ZpbGU9JG9hM0NmZyIsICIvTm9LZXlDaGVjayIgYAogICAgLVdhaXQgYAogICAgLVJlZGlyZWN0U3RhbmRhcmRPdXRwdXQgKEpvaW4tUGF0aCAkc2NyaXB0Um9vdCAib2EzX291dHB1dC5sb2ciKSBgCiAgICAtUmVkaXJlY3RTdGFuZGFyZEVycm9yIChKb2luLVBhdGggJHNjcmlwdFJvb3QgIm9hM19lcnJvci5sb2ciKQoKaWYgKCRvYTNQcm9jZXNzLkV4aXRDb2RlIC1uZSAwKSB7CiAgICBXcml0ZS1FcnJvciAiT0EzIHRvb2wgZmFpbGVkIHdpdGggZXhpdCBjb2RlICQoJG9hM1Byb2Nlc3MuRXhpdENvZGUpLiBTZWUgb2EzX2Vycm9yLmxvZyBmb3IgZGV0YWlscy4iCiAgICBleGl0IDEKfQoKIyBQYXJzZSB0aGUgZ2VuZXJhdGVkIFhNTCB0byBleHRyYWN0IHRoZSBoYXJkd2FyZSBoYXNoCmlmICgtbm90IChUZXN0LVBhdGggJHhtbE91dHB1dCkpIHsKICAgIFdyaXRlLUVycm9yICJPQTMgdG9vbCBkaWQgbm90IHByb2R1Y2UgT0EzLnhtbC4gSGFzaCBnZW5lcmF0aW9uIGZhaWxlZC4iCiAgICBleGl0IDEKfQoKdHJ5IHsKICAgIFt4bWxdJHhtbEhhc2ggPSBHZXQtQ29udGVudCAtUGF0aCAkeG1sT3V0cHV0IC1SYXcKICAgICRoYXJkd2FyZUhhc2ggPSAkeG1sSGFzaC5LZXkuSGFyZHdhcmVIYXNoCn0gY2F0Y2ggewogICAgV3JpdGUtRXJyb3IgIkZhaWxlZCB0byBwYXJzZSBPQTMueG1sOiAkKCRfLkV4Y2VwdGlvbi5NZXNzYWdlKSIKICAgIGV4aXQgMQp9CgojIENsZWFuIHVwIGludGVybWVkaWF0ZSBmaWxlcwpSZW1vdmUtSXRlbSAkeG1sT3V0cHV0IC1Gb3JjZQpSZW1vdmUtSXRlbSAkYmluT3V0cHV0IC1Gb3JjZQoKIyBPdXRwdXQgcmVzdWx0cyB0byBjb25zb2xlCldyaXRlLUhvc3QgIiIKV3JpdGUtSG9zdCAiPT09IFdpbmRvd3MgQXV0b3BpbG90IEhhcmR3YXJlIEhhc2ggPT09IiAtRm9yZWdyb3VuZENvbG9yIEN5YW4KV3JpdGUtSG9zdCAiU2VyaWFsIE51bWJlcjogJHNlcmlhbCIKV3JpdGUtSG9zdCAiSGFyZHdhcmUgSGFzaDogJGhhcmR3YXJlSGFzaCIKaWYgKCRHcm91cFRhZykgeyBXcml0ZS1Ib3N0ICJHcm91cCBUYWc6ICRHcm91cFRhZyIgfQpXcml0ZS1Ib3N0ICIiCgojIFNhdmUgcmVzdWx0cyB0byBDU1Ygb24gdGhlIFVTQiBkcml2ZQokb3V0cHV0UGF0aCA9IGlmICgkT3V0cHV0RmlsZSAtbmUgIiIpIHsgJE91dHB1dEZpbGUgfSBlbHNlIHsgSm9pbi1QYXRoICR1c2JEcml2ZSAiQXV0b3BpbG90SGFzaF8kc2VyaWFsLmNzdiIgfQoKJGNzdkNvbnRlbnQgPSAiRGV2aWNlIFNlcmlhbCBOdW1iZXIsV2luZG93cyBQcm9kdWN0IElELEhhcmR3YXJlIEhhc2gsR3JvdXAgVGFnYG4iCiRjc3ZDb250ZW50ICs9ICIkc2VyaWFsLCwkaGFyZHdhcmVIYXNoLCRHcm91cFRhZ2BuIgoKU2V0LUNvbnRlbnQgLVBhdGggJG91dHB1dFBhdGggLVZhbHVlICRjc3ZDb250ZW50IC1FbmNvZGluZyBVVEY4CgpXcml0ZS1Ib3N0ICJSZXN1bHRzIHNhdmVkIHRvOiAkb3V0cHV0UGF0aCIgLUZvcmVncm91bmRDb2xvciBHcmVlbgpXcml0ZS1Ib3N0ICIiCldyaXRlLUhvc3QgIkltcG9ydCB0aGlzIENTViBpbnRvIEludHVuZSAvIEF1dG9waWxvdCB0byByZWdpc3RlciB0aGUgZGV2aWNlLiIgLUZvcmVncm91bmRDb2xvciBDeWFuCg=="
$b64Oa3Cfg = "PE9BMz4KICAgPEZpbGVCYXNlZD4KICAgICAgIDxJbnB1dEtleVhNTEZpbGU+Ii5caW5wdXQuWE1MIjwvSW5wdXRLZXlYTUxGaWxlPgogICA8L0ZpbGVCYXNlZD4KICAgPE91dHB1dERhdGE+CiAgIDxBc3NlbWJsZWRCaW5hcnlGaWxlPiIuXE9BMy5iaW4iPC9Bc3NlbWJsZWRCaW5hcnlGaWxlPgogICA8UmVwb3J0ZWRYTUxGaWxlPiIuXE9BMy54bWwiPC9SZXBvcnRlZFhNTEZpbGU+CiAgIDwvT3V0cHV0RGF0YT4KPC9PQTM+"
$b64InputXml = "PD94bWwgdmVyc2lvbj0iMS4wIj8+CjxLZXk+CiAgICA8UHJvZHVjdEtleT5YWFhYWC1YWFhYWC1YWFhYWC1YWFhYWC1YWFhYWDwvUHJvZHVjdEtleT4KICAgIDxQcm9kdWN0S2V5SUQ+MDAwMDAwMDAwMDAwMDwvUHJvZHVjdEtleUlEPgogICAgPFByb2R1Y3RLZXlTdGF0ZT4wPC9Qcm9kdWN0S2V5U3RhdGU+CjwvS2V5Pg=="
$b64StartNetCmd = "QGVjaG8gb2ZmCmVjaG8gTGF1bmNoaW5nIEF1dG9waWxvdCBUb29sLi4uCmZvciAlJWQgaW4gKEQgRSBGIEcgSCBJIEogSykgZG8gKAogICAgaWYgZXhpc3QgJSVkOlxUb29sc1xFeHRyYWN0LUF1dG9waWxvdEhhc2gucHMxICgKICAgICAgICBwb3dlcnNoZWxsIC1FeGVjdXRpb25Qb2xpY3kgQnlwYXNzIC1GaWxlICIlJWQ6XFRvb2xzXEV4dHJhY3QtQXV0b3BpbG90SGFzaC5wczEiCiAgICAgICAgZ290byA6ZG9uZQogICAgKQopCjpkb25l"

# WPF GUI
Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
Add-Type -AssemblyName System.Drawing -ErrorAction Stop

$form = New-Object System.Windows.Forms.Form
$form.Text = "Autopilot USB Creator"
$form.Size = New-Object System.Drawing.Size(600, 500)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "Create Bootable USB for Autopilot Hash Extraction"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.Size = New-Object System.Drawing.Size(560, 30)
$lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$form.Controls.Add($lblTitle)

$lblSource = New-Object System.Windows.Forms.Label
$lblSource.Text = "Source files folder (contains oa3tool.exe, PCPKsp.dll):"
$lblSource.Location = New-Object System.Drawing.Point(20, 60)
$lblSource.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($lblSource)

$txtSource = New-Object System.Windows.Forms.TextBox
$txtSource.Location = New-Object System.Drawing.Point(20, 80)
$txtSource.Size = New-Object System.Drawing.Size(400, 20)
$txtSource.Text = $SourceFolder
$form.Controls.Add($txtSource)

$btnBrowseSource = New-Object System.Windows.Forms.Button
$btnBrowseSource.Text = "Browse..."
$btnBrowseSource.Location = New-Object System.Drawing.Point(425, 80)
$btnBrowseSource.Size = New-Object System.Drawing.Size(150, 25)
$btnBrowseSource.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select folder containing oa3tool.exe and PCPKsp.dll"
    if ($folderBrowser.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtSource.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($btnBrowseSource)

$lblOa3 = New-Object System.Windows.Forms.Label
$lblOa3.Text = "Path to oa3tool.exe (from Windows ADK):"
$lblOa3.Location = New-Object System.Drawing.Point(20, 110)
$lblOa3.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($lblOa3)

$txtOa3 = New-Object System.Windows.Forms.TextBox
$txtOa3.Location = New-Object System.Drawing.Point(20, 130)
$txtOa3.Size = New-Object System.Drawing.Size(400, 20)
$txtOa3.Text = $Oa3ToolPath
$form.Controls.Add($txtOa3)

$btnBrowseOa3 = New-Object System.Windows.Forms.Button
$btnBrowseOa3.Text = "Browse..."
$btnBrowseOa3.Location = New-Object System.Drawing.Point(425, 130)
$btnBrowseOa3.Size = New-Object System.Drawing.Size(150, 25)
$btnBrowseOa3.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "Executable|*.exe|All files|*.*"
    $fileDialog.Title = "Select oa3tool.exe"
    if ($fileDialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtOa3.Text = $fileDialog.FileName
    }
})
$form.Controls.Add($btnBrowseOa3)

$lblPcpksp = New-Object System.Windows.Forms.Label
$lblPcpksp.Text = "Path to PCPKsp.dll (from Windows System32):"
$lblPcpksp.Location = New-Object System.Drawing.Point(20, 160)
$lblPcpksp.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($lblPcpksp)

$txtPcpksp = New-Object System.Windows.Forms.TextBox
$txtPcpksp.Location = New-Object System.Drawing.Point(20, 180)
$txtPcpksp.Size = New-Object System.Drawing.Size(400, 20)
$txtPcpksp.Text = $PcpkspPath
$form.Controls.Add($txtPcpksp)

$btnBrowsePcpksp = New-Object System.Windows.Forms.Button
$btnBrowsePcpksp.Text = "Browse..."
$btnBrowsePcpksp.Location = New-Object System.Drawing.Point(425, 180)
$btnBrowsePcpksp.Size = New-Object System.Drawing.Size(150, 25)
$btnBrowsePcpksp.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = "DLL|*.dll|All files|*.*"
    $fileDialog.Title = "Select PCPKsp.dll"
    if ($fileDialog.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtPcpksp.Text = $fileDialog.FileName
    }
})
$form.Controls.Add($btnBrowsePcpksp)

$chkDownload = New-Object System.Windows.Forms.CheckBox
$chkDownload.Text = "Install ADK PE Addon via winget"
$chkDownload.Location = New-Object System.Drawing.Point(20, 215)
$chkDownload.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($chkDownload)

$lblWinpe = New-Object System.Windows.Forms.Label
$lblWinpe.Text = "WinPE source folder (contains boot/, sources/, etc.):"
$lblWinpe.Location = New-Object System.Drawing.Point(20, 235)
$lblWinpe.Size = New-Object System.Drawing.Size(300, 20)
$form.Controls.Add($lblWinpe)

$txtWinpe = New-Object System.Windows.Forms.TextBox
$txtWinpe.Location = New-Object System.Drawing.Point(20, 255)
$txtWinpe.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($txtWinpe)

$btnBrowseWinpe = New-Object System.Windows.Forms.Button
$btnBrowseWinpe.Text = "Browse..."
$btnBrowseWinpe.Location = New-Object System.Drawing.Point(425, 255)
$btnBrowseWinpe.Size = New-Object System.Drawing.Size(150, 25)
$btnBrowseWinpe.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Select folder containing extracted WinPE files (boot/, sources/, etc.)"
    if ($folderBrowser.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtWinpe.Text = $folderBrowser.SelectedPath
    }
})
$form.Controls.Add($btnBrowseWinpe)

$lblDrive = New-Object System.Windows.Forms.Label
$lblDrive.Text = "Select USB drive:"
$lblDrive.Location = New-Object System.Drawing.Point(20, 275)
$lblDrive.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($lblDrive)

$cmbDrive = New-Object System.Windows.Forms.ComboBox
$cmbDrive.Location = New-Object System.Drawing.Point(20, 295)
$cmbDrive.Size = New-Object System.Drawing.Size(400, 20)
$cmbDrive.DropDownStyle = "DropDownList"

# Detect removable USB drives via WMI (more reliable than Get-PSDrive)
$removableDrives = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq 2 } | Select-Object -ExpandProperty DeviceID

if ($removableDrives) {
    foreach ($drive in $removableDrives) {
        $cmbDrive.Items.Add($drive)
    }
}

if ($cmbDrive.Items.Count -eq 0) {
    $cmbDrive.Items.Add("No removable drives detected")
    $cmbDrive.Enabled = $false
}
$form.Controls.Add($cmbDrive)

$chkFormat = New-Object System.Windows.Forms.CheckBox
$chkFormat.Text = "Format USB drive (FAT32) before copying"
$chkFormat.Location = New-Object System.Drawing.Point(20, 265)
$chkFormat.Size = New-Object System.Drawing.Size(300, 20)
$chkFormat.Checked = $true
$form.Controls.Add($chkFormat)

$lblProgress = New-Object System.Windows.Forms.Label
$lblProgress.Text = "Ready"
$lblProgress.Location = New-Object System.Drawing.Point(20, 295)
$lblProgress.Size = New-Object System.Drawing.Size(560, 20)
$form.Controls.Add($lblProgress)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 320)
$progressBar.Size = New-Object System.Drawing.Size(560, 20)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = "Create USB Drive"
$btnCreate.Location = New-Object System.Drawing.Point(20, 350)
$btnCreate.Size = New-Object System.Drawing.Size(250, 40)
$btnCreate.Add_Click({
    $btnCreate.Enabled = $false
    $btnExit.Enabled = $false
    $cmbDrive.Enabled = $false
    $chkFormat.Enabled = $false
    $txtSource.Enabled = $false
    $txtOa3.Enabled = $false
    $txtPcpksp.Enabled = $false
    $btnBrowseSource.Enabled = $false
    $btnBrowseOa3.Enabled = $false
    $btnBrowsePcpksp.Enabled = $false
    $txtWinpe.Enabled = $false
    $btnBrowseWinpe.Enabled = $false
    $chkDownload.Enabled = $false

    $usbDrive = $cmbDrive.SelectedItem
    if (-not $usbDrive -or $usbDrive -eq "No removable drives detected") {
        [System.Windows.Forms.MessageBox]::Show("Please select a valid USB drive.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    $sourceFolder = $txtSource.Text
    $oa3Tool = $txtOa3.Text
    $pcpksp = $txtPcpksp.Text
    $winpeSource = $txtWinpe.Text
    $downloadWinpe = $chkDownload.IsChecked
    $downloadUrl = $txtDownloadUrl.Text
    $downloadPath = $txtDownloadPath.Text

    # Use files from script root if they exist there
    $scriptRoot = $PSScriptRoot
    $oa3ToolInRoot = Join-Path $scriptRoot "oa3tool.exe"
    $pcpkspInRoot = Join-Path $scriptRoot "PCPKsp.dll"

    # If user specified paths in GUI, use those; otherwise use files from script root
    if ($oa3Tool -and (Test-Path $oa3Tool)) {
        $oa3ToolToUse = $oa3Tool
    } elseif (Test-Path $oa3ToolInRoot) {
        $oa3ToolToUse = $oa3ToolInRoot
    } else {
        [System.Windows.Forms.MessageBox]::Show("oa3tool.exe not found. Place it next to this script or specify its path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    if ($pcpksp -and (Test-Path $pcpksp)) {
        $pcpkspToUse = $pcpksp
    } elseif (Test-Path $pcpkspInRoot) {
        $pcpkspToUse = $pcpkspInRoot
    } else {
        [System.Windows.Forms.MessageBox]::Show("PCPKsp.dll not found. Place it next to this script or specify its path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    if (-not (Test-Path $sourceFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Source folder does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    if (-not (Test-Path $oa3ToolToUse)) {
        [System.Windows.Forms.MessageBox]::Show("oa3tool.exe not found at specified path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    if (-not (Test-Path $pcpkspToUse)) {
        [System.Windows.Forms.MessageBox]::Show("PCPKsp.dll not found at specified path.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        return
    }

    if (-not (Test-Path $winpeSource)) {
        [System.Windows.Forms.MessageBox]::Show("WinPE source folder does not exist.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        $txtWinpe.Enabled = $true
        $btnBrowseWinpe.Enabled = $true
        return
    }

    $lblProgress.Text = "Preparing USB drive..."
    $progressBar.Value = 10

    # Run long work in a background job so the GUI does not lock up
    $job = Start-Job -ScriptBlock {
        param($usbDrive, $oa3ToolToUse, $pcpkspToUse, $formatChecked, $scriptRoot, $b64ExtractScript, $b64Oa3Cfg, $b64InputXml, $b64StartNetCmd, $winpeSource, $downloadWinpe, $downloadUrl, $downloadPath)

        $usbRoot = $usbDrive
        if (-not $usbRoot.EndsWith("\")) { $usbRoot += "\" }

        # Decode embedded files
        $extractScript = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64ExtractScript))
        $oa3Cfg = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64Oa3Cfg))
        $inputXml = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($b64InputXml))
        $startNetCmd = [System.Text.Encoding]::ASCII.GetString([Convert]::FromBase64String($b64StartNetCmd))

        # Format if requested
        if ($formatChecked) {
            Write-Output "progress:Formatting USB drive $usbDrive..."
            $formatOutput = & format.com $usbDrive /FS:FAT32 /Q /V:"AutopilotUSB" /Y
            $formatOutput | Out-Null
            Start-Sleep -Seconds 5
        }

        # Optionally download WinPE via winget (ADK PE Addon)
        if ($downloadWinpe) {
            Write-Output "progress:Installing ADK PE Addon via winget..."
            $wingetOutput = & winget install --id=Microsoft.ADKPEAddon -e
            $wingetOutput | Out-Null
            Start-Sleep -Seconds 5

            # Find the WinPE source directory in the ADK installation
            $adkRoot = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64"
            if (Test-Path $adkRoot) {
                # Search for boot.wim to locate the WinPE source
                $bootWim = Get-ChildItem $adkRoot -Recurse -Filter "boot.wim" -File | Select-Object -First 1
                if ($bootWim) {
                    $winpeSource = Split-Path $bootWim.FullName -Parent
                    Write-Output "progress:Found WinPE source at $winpeSource"
                } else {
                    Write-Output "progress:Warning: boot.wim not found in ADK directory"
                }
            } else {
                Write-Output "progress:Warning: ADK directory not found after winget install"
            }
        }

        # Copy WinPE boot files to make USB bootable
        if ($winpeSource -and (Test-Path $winpeSource)) {
            Write-Output "progress:Copying WinPE boot files..."
            # Copy all WinPE files to USB root
            $winpeItems = Get-ChildItem $winpeSource -Recurse | Where-Object { -not $_.PSIsContainer }
            foreach ($item in $winpeItems) {
                $dest = Join-Path $usbRoot $item.FullName.Substring($winpeSource.Length)
                $destDir = Split-Path $dest -Parent
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                Copy-Item $item.FullName $dest -Force
            }

            # Make USB bootable with bootsect
            $bootsect = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\amd64\bootsect.exe"
            if (-not (Test-Path $bootsect)) {
                $bootsect = "bootsect.exe"
            }
            if (Test-Path $bootsect) {
                & $bootsect $usbDrive /nt52
                Start-Sleep -Seconds 2
            }
        }

        Write-Output "progress:Copying files..."

        $toolsFolder = Join-Path $usbRoot "Tools"
        if (-not (Test-Path $toolsFolder)) { New-Item -ItemType Directory -Path $toolsFolder -Force | Out-Null }

        Set-Content -Path (Join-Path $toolsFolder "Extract-AutopilotHash.ps1") -Value $extractScript -Encoding UTF8
        Set-Content -Path (Join-Path $toolsFolder "OA3.cfg") -Value $oa3Cfg -Encoding UTF8
        Set-Content -Path (Join-Path $toolsFolder "input.xml") -Value $inputXml -Encoding UTF8

        Copy-Item $oa3ToolToUse (Join-Path $toolsFolder "oa3tool.exe") -Force
        Copy-Item $pcpkspToUse (Join-Path $toolsFolder "PCPKsp.dll") -Force

        Set-Content -Path (Join-Path $usbRoot "startnet.cmd") -Value $startNetCmd -Encoding ASCII

        Write-Output "progress:Files copied successfully."
        Start-Sleep -Seconds 1
        Write-Output "progress:Complete!"

        Write-Output "result:success"
        Write-Output "usbDrive:$usbDrive"
    } -ArgumentList $usbDrive, $oa3ToolToUse, $pcpkspToUse, $chkFormat.Checked, $scriptRoot, $b64ExtractScript, $b64Oa3Cfg, $b64InputXml, $b64StartNetCmd, $winpeSource, $downloadWinpe, $downloadUrl, $downloadPath

    # Poll for job completion and update UI from main thread
    while ($job.State -eq 'Running') {
        $job | Receive-Job | ForEach-Object {
            if ($_ -is [string] -and $_.StartsWith("progress:")) {
                $status = $_.Substring(9)
                $form.BeginInvoke({ $lblProgress.Text = $status }, @())
            }
        }
        Start-Sleep -Seconds 1
    }

    # Handle job failure
    if ($job.State -eq 'Failed') {
        $lblProgress.Text = "Failed."
        $progressBar.Value = 0
        $job.Error | ForEach-Object { $_.Exception.Message }
        [System.Windows.Forms.MessageBox]::Show("Background job failed to complete.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    } else {
        $finalOutput = $job | Receive-Job
        Remove-Job $job

        # Re-enable controls
        $btnCreate.Enabled = $true
        $btnExit.Enabled = $true
        $cmbDrive.Enabled = $true
        $chkFormat.Enabled = $true
        $txtSource.Enabled = $true
        $txtOa3.Enabled = $true
        $txtPcpksp.Enabled = $true
        $btnBrowseSource.Enabled = $true
        $btnBrowseOa3.Enabled = $true
        $btnBrowsePcpksp.Enabled = $true
        $txtWinpe.Enabled = $true
        $btnBrowseWinpe.Enabled = $true
        $chkDownload.Enabled = $true

        if ($finalOutput -contains "result:success") {
            $lblProgress.Text = "Complete!"
            $progressBar.Value = 100
            $usbDriveName = ($finalOutput -match "usbDrive:(.+)")[1]

            [System.Windows.Forms.MessageBox]::Show(
                "USB drive $usbDriveName has been prepared successfully.`n`n" +
                "Files copied:`n" +
                "- WinPE boot files (from source folder)`n" +
                "- Extract-AutopilotHash.ps1`n" +
                "- oa3tool.exe`n" +
                "- PCPKsp.dll`n" +
                "- OA3.cfg`n" +
                "- input.xml`n" +
                "- startnet.cmd (auto-launches on boot)`n`n" +
                "Boot the target device to this USB WinPE and PowerShell will launch the extraction tool automatically.",
                "Success",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
        } else {
            $lblProgress.Text = "Failed."
            $progressBar.Value = 0
            [System.Windows.Forms.MessageBox]::Show("Failed to create USB drive.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    }
})
$form.Controls.Add($btnCreate)

$btnExit = New-Object System.Windows.Forms.Button
$btnExit.Text = "Exit"
$btnExit.Location = New-Object System.Drawing.Point(280, 350)
$btnExit.Size = New-Object System.Drawing.Size(300, 40)
$btnExit.Add_Click({ $form.Close() })
$form.Controls.Add($btnExit)

# Show the form
[void] $form.ShowDialog()
