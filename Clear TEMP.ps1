$baseName = "Untitled-*.pq"

Get-ChildItem -Path $env:TEMP -Filter $baseName | ForEach-Object {$_.Delete()}
