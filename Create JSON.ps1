$baseName = "pqinvscode"

# Set bulk of json values
$version = "1.0.1"
$name = "Power Query"
$description = "Creates a new Power Query document and opens it in Visual Studio Code using the Power Query addon (https://marketplace.visualstudio.com/items?itemName=PowerQuery.vscode-powerquery)"
$path = "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"

# Get json value for arguments
$ps1 = {
    # Remove PQ files greater than 7 days old
    (Get-ChildItem "$env:TEMP" -Filter "*.pq") | Where-Object -Property "CreationTime" -LE (Get-Date).AddDays(-7) | ForEach-Object { $_.Delete() }

    # Loop through existing PQ files and sequentially create and open a new one
    for ($i = 1; $i -lt 10000; $i++) {
        if (-not (Test-Path "$env:TEMP\Untitled-$i.pq")) {
            Set-Content "$env:TEMP\Untitled-$i.pq" -Value ""
            Start-Process -FilePath "explorer.exe" -ArgumentList @("$env:TEMP\Untitled-$i.pq")
            break
        }
    }
}
$ps1String = $ps1.ToString().Replace('$baseName', $baseName).Replace('$version', $version)
$ps1Base64 = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($ps1String))
$command = { Invoke-Command -ScriptBlock ([Scriptblock]::Create([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($ps1Base64)))) -ArgumentList @('%server%', '%database%') }
$commandString = $command.ToString().Replace('$ps1Base64', "'$ps1Base64'")
$arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -Command &{$commandString}"
# $arguments = "-NoProfile -ExecutionPolicy Bypass -Command &{$commandString}"

# Get json value for iconData
$imageType = "png"
$imageBase64 = [System.Convert]::ToBase64String((Get-Content -Raw -Encoding Byte "$PSScriptRoot\resources\$baseName.$imageType"))
$iconData = "data:image/$imageType;base64,$imageBase64"

# Create json file
$json = @"
{
  "version": "$version",
  "name": "$name",
  "description": "$description",
  "path": "$path",
  "arguments": "$arguments",
  "iconData": "$iconData"
}
"@
Set-Content "$PSScriptRoot\$baseName.pbitool.json" -Value $json

# Test command that gets launched by powershell
&$command
