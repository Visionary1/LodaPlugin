Class Win
{
	Activate(Hwnd)
	{
		WinActivate, % "ahk_id " . Hwnd
		WinWaitActive, % "ahk_id " . Hwnd
	}

	Top(Hwnds*)
	{
		For k, Hwnd in Hwnds
		{
			If WinExist("ahk_id " . Hwnd) {
				WinSet, AlwaysOnTop, On, % "ahk_id " . Hwnd
				WinSet, AlwaysOnTop, Off, % "ahk_id " . Hwnd
			}
		}
	}
	/*
	Destruct(Hwnd, Parent) 
	{
		If !WinExist(Hwnd)
			Parent.GuiClose()
	}
	*/

	Kill(Hwnds*)
	{
		For k, Hwnd in Hwnds
			WinKill, % "ahk_id " . Hwnd
	}

	Fade(w := "", t := 128, i := 1, d := 5) 
	{
		t := (t >= 255) ? 255 : (t < 0) ? 0 : t
		WinGet, s, Transparent, % w
		s := (s == "") ? 255 : s
		WinSet,Transparent,% s,% w
		i := (s<t) ? abs(i) : -1*abs(i)
		While (k := (i<0) ? (s>t) : (s<t) && WinExist(w)) {
			WinGet, s, Transparent, % w
			s+=i
			WinSet, Transparent, % s, % w
			Sleep, % d
		}
	}

	Hover(Hwnd)
	{
		static Save := False

		MouseGetPos,,, OnWin
		If ( Hwnd = OnWin ) && (Save = False) {
			Save := !Save
			ControlFocus,, % "ahk_id" . Hwnd
			this.Fade("ahk_id " . Hwnd, 255, 15)
		} Else If ( Hwnd != OnWin ) && (Save != False) {
			Save := !Save
			this.Fade("ahk_id " . Hwnd, 150, 5)
		}
	}
}