param(
    [string]$imagePath, 
    [string]$message="Commited by GH-Images", 
    [string]$localPath="~/.gh-images"
)

if(Test-Path $imagePath) {
    if(-not (Test-Path $localPath)){
        mkdir $localPath
    }

    $newItem = copy-item $imagePath -Destination $localPath

    git add $newItem
    git commit -m $message
    git push
}