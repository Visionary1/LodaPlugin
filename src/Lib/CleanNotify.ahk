class CleanNotify 
{
	__New(Title, Msg, pnW := "700", pnH := "300", Pos := "b r", Time := "10") 
	{
		LastFound := WinExist()
		Gui, new, +hwndhNotify -DPIScale
		this.hNotify := hNotify
		Gui, % this.hNotify ": Default"
		Gui, % this.hNotify ": +AlwaysOnTop +ToolWindow -SysMenu -Caption +LastFound +E0x20"
		WinSet, Transparent, 0
		Gui, % this.hNotify ": Color", 0xF2F2F0
		Gui, % this.hNotify ": Font", c0x07D82F s18 wBold Q5, Segoe UI
		Gui, % this.hNotify ": Add", Text, % " x" 20 " y" 12 " w" pnW-20 " hwndhTitle", % Title
		this.hTitle := hTitle
		
		Gui, % this.hNotify ": Font", cBlack s15 wRegular Q5
		Gui, % this.hNotify ": Add", Text, % " x" 20 " y" 55 " w" pnW-20 " h" pnH-55 " hwndhMsg", % Msg
		this.hMsg := hMsg	
		Gui, % this.hNotify ": Show", % "W " pnW + 50 " H" pnH " NoActivate"
		
		this.WinMove(this.hNotify, Pos)
		WinSet, Region, % " 0-0 w" pnW " h" pnH " R40-40", % "ahk_id " this.hNotify
		LodaPlugin.WinFade("ahk_id " . this.hNotify, 210, 5)
		if (WinExist(LastFound))
			Gui, % LastFound ": Default"
	}
	
	Mod(Title, Msg := "") 
	{
		if !(Title == "")
			GuiControl, % this.hNotify ": Text", % this.hTitle, % Title
		if !(Msg == "")
			GuiControl, % this.hNotify ": Text", % this.hMsg, % Msg
	}
	
	Destroy() 
	{
		try LodaPlugin.WinFade("ahk_id " . this.hNotify, 0, 5)
		try Gui, % this.hNotify . ": Destroy"
	}
	
	__Delete() 
	{
		this.Destroy()
	}
	
	WinMove(hwnd,position) 
	{
		SysGet, Mon, MonitorWorkArea
		WinGetPos,ix,iy,w,h, ahk_id %hwnd%
		x := InStr(position,"l") ? MonLeft : InStr(position,"hc") ?  (MonRight-w)/2 : InStr(position,"r") ? MonRight - w : ix
		y := InStr(position,"t") ? MonTop : InStr(position,"vc") ?  (MonBottom-h)/2 : InStr(position,"b") ? MonBottom - h : iy
		WinMove, ahk_id %hwnd%,, x, y
	}
}