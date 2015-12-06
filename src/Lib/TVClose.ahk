TVClose(Target, H_ReduceCount := 2, W_ReduceCount := 2) ;Credits, tmplinshi
{
	WinGetPos, x, y, w, h, % "ahk_id " . Target
	
	; Decrease height (keep 3 pixels)
	Step := (h - 3) / H_ReduceCount
	Loop, % H_ReduceCount
	{
		y += Step / 2 ; Moving down
		h -= Step     ; Decreasing height
		DllCall("MoveWindow", "Ptr", Target, "Int", x, "Int", y, "Int", w, "Int", h, "Int", true)
	}
	
	; Decrease Width (keep 3 pixels)
	Step := (w - 3) / W_ReduceCount
	Loop, % W_ReduceCount
	{
		x += Step / 2 ; Moving right
		w -= Step     ; Decreasing width
		DllCall("MoveWindow", "Ptr", Target, "Int", x, "Int", y, "Int", w, "Int", h, "Int", true)
	}
}