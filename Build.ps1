[CmdletBinding(DefaultParameterSetName='None')]
Param(
    # Archive containing the Ceph Windows binaries, will be fetched using scp.
    # Can be a local path, a UNC path or a remote scp path.
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$CephZipPath,

    # The thumbprint of the X509 certificate used for signing the WNBD driver
    # and the MSI installer
    [Parameter(ParameterSetName="Sign", Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SignX509Thumbprint,
    [Parameter(ParameterSetName="Sign", Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SignTimestampUrl,
    [Parameter(ParameterSetName="Sign", Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$SignCrossCertPath
)

$ErrorActionPreference = "Stop"

function SetVCVars($version="2019", $platform="x86_amd64") {
    pushd "$ENV:ProgramFiles (x86)\Microsoft Visual Studio\$version\Community\VC\Auxiliary\Build"
    try {
        cmd /c "vcvarsall.bat $platform & set" |
        foreach {
          if ($_ -match "=") {
            $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
          }
        }
    }
    finally {
        popd
    }
}

function Sign($x509thumbprint, $crossCertPath, $timestampUrl, $path) {
    & signtool.exe sign /ac $crossCertPath /sha1 $x509thumbprint /tr $timestampUrl /td SHA256 /v $path
    if($LASTEXITCODE) { throw "signtool failed" }
}

function BuildWnbd() {

    pushd $depsBuildDir
    & git.exe clone https://github.com/cloudbase/wnbd
    if($LASTEXITCODE) {
        throw "git failed"
    }
    cd wnbd

    & msbuild.exe vstudio\wnbd.sln /p:Configuration=Release
    if($LASTEXITCODE) {
        throw "msbuild failed"
    }

    if($SignX509Thumbprint) {
        Sign $SignX509Thumbprint $SignCrossCertPath $SignTimestampUrl .\vstudio\x64\Release\driver\wnbd.sys
        Sign $SignX509Thumbprint $SignCrossCertPath $SignTimestampUrl .\vstudio\x64\Release\driver\wnbd.cat
    }

    copy vstudio\x64\Release\driver\* ..\..\Driver\
    copy vstudio\x64\Release\libwnbd.dll ..\..\Binaries\

    popd
}

function GetCephBinaries() {
    pushd $depsBuildDir

    & scp.exe $CephZipPath ceph.zip
    if($LASTEXITCODE) {
        throw "scp failed"
    }

    if (Test-Path ceph) {
        rm -Recurse -Force ceph\
    }

    Expand-Archive ceph.zip -DestinationPath .
    rm ceph.zip

    cd ceph
    copy -Path *.dll,`
    ceph-conf.exe,`
    rados.exe,`
    rbd.exe,`
    rbd-wnbd.exe,`
    ceph-dokan.exe `
    -Destination ..\..\Binaries\

    popd
}

$depsBuildDir = "Dependencies"

SetVCVars

if (Test-Path $depsBuildDir) {
    rm -Recurse -Force $depsBuildDir\
}
mkdir $depsBuildDir

del Driver\*
del Binaries\*

GetCephBinaries
BuildWnbd

$configuration = "Release"
& msbuild.exe ceph-windows-installer.sln /p:Platform=x64 /p:Configuration=$configuration
if($LASTEXITCODE) {
    throw "msbuild failed"
}

if($SignX509Thumbprint) {
    Sign $SignX509Thumbprint $SignCrossCertPath $SignTimestampUrl .\bin\Release\Ceph.msi
}

Write-Output ""
Write-Output "Success! MSI location: $((get-childitem .\bin\$configuration\Ceph.msi).FullName)"
