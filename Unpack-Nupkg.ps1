<#
Author: Eric K. Miller
Last updated: 21 May 2025

This script automates the manual installation of .nupkg files to create PowerShell modules.

From the Microsoft documentation at
https://learn.microsoft.com/en-us/powershell/gallery/how-to/working-with-packages/manual-download:

1. Rename the .nupkg extension(s) to .zip
2. Use the Expand-Archive cmdlet to extract to a folder with the module name in $env:PSModulePath
3. Remove the four specified NuGet items
4. (Optional: Delete the source .zip)
#>
Clear-Host

$SrcPath = Read-Host "Source directory of the .nupkg file"
$ModulePath = Read-Host "Destination directory for the module (must be in `$env:PSModulePath`)"

$NuGet_REMOVE = @('_rels', 'package', '*Content_Types*.xml', '*.nuspec')

Get-ChildItem $SrcPath -File |
    ForEach-Object {
        if ($_.Extension -eq '.nupkg')
        {
            $ModuleFolder = $_.BaseName -replace '\.\d+', ''  # remove version numbers
            Copy-Item -Path $_.FullName -Destination ($_.FullName -replace '.nupkg', '.zip')  # change extension
            Expand-Archive -Path ($_.FullName -replace '.nupkg', '.zip') -DestinationPath "$ModulePath\$ModuleFolder"
            foreach ($ni in $NuGet_REMOVE)
            {
                Remove-Item -Path "$ModulePath\$ModuleFolder\$ni" -Recurse -Force
            }
            Remove-Item -Path ($_.FullName -replace '.nupkg', '.zip') -Recurse -Force -Confirm  # option to delete .zip
        }
    }