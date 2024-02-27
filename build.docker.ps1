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
$ErrorActionPreference = 'Stop'
try {
    $dockerImageName = ($packageId -creplace '\B([A-Z])','-$1' `
        -replace 'EdFi\.Ods','ods-api' `
        -replace '\.','-'`
        -replace 'M-I6', 'MI6'`
        -replace 'U-I', 'ui'`
        -replace 'M-I-D-X', 'MIDX'`
        ).ToLower()

    Write-Verbose $dockerImageName
    $packageSource = Join-Path -Path $packageFolder -ChildPath "$packageId.$($packageVersion.Split('+')[0]).nupkg"

    Copy-Item -Path $packageSource -Destination "$dockerProject\app.zip"
    #rename package to zip so it does not get pushed to OctopusDeploy
    Rename-Item -LiteralPath $packageSource -NewName "$(Split-Path -Path $packageSource -LeafBase).zip"

    Push-Location -Path $dockerProject

    $imageVersion = $packageVersion.Replace('+','_')

    $imageName = "$registry$dockerImageName"

    docker build -t "${imageName}:$imageVersion" -t $imageName --platform linux .

    $existingImageNames = $existingImageNames | Where-Object{$_ -ne " "}
    $existingImageNames += "$imageName|n${imageName}:$imageVersion"

    $newImageNames = [string]::Join('|n',$existingImageNames)

    Write-Output "##teamcity[setParameter name='imageName' value='$newImageNames']"
} Catch {
    Write-Error $_
    exit(1)
} Finally {
    Pop-Location
}