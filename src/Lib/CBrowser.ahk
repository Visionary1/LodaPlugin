class Browser 
{
	__New(Title, URL) 
	{
		global WB
		Gui, New, +Resize +hwndhThis
		this.hMain 						:= hThis
		this.Bound 						:= []
		this.Bound.OnMessage 	:= this.OnMessage.Bind(this)
		Gui, % this.hMain ": Add", ActiveX, x0 y0 w500 h500 hwndhThis vWB, Shell.Explorer
		this.hEmbed 					:= hThis
		WB.silent := true, WB.Navigate(URL)
		WinEvents.Register(this.hMain, this)
		OnMessage(0x100, this.Bound.OnMessage)
		Gui, % this.hMain . ": Show", % " hide w" A_ScreenWidth*0.3 " h" A_ScreenHeight*0.6 , % Title
		Gui, % this.hMain . ": Show", % " hide w" A_ScreenWidth*0.3 " h" A_ScreenHeight*0.6 , % Title
	}
	
	GuiSize() 
	{
		DllCall("MoveWindow", "Ptr", this.hEmbed, "Int", 0, "Int", 0, "Int", A_GuiWidth, "Int", A_GuiHeight, "Int", true)
	}
	
	GuiClose() 
	{
		Gui, % this.hMain . ": Hide"
	}
	
	Show() 
	{
		WinShow, % "ahk_id " . this.hMain
	}
	
	__Delete() 
	{
		OnMessage(0x100, this.Bound.OnMessage, 0)
		this.Delete("Bound")
		WinEvents.Unregister(this.hMain)
		Gui, % this.hMain . ": Destroy"
	}
	
	OnMessage(wParam, lParam, Msg, hWnd) 
	{
		global WB
		static fields := "hWnd,Msg,wParam,lParam,A_EventInfo,A_GuiX,A_GuiY"
		
		if (Msg = 0x100) {
			WinGetClass, ClassName, ahk_id %hWnd%
			
			if (ClassName = "MacromediaFlashPlayerActiveX" && wParam == GetKeyVK("Enter"))
				SendInput, {tab 4}{space}+{tab 4}
			
			if (ClassName = "Internet Explorer_Server") {
				pipa := ComObjQuery(WB.document, "{00000117-0000-0000-C000-000000000046}")
				VarSetCapacity(Msgs, 48)
				Loop Parse, fields, `,             ;`
					NumPut(%A_LoopField%, Msgs, (A_Index-1)*A_PtrSize)
				TranslateAccelerator := NumGet(NumGet(1*pipa)+5*A_PtrSize)
				Loop 2
					r := DllCall(TranslateAccelerator, "Ptr",pipa, "Ptr",&Msgs)
				until wParam != 9 || WB.document.activeElement != ""
				ObjRelease(pipa)
				if r = 0
					return 0
			}
		}
	}
}