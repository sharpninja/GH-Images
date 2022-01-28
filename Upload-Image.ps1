param(
    [string]$imagePath,
    [string]$message = 'Commited by GH-Images',
    [string]$localPath = "$env:USERPROFILE\gh-images-repository"
)

Push-Location
try {
    if (Test-Path $imagePath) {
        if (-not (Test-Path $localPath)) {
            $path = split-path $localPath
            $repo = split-path $localPath -leaf
            if(-not (Test-Path $path)){
                mkdir $path
            }
            Set-Location $path
            $existingRepo = gh repo list --public --json name -q '.[].name' `
                | Where-Object { $_ -eq $repo }

            if(-not $existingRepo) {
                gh repo create $repo --public
            }

            gh repo clone $repo $localpath
        }

        Set-Location $localPath
        Copy-Item $imagePath -Destination $localPath
        $newItem = (Split-Path $imagePath -Leaf);
        if (Test-Path $newItem) {
            git add "$newItem"
            git commit -m $message
            git push

            $url=gh browse -n
            # username/repo[/subdir][@ref]
            $url = $url.Replace('github.com', 'raw.githubusercontent.com');
        }

        return "$url/main/$($newItem.Replace(" ", "%20"))"
    }
}
finally {
    Pop-Location
}