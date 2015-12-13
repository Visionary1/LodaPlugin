#Include <Functor>
#Include <CBrowser>
#Include <CleanNotify>
#Include <CMsgBox>
#Include <JSON>
#Include <CInput>
#Include <CWinEvents>
#Include <Win>
#Include <SetWinEventHook>
#Include <TVClose>
#Include <Thread>
#Include <Install>
#Include <Entry>

Entry.As("User")
global Resizer 		:= DynaCall("MoveWindow", ["tiiiii", 1, 2, 3, 4, 5], _dHwnd := "", _dX := "", _dY := "", _dW := "", _dH := "", True)
global pVersion		:= "0.1"
global jXon		:= JSON.Load("https://goo.gl/7KhJiP",, True)
global __Noti 		:= new CleanNotify("로다 플러그인", "팟플레이어 애드온`n" , (A_ScreenWidth / 3) + 10, (A_ScreenHeight / 6) - 10, "vc hc", "P")
global __Main		:= new LodaPlugin()
global __GaGa 		:= new Browser("가가라이브 채팅", "http://goo.gl/zlBZPF")
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
	__New()
	{
		Gui, new, -DPIScale -Resize +ToolWindow -SysMenu +LastFound
		this.hPlugin		:= WinExist()
		this.Bound		:= []
		this.Bound.Transition	:= new this.Transition(this)
		this.Bound.PDMenu	:= ObjBindMethod(this.PDMenu, this)
		this.Bound.Hover	:= new Thread( ObjBindMethod(Win, "Hover", this.hPlugin) )
		this.Bound.Parser	:= new Thread( ObjBindMethod(this.Parser, "", "", "Refresh", this.Bound.PDMenu) )
		this.Parser("New", this.Bound.PDMenu), __Noti := ""
		this.Bound.OnMessage 	:= this.OnMessage.Bind(this)
		Buttons			:= new this.MenuButtons(this)
		Menus			:=
		(Join
		[
			["채팅창 열기", [
				["익스플로러 사용", Buttons.IE.Bind(Buttons)],
				["파이어폭스 사용", Buttons.FireFox.Bind(Buttons)],
				["크롬 사용", Buttons.Chrome.Bind(Buttons)],
				["채팅창 도킹", Buttons.Docking.Bind(Buttons)]
			]], ["라이브하우스 주소", [
				["기본", Buttons.ChangeServer.Bind(Buttons)],
				["주소2", Buttons.ChangeServer.Bind(Buttons)],
				["주소3", Buttons.ChangeServer.Bind(Buttons)],
				["주소4", Buttons.ChangeServer.Bind(Buttons)]
			]], ["About", Buttons.About.Bind(Buttons)]
		]
		)
		this.Menus	:= this.CreateMenuBar(Menus)
		this.PotPlayer	:= this.DaumPotPlayer.Run()
		this.ThreadID	:= DllCall("GetWindowThreadProcessId", "Ptr", this.PotPlayer["PID"])
		this.HookAddr	:= RegisterCallback("HookProc", 0, 3)
		this.Event	:= SetWinEventHook(EVENT_OBJECT_DESTROY := 0x8001, EVENT_OBJECT_LOCATIONCHANGE := 0x800B, 0
		, this.HookAddr, this.PotPlayer["PID"], this.ThreadID, 0)
		
		Menu, MenuBar, Add, % "설정", % ":" . this.Menus[1]
		this.MenuButtons.Icon("MenuBar", "설정", "setting")
		for each, Item in {"채팅창 열기": "vote", "라이브하우스 주소": "then", "About": "info"}
			this.MenuButtons.Icon("Loda_0", each, Item)
		for each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
			this.MenuButtons.Icon(Item, each, "off")
		for each, Item in {"기본": "on", "주소2": "off", "주소3": "off", "주소4": "off"}
			this.MenuButtons.Icon("Loda_2", each, Item)
		Gui, Menu, MenuBar
		
		WinEvents.Register(this.hPlugin, this)
		for each, Item in [0x0047, 0x200, 0x2A2]
			OnMessage(Item, this.Bound.OnMessage)
		WinGetPos, pX, pY,,, % "ahk_id " . this.PotPlayer["Hwnd"]
		Gui, Show, % "x" pX " y" pY - 71 " w" 430 "h " 15, % "로다 플러그인 " . pVersion
		
		this.Bound.Hover.Start(100)
		this.Bound.Parser.Start( 60000 * 10 * 2 )
	}
	
	__Delete() 
	{
		this.GuiClose()
	}
	
	OnMessage(wParam, lParam, Msg, hWnd) 
	{
		static WM_WINDOWPOSCHANGED := 0x0047
		
		if (Msg = WM_WINDOWPOSCHANGED) && !WinActive("가가라이브 채팅") && !WinActive("ahk_id " . this.PotPlayer["Hwnd"]) {
			Win.Top("ahk_id " . this.PotPlayer["Hwnd"])
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
				Menus.Push(SubMenus*)
				Ref := ":" . SubMenus[1]
			}
			Menu, % Menus[1], Add, % Item[1], % Ref
		}

		Return Menus
	}

	class PDMenu extends Functor
	{
		Call(Self, ItemName, ItemPos, MenuName) 
		{
			PDName := SubStr(SubStr(ItemName, 1, InStr(ItemName, "`t")), 1, -1)
			if (MenuName == "TwitchMenu")
				this.Twitch(PDName)
			else if (MenuName != "TwitchMenu") {
				_PDName := jXon.LiveHouseIn[PDName]
				If _PDName is not Integer
					this.Streamup(PDName, Self)
				Else
					this.LiveHouseIn(PDName, Self)
			}

			Return Self.Bound.Transition(this.StreamURL, this.ChatURL, Self.ChatMethod)
		}

		LiveHouseIn(PDName, Self)
		{
			DefaultServer 	:= ( Self.ChatServer ? Self.ChatServer : jXon.parse.Server1 )
			this.StreamURL	:= "http://" . DefaultServer . "/" . jXon.LiveHouseIn[PDName] . "/video/playlist.m3u8"
			this.ChatURL	:= "https://livehouse.in/en/channel/" . jXon.LiveHouseIn[PDName] . "/chatroom"
		}

		Streamup(PDName, Self)
		{
			PDName 	:= jXon.LiveHouseIn[PDName]
			If (PDName = "rongsports")
				this.StreamURL 	:= "https://video-cdn.streamup.com/app/rongsportss-channel/playlist.m3u8"
			Else
				this.StreamURL 	:= "https://video-cdn.streamup.com/app/" . PDName . "s-stream/playlist.m3u8"
			this.ChatURL 		:= "https://streamup.com/" . PDName . "/embeds/chatonly"
		}

		Twitch(PDName)
		{
			PDName 		:= ( jXon.Twitch[PDName] ? jXon.Twitch[PDName] : PDName )
			api 		:= "http://api.twitch.tv/api/channels/" . PDName . "/access_token"
			RequestToken 	:= JSON.Load(api,,True)
			tokenVal 	:= RequestToken.token
			sigVal 		:= RequestToken.sig
			dummy	 	= 
			(LTrim Join
			http://usher.justin.tv/api/channel/hls/%PDName%.m3u8?
			token=%tokenVal%
			&sig=%sigVal%
			)
			this.StreamURL 	:= dummy
			this.ChatURL 	:= "http://www.twitch.tv/" . PDName . "/chat?popout="
		}
	}
	
	/*
	PDMenu(ItemName, ItemPos, MenuName) 
	{
		static DefaultServer := "hi.cdn.livehouse.in"

		PDName	:= SubStr(SubStr(ItemName, 1, InStr(ItemName, "`t")), 1, -1)
		StreamURL	:= "http://" . DefaultServer . "/" . jXon[PDName] . "/video/playlist.m3u8"
		ChatURL	:= "https://livehouse.in/en/channel/" . jXon[PDName] . "/chatroom"
		Return		this.Bound.Transition(StreamURL, ChatURL, this.ChatMethod)
	}
	*/

	class MenuButtons ;ty, GeekDude!
	{
		__New(Parent) 
		{
			this.Parent := Parent
		}
		
		IE(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "iexplore.exe"
		}
		
		FireFox(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"익스플로러 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "firefox.exe"
		}
		
		Chrome(ItemName, ItemPos, MenuName) 
		{
			for each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "chrome.exe"
		}
		
		Docking(ItemName, ItemPos, MenuName) 
		{
			Docker := new MsgBox("로다 플러그인", "채팅창을 팟플레이어와 함께 움직이기", "확인' 후 도킹할 윈도우를 우클릭하세요!", "확인|취소", "GREEN", this.Parent.PotPlayer["Hwnd"])
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
						this.Icon(Item, each, "off")
					this.Icon(MenuName, ItemName, "on")
					
					this.Parent.Docking	:= id
					this.Parent.ChatMethod	:= "Docking"
				}
			}
		}

		ChangeServer(ItemName)
		{
			if (ItemName == "기본")
				this.Parent.ChatServer := jXon.parse.Server1
			else if (ItemName == "주소2")
				this.Parent.ChatServer := jXon.parse.Server2 ;220.130.187.73"
			else if (ItemName == "주소3")
				this.Parent.ChatServer := jXon.parse.Server3
			else if (ItemName == "주소4")
				this.Parent.ChatServer := jXon.parse.Server4 ;106.187.40.237"
			for each, Item in {"기본": "Loda_2", "주소2": "Loda_2", "주소3": "Loda_2", "주소4": "Loda_2"}
				this.Icon(Item, each, "off")
			this.Icon("Loda_2", ItemName, "on")
		}

		About()
		{
			__AboutText = 
			(
			팟플레이어 애드온


			Credits <a href="http://goo.gl/nEVrqs">공대생</a>, <a href="https://goo.gl/nCb07h">RONGSPORTS</a>
			)
			Gui About: New, % "LabelAbout AlwaysOnTop -MinimizeBox Owner" . this.Parent.PotPlayer["Hwnd"]
			Gui Color, White
			Gui Font, c00ADEF s16 W700 Q4, Segoe UI
			Gui Add, Picture, x10 y10, % A_Temp . "\LodaPlugin\LodaPlugin.png"
			Gui Add, Text, x70 y6 w210, 로다 플러그인
			Gui Font
			Gui Add, Text, x214 y22 Disabled, % "v0.1"
			Gui Add, Link, x71 y45 w210, % __AboutText
			Gui Add, Link, x16 y120, <a href="http://goo.gl/Weawli">건의 && 버그리포트</a>
			Gui Add, Button, gAboutClose x198 y112 w75 h23 Default, 닫기
			Gui Show, w285 h150, About
			ControlFocus Button1, About
			Return

			AboutEscape:
			AboutClose:
			Gui About: Destroy
			Return
		}

		class Icon extends Functor
		{
			Call(Self, MenuName, ItemName, ico)
			{
				try Menu, % MenuName, Icon, % ItemName, % A_Temp . "\LodaPlugin\" . ico . ".png",, 0
			}
		}

	}
	
	class DaumPotPlayer
	{
		class Run extends Functor
		{
			static is64	:= InStr(A_ScriptName, "64") ? "64" : ""
			, isMini	:= InStr(A_ScriptName, "Mini") ? "Mini" : ""

			Call(Self)
			{
				this.UseStreamTimeShift()

				try Run, % this.GetPath() . "\PotPlayer" . this.isMini . this.is64 . ".exe",,, TargetPID
				catch {
					MsgBox, 262192, 이런!, 팟플레이어가 설치되지 않은 것 같아요`n설치후에 다시 실행해주세요!, 5
					ExitApp
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
		static Interval := 30
		, isMini 	:= InStr(A_ScriptName, "Mini") ? True : False
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
			Input.Send("{Ctrl Down}u{Ctrl Up}", this.Parent.PotPlayer["Hwnd"],, True), Work := ""
			while !Work
				Work := WinActive("ahk_class #32770", "주소 열기")
			WinSet, Transparent, 0, % "ahk_id " . Work

			Holding := ""
			while !Holding {
				Win.Activate("ahk_id " . Work)
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
			if (ChatMethod != "Docking") && !(ChatMethod == "")
				try Run, % this.Parent.ChatMethod . " " . ChatURL
			else if (ChatMethod == "Docking") {
				Win.Activate("ahk_id " . this.Parent.Docking)
				ClipHistory 	:= Clipboard
				Clipboard 	:= ChatURL
				Input.Send("{F6 Down}{F6 Up}", this.Parent.Docking,, True)
				Input.Send("{Ctrl Down}v{Ctrl Up}", this.Parent.Docking,, False)
				Input.Send("{Enter Down}{Enter Up}", this.Parent.Docking,, False)
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
			Resizer.(this.Parent.PotPlayer["Hwnd"], pX, pY, pW, pH)
		}

		DePrev(WinTitle, WinText)
		{
			if WinExist(WinTitle, WinText)
				WinClose, % WinTitle, % WinText
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
			Progrs := new Thread(ObjBindMethod(this, "UpdateProgressBar", SaveFileAs))
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
		static HTML := ComObjCreate("HTMLfile"), pooHash := ComObjCreate("Scripting.Dictionary")
		
		Call(Self, Option := "New", MenuBind := "") 
		{
			if (Option == "Refresh") {
				Gui, Menu
				for each, Item in ["영화:방송", "애니:방송", "예능:방송", "기타:방송", "TwitchMenu"]
					try Menu, % Item, Delete,
				this.pooHash.RemoveAll()
				} else if (Option == "New") {
					this.isLatest()
				}

			poo := JSON.Get("http://poooo.ml/")
			this.LiveHouseIn(poo, MenuBind)
			this.Twitch(poo, MenuBind)
			poo := ""

			if (Option == "Refresh") {
				Gui, Menu, MenuBar
			}
		}

		isLatest() 
		{
			if ( jXon.parse.pVersion > pVersion ) {
				Result := new MsgBox("로다 플러그인", "최신 " jXon.parse.pVersion " 버전이 존재합니다", "업데이트 버전을 내려받을까요?", "예|아니오", "BLUE", __Noti.hNotify)
				if (Result == "예") {
					LodaPlugin.Download( jXon.parse.UpdatePath, "로다 플러그인 " . jXon.parse.pVersion . ".zip" )
				}
			}
		}

		LiveHouseIn(poo, MenuBind)
		{
			pooHash 	:= this.pooHash
			HTML 		:= this.HTML
			Cut 		:= jXon.parse.Until
			LiveHouseIn 	:= SubStr(poo, 1, InStr(poo, Cut) - 1)
			HTML.Open(), HTML.Write(LiveHouseIn), HTML.Close()

			For each, Value in ["영화:방송", "애니:방송", "예능:방송", "기타:방송"]
			{
				pooHash.Item(Value) := HTML.getElementsByClassName("livelist")[A_Index-1].innerHTML
				Sleep, 100
			}

			For each in pooHash
			{
				HTML.Open()
				HTML.Write( pooHash.Item(each) )
				HTML.Close()

				while HTML.getElementsByClassName("deepblue pull-left")[A_Index-1].innerText
				{
					PD		:= HTML.getElementsByClassName("deepblue pull-left")[A_Index-1].innerText
					Banner		:= HTML.getElementsByClassName("ellipsis")[A_Index-1].innerText
					MenuName	:= each
					ItemName	:= PD . "`t" . Banner

					if !(__Noti == "") {
						__Noti.Mod("", "확인 중...`n" ItemName)
						Sleep, 50
					}

					try Menu, % MenuName, Add, % ItemName, % MenuBind
					LodaPlugin.MenuButtons.Icon(MenuName, ItemName, "on")
				}

				try Menu, MenuBar, Add, % each, % ":" . each
				LodaPlugin.MenuButtons.Icon("MenuBar", each, "PD")
			}
		}

		Twitch(poo, MenuBind)
		{
			TwitchPDCount := 0, TwitchPD := "", TwitchChannel := ""
			Cut1 := jXon.parse.Cut1
			Cut2 := jXon.parse.Cut2
			HTML := this.HTML

			Twitch := SubStr(poo, InStr(poo, Cut1))
			Twitch := SubStr(Twitch, 1, InStr(Twitch, Cut2) - 1)
			HTML.Open(), HTML.Write(Twitch), HTML.Close()

			while HTML.getElementsByClassName("deepblue")[A_Index-1].innerText {
				Name_Red := HTML.getElementsByClassName("red")[A_Index-1].innerText 
				Name_Blue := HTML.getElementsByClassName("deepblue")[A_Index-1].innerText
				TwitchPD .= Name_Red . Name_Blue "`n"
				TwitchPDCount := A_Index
			}

			Loop, % TwitchPDCount * 2 {
				if !( HTML.GetElementsByTagName("a")[A_Index-1].title )
					continue
				TwitchChannel .= HTML.GetElementsByTagName("a")[A_Index-1].title "`n" ; 트위치 방송명
			}

			TwitchPDCount := 0
			Loop, Parse, TwitchPD, `n, `r
				PDName%A_Index% := A_LoopField

			Loop, Parse, TwitchChannel, `n, `r 
			{
				ChannelName%A_Index% := A_LoopField
				TwitchPDCount := A_Index-1
			}

			Loop, % TwitchPDCount
			{
				PD 		:= PDName%A_Index%
				Banner 		:= ChannelName%A_index%
				ItemName 	:= PD . "`t" . Banner
				try Menu, TwitchMenu, Add, % ItemName, % MenuBind
				LodaPlugin.MenuButtons.Icon("TwitchMenu", ItemName, "on")
			}

			try Menu, MenuBar, Add, 트위치:방송, % ":TwitchMenu"
			LodaPlugin.MenuButtons.Icon("MenuBar", "트위치:방송", "Twitch")
		}
	}
}