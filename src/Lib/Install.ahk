#Include, zip.ahk
FileInstall, Resource\Resource.zip, % A_Temp . "\LodaPlugin.zip"
zip := new ZipFile(A_Temp . "\LodaPlugin.zip")
zip.Unpack("", A_Temp . "\")