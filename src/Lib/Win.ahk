class Win
{
	Activate(Hwnd)
	{
		WinActivate, % hWnd
		WinWaitActive, % hWnd
	}

	Top(Hwnd)
	{
		WinSet, AlwaysOnTop, On, % hWnd
		WinSet, AlwaysOnTop, Off, % hWnd
	}

	Destruct(Hwnd, Parent) 
	{
		if !WinExist(Hwnd)
			Parent.GuiClose()
	}

	Fade(w := "", t := 128, i := 1, d := 5) 
	{
		t := (t >= 255) ? 255 : (t < 0) ? 0 : t
		WinGet, s, Transparent, % w
		s := (s == "") ? 255 : s
		WinSet,Transparent,% s,% w
		i := (s<t) ? abs(i) : -1*abs(i)
		while (k := (i<0) ? (s>t) : (s<t) && WinExist(w)) {
			WinGet, s, Transparent, % w
			s+=i
			WinSet, Transparent, % s, % w
			Sleep, % d
		}
	}

	Hover(Hwnd)
	{
		static Save := true

		MouseGetPos,,, OnWin
		if ( hWnd = OnWin ) && (Save = false) {
			Save := !Save
			;ControlFocus,, % "ahk_id" . Hwnd
			this.Fade("ahk_id " . hWnd, 255, 15)
		} else if ( hWnd != OnWin ) && (Save != false) {
			Save := !Save
			this.Fade("ahk_id " . hWnd, 125, 5)
		}
	}
}