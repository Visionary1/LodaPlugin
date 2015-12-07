#Include <Functor>
#Include <CBrowser>
#Include <CleanNotify>
#Include <CMsgBox>
#Include <JSON>
#Include <CInput>
#Include <CWinEvents>
#Include <SetWinEventHook>
#Include <TVClose>
#Include <Entry>

Entry.As("User")
global pName	:= "로다 플러그인", pVersion := "0.1"
global jXon	:= JSON.Load("https://goo.gl/7KhJiP")
global __Noti 	:= new CleanNotify(pName, "팟플레이어 애드온`n" , (A_ScreenWidth / 3) + 10, (A_ScreenHeight / 6) - 10, "vc hc", "P")
global __Main	:= new LodaPlugin(pName, pVersion)
global __GaGa 	:= new Browser("가가라이브 채팅", "http://goo.gl/zlBZPF")
__Main.RegisterCloseCallback(Func("__Destruct"))
Return

__Destruct(__Main) {
	ExitApp
}

ShowGa() {
	__GaGa.Show()
}

Terminate() {
	__Main.GuiClose()
}

class LodaPlugin 
{
	__New(Title, Version) 
	{
		Gui, new, -DPIScale -Resize -SysMenu +ToolWindow +LastFound
		this.hPlugin		:= WinExist()
		this.Bound		:= []
		this.Bound.PDMenu	:= ObjBindMethod(this, "PDMenu")
		this.Bound.Hover	:= new this.Thread( ObjBindMethod(this.Hover, "", this.hPlugin) )
		this.Bound.Parser	:= new this.Thread( ObjBindMethod(this.Parser, "", "", "Refresh", this.Bound.PDMenu) )
		this.Parser("New", this.Bound.PDMenu), __Noti := ""
		this.Bound.OnMessage 	:= this.OnMessage.Bind(this)
		Buttons			:= new this.MenuButtons(this)
		this.Bound.Transition	:= new this.Transition(this)
		Menus			:=
		(Join
		[
			["채팅창 열기", [
				["익스플로러 사용", Buttons.IE.Bind(Buttons)],
				["파이어폭스 사용", Buttons.FireFox.Bind(Buttons)],
				["크롬 사용", Buttons.Chrome.Bind(Buttons)]
			]], ["실험실", [
				["채팅창 도킹하기", Buttons.Docking.Bind(Buttons)]
			]], ["그리고", [
				["개발자에게 피드백", Buttons.Feedback.Bind(Buttons)],
				["POOO 이동", Buttons.goPOOO.Bind(Buttons)]
			]]
		]
		)
		this.Menus	:= this.CreateMenuBar(Menus)
		this.PotPlayer	:= this.DaumPotPlayer.Run()
		this.ThreadID	:= DllCall("GetWindowThreadProcessId", "Ptr", this.PotPlayer["PID"])
		this.HookAddr	:= RegisterCallback("HookProc", 0, 3)
		this.Event	:= SetWinEventHook(EVENT_OBJECT_DESTROY := 0x8001, EVENT_OBJECT_LOCATIONCHANGE := 0x800B, 0
		, this.HookAddr, this.PotPlayer["PID"], this.ThreadID, 0)
		
		Menu, MenuBar, Add, % "설정", % ":" . this.Menus[1]
		try Menu, MenuBar, Icon, % "설정", % A_Temp . "\setting.png",, 0
		for each, Item in {"채팅창 열기": "vote", "실험실": "info", "그리고": "then"}
			try Menu, % "Loda_0", Icon, % each, % A_Temp . "\" . Item . ".png",, 0
		for each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹하기": "Loda_2"}
			try Menu, % Item, Icon, % each, % A_Temp . "\off.png",, 0
		Gui, Menu, MenuBar
		
		WinEvents.Register(this.hPlugin, this)
		for each, Item in [0x0047, 0x200, 0x2A2]
			OnMessage(Item, this.Bound.OnMessage)
		WinGetPos, pX, pY,,, % "ahk_id " . this.PotPlayer["Hwnd"]
		Gui, Show, % "x" pX " y" pY - 71 " w" 430 "h " 15, % Title . " " . Version
		
		this.Bound.Hover.Start(100)
		this.Bound.Parser.Start( 60000 * 10 )
	}
	
