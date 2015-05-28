properties{
	$projectName = "Iteration0"
    $config = if($useConfig){$useConfig} else {"Debug"};
	$baseDir = Resolve-Path .\
	$srcDir = "$baseDir\src"
    $buildDir = "$baseDir\build\"
	$packagesDir = "$buildDir\$config\"
	$slnFile = "$srcDir\DDD-Sample.sln"
}

task Default -depends Clean, CommonAssemblyInfo, Build, Test 

task Clean {
	msbuild $slnFile /m /t:Clean /p:VisualStudioVersion=12.0
	pushd src
	dir -directory bin -recurse | remove-item -recurse
	dir -directory obj -recurse | remove-item -recurse
	popd
	remove-item $packagesDir -recurse -ErrorAction Ignore
}

task CommonAssemblyInfo -description "Builds common assembly info file" {
	$buildNbr = if($env:build_number){$env:build_number} else {"999"};
	$version = "0.0.0.$buildNbr"   
    create-commonAssemblyInfo "$version" $projectName "$srcDir\CommonAssemblyInfo.cs"
}

task Build -depends Clean,CommonAssemblyInfo -description "Builds solution"{
	msbuild $slnFile /m /p:Configuration=$config /t:Build /p:VisualStudioVersion=12.0
}

task -name Test -depends Build -description "Run all tests" -action {
}
	
function global:create-commonAssemblyInfo($version,$applicationName,$filename)
{
"using System.Reflection;
using System.Runtime.InteropServices;

//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated by a tool.
//     Runtime Version:2.0.50727.4927
//
//     Changes to this file may cause incorrect behavior and will be lost if
//     the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

[assembly: ComVisibleAttribute(false)]
[assembly: AssemblyVersionAttribute(""$version"")]
[assembly: AssemblyFileVersionAttribute(""$version"")]
[assembly: AssemblyCopyrightAttribute(""Copyright 2013-2015"")]
[assembly: AssemblyProductAttribute(""$applicationName"")]
[assembly: AssemblyCompanyAttribute(""ClearMeasure Workshop"")]
[assembly: AssemblyConfigurationAttribute(""release"")]
[assembly: AssemblyInformationalVersionAttribute(""$version"")]"  | out-file $filename -encoding "ASCII"    
}
