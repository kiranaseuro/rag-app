$scriptDir = $PSScriptRoot
$rootDir = (Get-Item $scriptDir).Parent.FullName
$distDir = Join-Path $rootDir "dist"

if (Test-Path $distDir) {
    Remove-Item -Path $distDir -Recurse -Force
}
New-Item -ItemType Directory -Path $distDir -Force

$functions = @("auth_handler", "db_init", "document_processor", "evaluation_handler", "query_handler", "upload_handler")

foreach ($fn in $functions) {
    $srcDir = Join-Path $rootDir "src\$fn"
    if (Test-Path $srcDir) {
        $zipPath = Join-Path $distDir "${fn}.zip"
        Write-Host "Packaging $fn to $zipPath"
        # Using a temporary file to avoid issues with Compress-Archive's locking or path length
        Compress-Archive -Path "$srcDir\*" -DestinationPath $zipPath -Force
    }
    else {
        Write-Warning "Source directory not found: $srcDir"
    }
}

Write-Host "Packaged Lambda functions to $distDir"
