Set-ExecutionPolicy RemoteSigned

$tmp = Get-Location
$cwd = $tmp.Path
$rootDir = $cwd.Substring(0, $cwd.LastIndexOf("\"))
$env:__ROOTDIR__ = $rootDir

$tmpDir = (Join-Path $rootDir "~tmp")

if(!(Test-Path $tmpDir))
{
	mkdir $tmpDir
}

function GinGW_Donwload_Unzip_Install() {

Set-ExecutionPolicy RemoteSigned
#加载winapi 
trap [exception]
{
 '在trap中捕获到脚本异常'
 $_.Exception.Message
 continue
} 
try
{


$ini = Add-Type -memberDefinition @"  
[DllImport("Kernel32")]  
public static extern int GetPrivateProfileString (  
string section ,    
string key ,   
string def ,   
StringBuilder retVal ,    
int size ,   
string filePath );   
"@ -passthru -name MyPrivateProfileString -UsingNamespace System.Text  
$retVal=New-Object System.Text.StringBuilder(256) 
$filePath=$env:__ROOTDIR__ + '\config.ini'
$null=$ini::GetPrivateProfileString("MinGW","location","",$retVal,256,$filePath)  


$MINGW_URL=$retVal.tostring()  

$fileNameToSave = $MINGW_URL.Split("/")[-1]

#
#
$file = (Join-Path $tmpDir $fileNameToSave)

(New-Object System.Net.WebClient).DownloadFile($MINGW_URL,$file)

If (!$?)
{
"下载文件操作失败";
break
};

$destinationToUnzip = $rootDir

if(!(Test-Path $destinationToUnzip))
{
	mkdir $destinationToUnzip
}

$shell = New-Object -ComObject Shell.Application
$sourceFolder = $shell.NameSpace($file)
$destinationFolder = $shell.NameSpace($destinationToUnzip)
$destinationFolder.CopyHere($sourceFolder.Items())

if(!$?) {
"解压文件操作失败";
break	
}

$execPath = (Join-Path $destinationToUnzip $fileNameToSave.Split(".")[0])

$execFile = (Join-Path $execPath "bin\mingw-get.exe")


&$execFile install msys-base
&$execFile install msys-wget
&$execFile install msys-flex
&$execFile install msys-bison
&$execFile install msys-perl

$bashExe = (Join-Path $rootDir "MinGW\msys\1.0\bin\bash.exe")

$setupSh = (Join-Path $rootDir "setup\setup.sh")

 
Get-Item $bashExe
if(!$?) {
	$($bashExe + "not existed")
	break	
}


&$bashExe $setupSh

}
catch
{
   echo $_.Exception.Message
   exit 1
 
}

}

GinGW_Donwload_Unzip_Install
