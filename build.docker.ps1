[CmdLetBinding()]
param(
    [string]$packageFolder = ".\Ed-Fi-ODS-Implementation\packages",
    [string]$dockerProject =  ".\Ed-Fi-ODS-Docker\Web-Sandbox-Admin\Alpine\mssql",
    [string]$packageId = "EdFi.Ods.SandboxAdmin",
    [string]$packageVersion = "0.0.0",
    [string]$registry = "",
    [Parameter(ValueFromRemainingArguments)]
    [string[]]$existingImageNames = @()
)

try {

    $dockerImageName = ($packageId -creplace '\B([A-Z])','-$1' `
        -replace 'EdFi\.Ods','ods-api' `
        -replace '\.','-'`
        -replace 'M-I6', 'MI6'`
        -replace 'U-I', 'ui'`
        ).ToLower()

    Write-Verbose $dockerImageName
    $packageSource = Join-Path -Path $packageFolder -ChildPath "$packageId.$packageVersion.nupkg"

    Copy-Item -Path $packageSource -Destination "$dockerProject\app.zip"

    Push-Location -Path $dockerProject

    $imageVersion = $packageVersion.Split('+')[0]

    $imageName = "$registry$dockerImageName"

    docker build -t "${imageName}:$imageVersion" -t $imageName --platform linux .

    $existingImageNames = $existingImageNames | Where-Object{$_ -ne " "}
    $existingImageNames += $imageName

    $newImageNames = [string]::Join('|n',$existingImageNames)

    Write-Output "##teamcity[setParameter name='imageName' value='$newImageNames']"
} Catch {
    $ErrorMessage = $_.Exception.Message
    Write-Output $ErrorMessage
    exit(1)
} Finally {
    Pop-Location
}