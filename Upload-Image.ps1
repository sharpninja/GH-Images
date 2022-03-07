#param(
    #[string[]]$imagePaths
    #[string]$message = 'Commited by GH-Images',
    #[string]$localPath = "$env:USERPROFILE\gh-images-repository"
#)

Push-Location
try {
    # Write-Host $args

    $imagePaths = $args

    # if ($args.IndexOf(' ') -gt -1) {
    #     Write-Host "Splitting $args on space"
    #     $imagePaths = $args.Split(' ');
    # }
    # if ($args.IndexOf("`n") -gt -1) {
    #     Write-Host "Splitting $args on NewLine"
    #     $imagePaths += $args.Split("`n");
    # }

    $results = @()
    $message = 'Commited by GH-Images'
    $localPath = "$env:USERPROFILE\gh-images-repository"
    # Write-Host ("`$imagePaths has [${0}] images." -f $imagePaths.Length)
    foreach ($imagePath in $imagePaths) {
        if (Test-Path $imagePath) {
            if (-not (Test-Path $localPath)) {
                $path = Split-Path $localPath
                $repo = Split-Path $localPath -Leaf
                if (-not (Test-Path $path)) {
                    mkdir $path
                }
                Set-Location $path
                $existingRepo = gh repo list --public --json name -q '.[].name' `
                | Where-Object { $_ -eq $repo }

                if (-not $existingRepo) {
                    gh repo create $repo --public
                }

                gh repo clone $repo $localpath
            }

            Set-Location $localPath
            Copy-Item $imagePath -Destination $localPath -Force > $null
            $newItem = (Split-Path $imagePath -Leaf);
            if (Test-Path $newItem) {
                git add "$newItem" > $null
                git commit -m $message > $null

                $url = gh browse -n
                # username/repo[/subdir][@ref]
                $url = $url.Replace('github.com', 'raw.githubusercontent.com');
            }

            $results += "$url/main/$($newItem.Replace(' ', '%20'))"
        }

    }

    git push > $null

    # write-host
    write-host $results
}
finally {
    Pop-Location
}