	__Delete() 
	{
		this.GuiClose()
	}
	
	OnMessage(wParam, lParam, Msg, hWnd) 
	{
		static WM_WINDOWPOSCHANGED := 0x0047
		
		if (Msg = WM_WINDOWPOSCHANGED) && !WinActive("ahk_id " . this.PotPlayer["Hwnd"]) && !WinActive("가가라이브 채팅") {
			this.SetTop("ahk_id " . this.PotPlayer["Hwnd"])
			WinGetPos, iX, iY,,, % "ahk_id " . this.hPlugin
			WinMove, % "ahk_id " . this.PotPlayer["Hwnd"],, % iX, % iY + 66
		}
	}
	
	GuiClose()
	{
		Critical
		__GaGa := ""
		try WinKill, % "ahk_id " . this.PotPlayer["Hwnd"]
		try WinKill, % "ahk_id " . this.Docking
		TVClose(this.hPlugin, 40, 100)
		for each, Item in [0x0047, 0x200, 0x2A2]
			OnMessage(Item, this.Bound.OnMessage, 0)
		this.Bound.Hover.Destroy()
		this.Bound.Parser.Destroy()
		this.Delete("Bound")
		WinEvents.Unregister(this.hPlugin)
		Gui, Destroy
		DllCall("GlobalFree", "Ptr", this.HookAddr, "Ptr")
		this.CloseCallback()
	}
	
	RegisterCloseCallback(CloseCallback) 
	{
		this.CloseCallback := CloseCallback
	}
	
	CreateMenuBar(Menu) ; ty, GeekDude
	{
		static MenuName := 0
		Menus := ["Loda_" . MenuName++]
		for each, Item in Menu
		{
			Ref := Item[2]
			if IsObject(Ref) && Ref._NewEnum() {
				SubMenus := this.CreateMenuBar(Ref)
				Menus.Push(SubMenus*), Ref := ":" . SubMenus[1]
			}
			Menu, % Menus[1], Add, % Item[1], % Ref
		}
		return Menus
	}
	
	PDMenu(ItemName, ItemPos, MenuName) 
	{
		static DefaultServer := "hi.cdn.livehouse.in"

		PDName	:= SubStr(SubStr(ItemName, 1, InStr(ItemName, "`t")), 1, -1)
		StreamURL	:= "http://" . DefaultServer . "/" . jXon[PDName] . "/video/playlist.m3u8"
		ChatURL	:= "https://livehouse.in/en/channel/" . jXon[PDName] . "/chatroom"
		Return		this.Bound.Transition(StreamURL, ChatURL, this.ChatMethod)
	}

	class MenuButtons ;ty, GeekDude!
	{
		__New(Parent) 
		{
			this.Parent := Parent
		}
		
		IE(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹하기": "Loda_2"}
				try Menu, % Item, Icon, % each, % A_Temp . "\off.png",, 0
			try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\on.png",, 0
			
			this.Parent.Docking		:= ""
			this.Parent.ChatMethod	:= "iexplore.exe"
		}
		
		FireFox(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"익스플로러 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹하기": "Loda_2"}
				try Menu, % Item, Icon, % each, % A_Temp . "\off.png",, 0
			try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\on.png",, 0
			
			this.Parent.Docking		:= ""
			this.Parent.ChatMethod	:= "firefox.exe"
		}
		
		Chrome(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "채팅창 도킹하기": "Loda_2"}
				try Menu, % Item, Icon, % each, % A_Temp . "\off.png",, 0
			try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\on.png",, 0
			
