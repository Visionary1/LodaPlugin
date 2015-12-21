class Input
{
	Send(Sends, Hwnd, Focus := False) 
	{
		If (Focus)
			Win.Activate(Hwnd)
			;ControlFocus,, % "ahk_id " . Hwnd
		;ControlSend, ahk_parent, % Sends, % "ahk_id " . Hwnd
		SendInput, % Sends
		Sleep, 50
	}
	
	Click(Control, Hwnd, Focus := False) 
	{
		If (Focus)
			Win.Activate(Hwnd)

		ControlClick, % Control, % "ahk_id " . Hwnd,,,, NA
	}
}