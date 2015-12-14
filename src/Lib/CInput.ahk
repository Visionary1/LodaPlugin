class Input
{
	Send(Sends, To, Tick := 50, Focus := False) 
	{
		if (Focus = true)
			Win.Activate("ahk_id" . To)
			;ControlFocus,, % "ahk_id " . To
		ControlSend, ahk_parent, % Sends, % "ahk_id " . To
		Sleep,% Tick
	}
	
	Click(Control, To) 
	{
		ControlClick, % Control, % "ahk_id " . To,,,, NA
	}
}