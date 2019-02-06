## Paramaters - change these as appropriate

$inputDirectory = "InputFiles";
$outputDirectory = "OutputFiles";
$notFoundDirectory = "NoMatchFiles"
$nameLookFile = "Names.csv"
$baseOutputDirectory = Get-Date -UFormat "%Y-%m-%d %H-%M-%S"

# Assumes that all files are in the format prefix_filename.pdf
## Examples:
##  abc123_test.pdf will be renamed to abbot, barely_filename.pdf where there is an entry such as abc123 | abbot, barely_filename.pdf in the supplied csv file
# Troubleshooting
## When saving the file in excel please ensure you're saving as a CSV file format.
## Make sure all 3 directories exist (input, output, not found)
# nameLookFile format
## It should have two columns:
### Prefix
### FullName

function CopyMatchedFileToOutputDirectory($oldFilename, $newFilename) {
    Write-Host "Renaming '$oldFilename' to '$newFilename'";

    $fullOldPath = Join-Path -Path $inputDirectory -ChildPath $oldFilename
    $fullNewPath = Join-Path -Path $outputDirectory -ChildPath $newFilename
    
    Copy-Item -Path $fullOldPath -Destination $fullNewPath
}

function CopyUnmatchedFileToOutputDirectory($oldFilename) {
    $fullOldPath = Join-Path -Path $inputDirectory -ChildPath $oldFilename
    $fullNewPath = Join-Path -Path $notFoundDirectory -ChildPath $oldFilename
    
    Copy-Item -Path $fullOldPath -Destination $fullNewPath
}

$files = Get-ChildItem $inputDirectory

$nameLookup = @{}
Import-Csv $nameLookFile | ForEach-Object {
  $nameLookup[$_.Prefix] = $_.FullName
    
    if([string]::IsNullOrEmpty($_.Prefix) -eq $true) {
        Write-Warning "Empty row found in names CSV file. Verify the file has the headers Prefix and FullName"
    }
    
    if([string]::IsNullOrEmpty($_.FullName) -eq $true) {
        Write-Warning "Empty row found in names CSV file. Verify the file has the headers Prefix and FullName"
    }
}

Write-Host "Found $($files.Count) files in the input directory.";

for ($i=0; $i -lt $files.Count; $i++) {
    
    $oldFilename = $files[$i];
    
    $prefix = ($oldFilename -split "_")[1]
    $fullName = $nameLookup[$prefix]

    if([string]::IsNullOrEmpty($fullName) -eq $true) {
        Write-Warning "No match found for username '$prefix', filename is '$oldFilename'"
        CopyUnmatchedFileToOutputDirectory($oldFilename);
    }
    else {
        $newFilename = $oldFilename -replace $prefix,$fullName
        CopyMatchedFileToOutputDirectory $oldFilename.Name  $newFilename
    }
} 
