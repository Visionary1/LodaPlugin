﻿Class Entry
{
	As(Type := "User")
	{
		this.Admin()
		this.Common()
		If (Type == "User")
			this.User()
		Else If (Type == "Dev")
			this.Dev()
	}

	Admin()
	{
		If !(A_IsAdmin) {
			If (A_IsCompiled)
				DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? "Ptr" : "UInt"), 0, "Str", "RunAs", "Str", A_ScriptFullPath, "Str", "" , "Str", A_WorkingDir, "Int", 1)
			Else
				DllCall("shell32\ShellExecute" . (A_IsUnicode ? "" :"A"), (A_PtrSize=8 ? "Ptr" : "UInt"), 0, "Str", "RunAs", "Str", A_AhkPath, "Str", """" . A_ScriptFullPath . """" . A_Space . "", "Str", A_WorkingDir, "Int", 1)
			ExitApp
		}
	}
	
	Common() 
	{
		#NoEnv ;Changed to Default for new AutoHotkey v2
		#SingleInstance Off
		SetKeyDelay, 20, 10
		SetWinDelay, 0
		SetControlDelay, 0
		;SetBatchLines, -1
		ComObjError(False)
		Menu, Tray, NoStandard
		ShowGa := Func("ShowGa"), Terminate := Func("Terminate")
		Menu, Tray, Add, 가가라이브 채팅, % ShowGa
		Menu, Tray, Add,
		Menu, Tray, Add, 종료하기, % Terminate
	}
	
	User() 
	{
		#KeyHistory 0
		ListLines Off
	}
	
	Dev() 
	{
		;#Warn
	}
}

CloseCallback(__Main) {
	ExitApp
}

Terminate() {
	If WinExist("ahk_id " . __Noti.hNotify)
		CloseCallback(__Main)
	Else
		__Main.GuiClose()
}

ShowGa() {
	__GaGa.Show()
}