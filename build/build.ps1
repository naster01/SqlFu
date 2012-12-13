$projName="SqlFu"
$buildDir=$psake.build_script_dir
$rootDir=Split-Path $buildDir
$projectDir=$rootDir+"\src\"+$projName
$projectFile=$projectDir+"\SqlFu.csproj"
$buildOutputPath =$projectDir+"\bin\Release"
$tempDir=join-path $rootDir "temp"
$nuspec=join-path $tempDir "project.nuspec"
$nugetOut=join-path $rootDir "nugets"
$nuget=join-path $buildDir "libs\nuget.exe"
$sqlfuAsm="$buildOutputPath\$projName"+".dll"
$cavemanAsm="$buildOutputPath\CavemanTools.dll"

Framework "4.0"
# Framework "4.0x64"


task default -depends clean,build,nuget

task clean{
   Write-Host "Cleaning..."
   msbuild $projectFile /t:Clean /v:quiet
   rd $tempDir -recurse
   mkdir $tempDir
}

task build {
    exec { msbuild $projectFile /t:Build /p:Configuration=Release /v:quiet }
}


task nuget{
   mkdir "$tempDir\lib\Net40"
    xcopy "$buildOutputPath\$projName*.*"  "$tempDir\lib\Net40"
   xcopy "$buildDir\project.nuspec" (split-path $nuspec)
      $specFile=[xml](Get-Content $nuspec)
	  	   $specFile.package.metadata.version=[string](GetVersion)
			$specFile.package.metadata.dependencies.dependency.version=[string](CavemanVersion)	  
	      $specFile.Save($nuspec)
   "Updated version"
   "Building package..."
   & $nuget pack $nuspec -o $nugetOut
   
}

function GetVersion
{
  [string] $version= [System.Diagnostics.FileVersionInfo]::GetVersionInfo($sqlfuAsm).ProductVersion.ToString()
 Write-Host "SqlFu version is " $version
 return $version
}

function CavemanVersion
{
  [string] $version= [System.Diagnostics.FileVersionInfo]::GetVersionInfo($cavemanAsm).ProductVersion.ToString()
 Write-Host "CavemanTools version is " $version
 return $version
}