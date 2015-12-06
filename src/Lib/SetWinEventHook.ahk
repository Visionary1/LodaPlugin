HookProc(hWinEventHook, Event, hwnd) 
{
	static EVENT_OBJECT_LOCATIONCHANGE := 0x800B	, EVENT_OBJECT_FOCUS := 0x8005, EVENT_OBJECT_DESTROY := 0x8001
	
	if (Event = EVENT_OBJECT_FOCUS) ; when PotPlayer is activated
	{
		LodaPlugin.SetTop("ahk_id " . __Main.hPlugin)
		if WinExist("ahk_id " . __Main.Docking)
			LodaPlugin.SetTop("ahk_id " . __Main.Docking)
	}
	
	else if (Event = EVENT_OBJECT_DESTROY)
		LodaPlugin.Destruct("ahk_pid " . __Main.DaumPotPlayer.pPotPlayer, __Main) ; need to check since it fires too often
	
	else if (Event = EVENT_OBJECT_LOCATIONCHANGE) && (hwnd = __Main.hPotPlayer)
	{
		WinGetPos hX, hY, hW, hH, % "ahk_id " . __Main.hPotPlayer
		WinGetPos cX, cY, cW, cH, % "ahk_id " . __Main.hPlugin
		
		DllCall("MoveWindow", "Ptr", __Main.hPlugin, "Int", hX, "Int", hY - 66, "Int", hW, "Int", cH, "Int", true)
		if __Main.Docking
			DllCall("MoveWindow", "Ptr", __Main.Docking, "Int", hX + hW, "Int", hY - 66, "Int", 400, "Int", hH + 66, "Int", true)
	}
}

SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) 
{ 
	DllCall("CoInitialize", "uint", 0) 
	return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "uint", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags) 
}