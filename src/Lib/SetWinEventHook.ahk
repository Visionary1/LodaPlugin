﻿HookProc(hWinEventHook, Event, hwnd) 
{
	static EVENT_OBJECT_LOCATIONCHANGE := 0x800B, EVENT_OBJECT_FOCUS := 0x8005, EVENT_OBJECT_DESTROY := 0x8001
	
	If (Event = EVENT_OBJECT_FOCUS) ; when PotPlayer is activated
	{
		Return Win.Top(__Main.hPlugin, __Main.Docking)
	}
	
	Else If (Event = EVENT_OBJECT_DESTROY) && !WinExist("ahk_id " . __Main.PotPlayer["Hwnd"])
	{
		DllCall("UnhookWinEvent", "Ptr", __Main.Event)
		DllCall("GlobalFree", "Ptr", __Main.HookAddr, "Ptr")
		;TVClose(__Main.hPlugin, 40, 120)
		__GaGa.__Delete()
		Win.Kill(__Main.Docking)
		__Main.GuiClose()
		;Win.Destruct("ahk_id " . __Main.PotPlayer["Hwnd"], __Main) ; need to check since it fires too often
	}
	
	Else If (Event = EVENT_OBJECT_LOCATIONCHANGE) && (hwnd = __Main.PotPlayer["Hwnd"])
	{
		WinGetPos, hX, hY, hW, hH, % "ahk_id " . __Main.PotPlayer["Hwnd"]
		WinGetPos, cX, cY, cW, cH, % "ahk_id " . __Main.hPlugin

		Resizer.(__Main.hPlugin, hX, hY - 66, hW, cH)
		;DllCall("MoveWindow", "Ptr", __Main.hPlugin, "Int", hX, "Int", hY - 66, "Int", hW, "Int", cH, "Int", true)
		If (__Main.Docking)
			Resizer.(__Main.Docking, hX + hW + 5, hY - 66, 400, hH + 66)
			;DllCall("MoveWindow", "Ptr", __Main.Docking, "Int", hX + hW + 5, "Int", hY - 66, "Int", 400, "Int", hH + 66, "Int", true)
	}
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) 
{ 
	DllCall("CoInitialize", "Ptr", 0)
	Return DllCall("SetWinEventHook", "UInt", eventMin, "UInt", eventMax, "Ptr", hmodWinEventProc, "Ptr", lpfnWinEventProc, "UInt", idProcess, "UInt", idThread, "UInt", dwFlags) 
}