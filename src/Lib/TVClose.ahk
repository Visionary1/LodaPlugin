TVClose(Target, H_ReduceCount := 2, W_ReduceCount := 2) ;Credits, tmplinshi
{
	WinGetPos, x, y, w, h, % "ahk_id " . Target
	
	; Decrease height (keep 3 pixels)
	Step := (h - 3) / H_ReduceCount
	Loop, % H_ReduceCount
	{
		y += Step / 2 ; Moving down
		h -= Step     ; Decreasing height
		Resizer.(Target, x, y, w, h)
	}
	
	; Decrease Width (keep 3 pixels)
	Step := (w - 3) / W_ReduceCount
	Loop, % W_ReduceCount
	{
		x += Step / 2 ; Moving right
		w -= Step     ; Decreasing width
		Resizer.(Target, x, y, w, h)
	}
}