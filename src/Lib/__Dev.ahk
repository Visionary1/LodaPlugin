;/ Scirpt to Unicode by Soft
 
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance force
Menu, Tray, NoStandard
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
 
nb = 1
MsgBox, 4160, Notice, should run on the .ahk directory!
Gui, add, edit, xm+420 ym w400 h260 vStrIn, Encoded soruce code`n`nyou can drag&drop a script
;Gui, add, edit, xm y+30 w500 h200 vStrOut, Changed
Gui, add, ListView, xm ym w400 h260 vmyListView gAHKlist AltSubmit, Name|Path
Gui, add, button, xm+420 ym+265 w100 h30, SingleEncode
Gui, add, button, xm ym+265 w100 h30 gAHKget, load script
Gui, add, button, xm+120 ym+265 w100 h30, EncodeAll
LV_ModifyCol(1, 150)
LV_ModifyCol(2, 230)
Gui, show, Autosize, Script to Unicode(UTF-8)
return
 
AHKget:
LV_DELETE() 
Loop, %A_ScriptDir%\*.ahk
{
	Howmuch := A_Index
	File%A_Index% := A_LoopFileName
	LV_Add("", A_LoopFileName, A_LoopFileDir)
}
Gui, +OwnDialogs
MsgBox, 4160, , % Howmuch "`rscripts loaded!"
return
 
AHKlist:
Gui,Submit,NoHide
if (lv_getcount() > 0)
{
if A_GuiEvent = DoubleClick
{
	StrIn := ""
	GuiControl,, StrIn, 
	LV_GetText(ThisName, A_EventInfo, 1)
	FileRead, Opt2, %ThisName%
	GuiControl,, StrIn, %Opt2%
}
}
return
 
ButtonEncodeAll:
Gui, +OwnDialogs
MsgBox, 33, Check, Change all script's encoding?
IfMsgBox, Ok
{
Gui,Submit,NoHide
while nb <= LV_GetCount()
{
	StrIn := ""
	GuiControl,, StrIn, 
	LV_GetText(TrueName, A_Index)
	FileRead, Opt2, %TrueName%
	GuiControl,, StrIn, %Opt2%
	FileDelete, %TrueName%
	FileAppend, %Opt2%, %TrueName%, UTF-8
	;MsgBox % TrueName "Finish"
	nb ++
	TrayTip,, % TrueName "Finished"
}
nb := 1
}
return
 
ButtonSingleEncode:
Gui, Submit, NoHide
FileDelete, %FileName%
StringReplace, op1, FileName, %A_ScriptDir%\,, All
FileAppend, %StrIn%, %op1%, UTF-8
return
 
GuiDropFiles:
FileEncoding, UTF-8
StrIn := ""
GuiControl,, Strin, 
if A_GuiControl = StrIn
{
	FileName := A_GuiEvent
	FileRead, Draged, %A_GuiEvent%
	GuiControl,, StrIn, %Draged%
}
return
 
GuiClose:
ExitApp