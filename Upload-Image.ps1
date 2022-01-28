param(
    [string]$imagePath, 
    [string]$message = 'Commited by GH-Images', 
    [string]$localPath = '~/.gh-images'
)

Push-Location
try {
    if (Test-Path $imagePath) {
        if (-not (Test-Path $localPath)) {
            gh repo create gh-images-repository --public
            gh repo clone gh-images-repository $localpath
        }

        Set-Location $localPath
        Copy-Item $imagePath -Destination $localPath
        $newItem = (Split-Path $imagePath -Leaf);
        if (Test-Path $newItem) {
            git add "$newItem"
            git commit -m $message
            git push

            $url=gh browse -n "$newItem"
        }

        return $url;
    }
}
finally {
    Pop-Location
}