# Set the directory path to clean up
$directoryPath = "C:\git"

# Set the list of folders to keep (use full paths)
$foldersToKeep = @("C:\git\commonFilesDir")

# Get the current time
$currentTime = Get-Date

# Set the time interval (in hours)
$timeInterval = 1

# Function to check if a path is protected
function Is-Protected($path) {
    foreach ($folder in $foldersToKeep) {
        if ($path -eq $folder -or $path.StartsWith($folder + [System.IO.Path]::DirectorySeparatorChar)) {
            return $true
        }
    }
    return $false
}

# Recursively process items in the directory
Get-ChildItem -Path $directoryPath -Recurse | ForEach-Object {
    $fullPath = $_.FullName
    
    if (Is-Protected $fullPath) {
        Write-Output "Skipping: $fullPath (protected)"
    } else {
        $timeDifference = ($currentTime - $_.LastWriteTime).TotalHours
        
        if ($timeDifference -gt $timeInterval) {
            if ($_.PSIsContainer) {
                try {
                    Remove-Item $fullPath -Recurse -Force -ErrorAction Stop
                    Write-Output "Deleted folder: $fullPath"
                } catch {
                    Write-Output "Unable to delete folder: $fullPath. Error: $_"
                }
            } else {
                try {
                    Remove-Item $fullPath -Force -ErrorAction Stop
                    Write-Output "Deleted file: $fullPath"
                } catch {
                    Write-Output "Unable to delete file: $fullPath. Error: $_"
                }
            }
        } else {
            $itemType = if ($_.PSIsContainer) { "folder" } else { "file" }
            Write-Output ("Skipping {0}: {1} (last modified less than {2} hour(s) ago)" -f $itemType, $fullPath, $timeInterval)
        }
    }
}