			this.Parent.Docking		:= ""
			this.Parent.ChatMethod	:= "chrome.exe"
		}
		
		Docking(ItemName, ItemPos, MenuName) 
		{
			Docker := new MsgBox("도킹", "브라우저를 팟플레이어와 함께 움직이도록", "확인' 후 도킹할 윈도우를 우클릭하세요!", "확인|취소", "GREEN", this.Parent.PotPlayer["Hwnd"])
			if (Docker == "확인")
			{
				while !GetKeyState("RButton", "P") {
					MouseGetPos, , , id, control
					WinGetTitle, title, ahk_id %id%
					ToolTip, %title%`n`n이 윈도우를 도킹하려면 우클릭 하세요!
					Sleep, 100
				}
				ToolTip,
				MsgBox, 262180, Dock, %title%`n`n윈도우를 도킹할까요?
				IfMsgBox, Yes
				{
					for each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1"}
						try Menu, % Item, Icon, % each, % A_Temp . "\off.png",, 0
					try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\on.png",, 0
					
					this.Parent.Docking		:= id
					this.Parent.ChatMethod	:= "Docking"
				}
			}
		}
		
		Feedback() 
		{
			try Run, http://knowledgeisfree.tistory.com/guestbook
		}
		
		goPOOO() 
		{
			try Run, http://poooo.ml/
		}
	}
	
	class DaumPotPlayer
	{
		class Run extends Functor
		{
			static is64	:= InStr(A_ScriptName, "64") ? "64" : ""
			, isMini		:= InStr(A_ScriptName, "Mini") ? "Mini" : ""

			Call(Self)
			{
				this.UseStreamTimeShift()

				try Run, % this.GetPath() . "\PotPlayer" . this.isMini . this.is64 . ".exe",,, TargetPID
				catch {
					MsgBox, 262192, 이런!, 팟플레이어가 설치되지 않은 것 같아요`n설치후에 다시 실행해주세요!, 5
					LodaPlugin.__Delete()
				}
				WinWaitActive, % "ahk_pid " . TargetPID
				Return {"Hwnd": WinExist("ahk_pid" . TargetPID), "PID": TargetPID}
			}

			GetPath()
			{
				RegRead, PotPlayerPath, HKCU, % "SOFTWARE\DAUM\PotPlayer" . this.is64, ProgramFolder
				Return ErrorLevel = 0 ? PotPlayerPath : ""
			}

			UseStreamTimeShift() 
			{
				RegWrite, REG_DWORD, HKCU
				, % "SOFTWARE\DAUM\PotPlayer" . this.isMini . this.is64 . "\Settings", UseStreamTimeShift, 1
				RegWrite, REG_DWORD, HKCU
				, % "SOFTWARE\DAUM\PotPlayer" . this.isMini . this.is64 . "\Settings", StreamTimeShiftTime, 10
			}
		}
	}

	class Transition extends Functor
	{
		static Interval 	:= 30
		, isMini 		:= InStr(A_ScriptName, "Mini") ? true : false
		, is64 		:= InStr(A_ScriptName, "64") ? "Button6" : "Button7"

		__New(Parent)
		{
			this.Parent := Parent
		}

		Call(Self, StreamURL, ChatURL, ChatMethod)
		{
			this.DePrev("ahk_class #32770", "주소 열기")
			this.PotPlayer(StreamURL)
			this.Talk(ChatURL, ChatMethod)
			if (this.isMini)
				this.Repos()
		}

		PotPlayer(StreamURL)
		{
			Input.Send("{Ctrl Down}u{Ctrl Up}", this.Parent.PotPlayer["Hwnd"]), Work := ""
			while !Work
				Work := WinActive("ahk_class #32770", "주소 열기")
			WinSet, Transparent, 0, % "ahk_id " . Work

			Holding := ""
			while !Holding {
				LodaPlugin.Activate("ahk_id " . Work)
				Input.Click("Button2", Work) ;목록삭제
				Sleep, % this.Interval
				ControlSetText, Edit1, % StreamURL, % "ahk_id " . Work  ; 주소
				Sleep, % this.Interval
				ControlGetText, Holding, Edit1, % "ahk_id " . Work
				Sleep, % this.Interval
			}
			Input.Click(this.is64, Work)
		}

		Talk(ChatURL, ChatMethod)
		{
			if (ChatMethod != "Docking")
				try Run, % this.Parent.ChatMethod . " " . ChatURL
			else if (ChatMethod == "Docking") {
				ClipHistory 	:= Clipboard
				Clipboard 	:= ChatURL
				Input.Send("{F6 Down}{F6 Up}", this.Parent.Docking,, true)
				Input.Send("{Ctrl Down}v{Ctrl Up}", this.Parent.Docking,, false)
				Input.Send("{Enter Down}{Enter Up}", this.Parent.Docking,, false)
				Clipboard 	:= ClipHistory
			}
		}

		Repos()
		{
			WinGetPos, pX, pY, pW, pH, % "ahk_id " . this.Parent.PotPlayer["Hwnd"]
			Holding := ""
			while Holding != "다음 팟플레이어"
				WinGetTitle, Holding, % "ahk_id " . this.Parent.PotPlayer["Hwnd"]
			Sleep, % this.Interval * 5
			while Holding != "playlist.m3u8 - 다음 팟플레이어"
				WinGetTitle, Holding, % "ahk_id " . this.Parent.PotPlayer["Hwnd"]
			Sleep, % this.Interval * 5
			DllCall("MoveWindow", "Ptr", this.Parent.PotPlayer["Hwnd"], "Int", pX, "Int", pY, "Int", pW, "Int", pH, "Int", true)
		}

		DePrev(WinTitle, WinText)
		{
			if WinExist(WinTitle, WinText)
				WinClose, % WinTitle, % WinText
		}
	}
	
	class Thread extends Functor
	{
		__New(Bind) 
		{
			this.Bind := Bind
		}
		
		__Delete() 
		{
			this.Bind := ""
			this.Destroy()
		}
		
		Call() 
		{
			this.Bind.Call()
			if (this.Period < 0)
				this.Destroy()
		}
		
		Start(Period) 
		{
			this.Period := Period
			SetTimer, % this, % Period
		}
		
		Destroy() 
		{
			SetTimer, % this, Delete
		}
	}
	
	class Activate extends Functor
	{
		Call(Self, hWnd) 
		{
			WinActivate, % hWnd
			WinWaitActive, % hWnd
		}
	}
	
	class SetTop extends Functor
	{
		Call(Self, hWnd) 
		{
			WinSet, AlwaysOnTop, On, % hWnd
			WinSet, AlwaysOnTop, Off, % hWnd
		}
	}
	
	class WinFade extends Functor ;Credits, JoeDF
	{
		Call(Self, w := "", t := 128, i := 1, d := 5) 
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
	}
	
	class Hover extends Functor
	{
		Call(hWnd)
		{
			static Save := true

			MouseGetPos,,, OnWin
			if ( hWnd = OnWin ) && (Save = false) {
				Save := !Save
				LodaPlugin.WinFade("ahk_id " . hWnd, 255, 15)
			} else if ( hWnd != OnWin ) && (Save != false) {
				Save := !Save
				LodaPlugin.WinFade("ahk_id " . hWnd, 145, 5)
			}
		}
	}
	
	class Destruct extends Functor
	{
		Call(Self, hWnd, Parent) 
		{
			if !WinExist(hWnd)
				Parent.GuiClose()
		}
	}
	
	Class Download extends Functor ;Credit, Bruttosozialprodukt
	{
		Call(Self, UrlToFile, SaveFileAs) 
		{
			static WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			
			WebRequest.Open("HEAD", UrlToFile)
			WebRequest.Send()
			FinalSize := WebRequest.GetResponseHeader("Content-Length")
			Progress, H80, , 다운로드 중..., %UrlToFile%
			Progrs := new LodaPlugin.Thread(ObjBindMethod(this, "UpdateProgressBar", SaveFileAs))
			Progrs.Start(100)
			UrlDownloadToFile, % UrlToFile, % SaveFileAs
			Progress, Off
			Progrs.Destroy()
			this.Complete(SaveFileAs)
		}
		
		UpdateProgressBar(File) 
		{
			CurrentSize		:= FileOpen(File, "r").Length
			CurrentSizeTick		:= A_TickCount
			Speed			:= Round((CurrentSize/1024-LastSize/1024)/((CurrentSizeTick-LastSizeTick)/1000)) . " Kb/s"
			LastSizeTick		:= CurrentSizeTick
			LastSize		:= FileOpen(File, "r").Length
			PercentDone		:= Round(CurrentSize/FinalSize*100)
			Progress, %PercentDone%, %PercentDone%`% 완료, 다운로드 중...  (%Speed%), 다운로드 중 %SaveFileAs% (%PercentDone%`%)
		}
		
		Complete(File) 
		{
			try Run, % File, % A_ScriptDir
			ExitApp
		}
	}
	
	class Parser extends Functor
	{
		CheckSum() 
		{
			if ( jXon.parse.pVersion > pVersion ) {
				MsgBox, 262180, % pName, % jXon.parse.pVersion . " 버전이 존재해요`n최신 버전을 다운받을까요?"
				IfMsgBox, Yes
				{
					LodaPlugin.Download( jXon.parse.UpdatePath, "로다 플러그인 " . jXon.parse.pVersion )
				}
			}
		}
		
		Call(Self, Option := "New", MenuBind := "") 
		{
			static HTML := ComObjCreate("HTMLfile"), pooHash := ComObjCreate("Scripting.Dictionary")
			
			if (Option == "Refresh") {
				Gui, Menu
				for each, Item in ["영화:방송", "애니:방송", "예능:방송", "기타:방송"]
					try Menu, % Item, Delete,
				pooHash.RemoveAll()
			} else if (Option == "New") {
				this.CheckSum()
			}

			Cut 		:= jXon.parse.Until
			poo 		:= JSON.Get("http://poooo.ml/"), LiveHouseIn := "" ;TwitchPD := "", TwitchChannel := "", Twitch := ""
			LiveHouseIn 	:= SubStr(poo, 1, InStr(poo, Cut) - 1), poo := ""
			HTML.Open(), HTML.Write(LiveHouseIn), HTML.Close()
			
			pooHash.Item("영화:방송") := HTML.getElementsByClassName("livelist")[0].innerHTML
			pooHash.Item("애니:방송") := HTML.getElementsByClassName("livelist")[1].innerHTML
			pooHash.Item("예능:방송") := HTML.getElementsByClassName("livelist")[2].innerHTML
			pooHash.Item("기타:방송") := HTML.getElementsByClassName("livelist")[3].innerHTML
			
			for each in pooHash
			{
				HTML.Open()
				HTML.Write( pooHash.Item(each) )
				HTML.Close()
				
				while HTML.getElementsByClassName("deepblue")[A_Index-1].innerText
				{
					PD		:= HTML.getElementsByClassName("deepblue")[A_Index-1].innerText
					Banner		:= HTML.getElementsByClassName("ellipsis")[A_Index-1].innerText
					MenuName	:= each
					ItemName	:= PD . "`t" . Banner
					
					if (Option == "New") {
						__Noti.Mod("", "확인 중...`n" ItemName)
						Sleep, 50
					}
					
					try Menu, % MenuName, Add, % ItemName, % MenuBind
					try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\on.png",, 0
				}
				try Menu, MenuBar, Add, % each, % ":" . each
				try Menu, MenuBar, Icon, % each, % A_Temp . "\PD.png",, 0
			}
			
			if (Option == "Refresh") {
				Gui, Menu, MenuBar
			}
		}
	}
}
