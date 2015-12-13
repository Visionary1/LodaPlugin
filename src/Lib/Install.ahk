#Include <zip>
FileCreateDir, % A_Temp . "\LodaPlugin"
FileInstall, Resource\Resource.zip, % A_Temp . "\LodaPlugin\LodaPlugin.zip"
If !InStr(FileExist(A_Temp "\LodaPlugin\PD.png"), "D")
{
	zip := new ZipFile(A_Temp . "\LodaPlugin\LodaPlugin.zip").Unpack("", A_Temp . "\LodaPlugin\")
	zip.Unpack("", A_Temp . "\LodaPlugin\")
} 