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
#Include <DaumPotPlayer>
#Include <Entry>

Entry.As("User")
global Resizer 		:= DynaCall("MoveWindow", ["tiiiii", 1, 2, 3, 4, 5], _dHwnd := "", _dX := "", _dY := "", _dW := "", _dH := "", True)
global pVersion		:= "0.3.2"
global RsrcPath 	:= A_Temp . "\LodaPlugin\"
global jXon		:= JSON.Load("https://goo.gl/z0b7GM",, True)
global ParsePos 	:= {"PD": jXon.parse["Position_PD"]
			, "Title": jXon.parse["Position_Title"]
			, "TwitchPos": jXon.parse["Position_Twitch"]
			, "TwitchPD": jXon.parse["Position_TwitchPD"]}
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

Class LodaPlugin 
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
		this.Parser("New", this.Bound.PDMenu)
		this.Bound.OnMessage 	:= this.OnMessage.Bind(this)
		Buttons			:= new this.MenuButtons(this)
		Menus 			:= 
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
			]], ["다음팟 광고차단", Buttons.AdBlock.Bind(Buttons)]
			, 	["About", Buttons.About.Bind(Buttons)]
			]
		)
		/*
		If InStr(A_ScriptName, "개발자") {
			Menus := 
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
				]], ["다음팟 광고차단", Buttons.AdBlock.Bind(Buttons)]
				, 	["About", Buttons.About.Bind(Buttons)]
				]
			)
		} Else {
			Menus := 
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
		}
		*/
		this.Menus		:= this.CreateMenuBar(Menus)
		Menu, MenuBar, Add, % "설정", % ":" . this.Menus[1]
		this.MenuButtons.Icon("MenuBar", "설정", "setting")
		For Each, Item in {"채팅창 열기": "vote", "라이브하우스 주소": "then", "다음팟 광고차단": "off", "About": "info"}
			this.MenuButtons.Icon("Loda_0", Each, Item)
		For Each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
			this.MenuButtons.Icon(Item, Each, "off")
		For Each, Item in {"기본": "on", "주소2": "off", "주소3": "off", "주소4": "off"}
			this.MenuButtons.Icon("Loda_2", Each, Item)
		Gui, Menu, MenuBar
		
		WinEvents.Register(this.hPlugin, this)
		For Each, Item in [0x0047]
			OnMessage(Item, this.Bound.OnMessage)
		__Noti.Destroy()
		this.PotPlayer		:= DaumPotPlayer.Run()
		;this.ThreadID		:= DllCall("GetWindowThreadProcessId", "Ptr", this.PotPlayer["PID"]) ;PID 아니였어? ㅋㅋ
		this.ThreadID		:= DllCall("GetWindowThreadProcessId", "Ptr", this.PotPlayer["Hwnd"])
		this.HookAddr		:= RegisterCallback("HookProc", 0, 3)
		this.Event		:= SetWinEventHook(EVENT_OBJECT_DESTROY := 0x8001, EVENT_OBJECT_LOCATIONCHANGE := 0x800B, 0
		, this.HookAddr, this.PotPlayer["PID"], this.ThreadID, 0)
		WinGetPos, pX, pY,,, % "ahk_id " . this.PotPlayer["Hwnd"]
		Gui, Show, % "x" pX " y" pY - 71 " w" 430 "h " 15, % "로다 플러그인 " . pVersion
		Win.Activate("ahk_id" . this.hPlugin)
		
		this.Bound.Hover.Start(100)
		this.Bound.Parser.Start( 10 * 60 * 1000 )
	}
	
	OnMessage(wParam, lParam, Msg, hWnd)
	{
		static WM_WINDOWPOSCHANGED := 0x0047
		
		If (Msg = WM_WINDOWPOSCHANGED) && !WinActive("가가라이브 채팅") && !WinActive("ahk_id " . this.PotPlayer["Hwnd"]) {
			Win.Top("ahk_id " . this.PotPlayer["Hwnd"])
			WinGetPos, iX, iY,,, % "ahk_id " . this.hPlugin
			WinMove, % "ahk_id " . this.PotPlayer["Hwnd"],, % iX, % iY + 66
		}
	}
	
	GuiClose()
	{
		Critical
		If FileExist(RsrcPath . "hosts") {
			FileRead, Backup, % RsrcPath . "hosts"
			FileOpen("C:\Windows\System32\Drivers\etc\hosts", "w", "UTF-8").Write(Backup).Close()
		}
		__GaGa.__Delete(), this.Bound.Hover.Destroy(), this.Bound.Parser.Destroy()
		TVClose(this.hPlugin, 40, 100)
		Try WinKill, % "ahk_id " . this.PotPlayer["Hwnd"]
		Try WinKill, % "ahk_id " . this.Docking
		For Each, Item in [0x0047]
			OnMessage(Item, this.Bound.OnMessage, 0)
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
		For Each, Item in Menu
		{
			Ref := Item[2]
			If IsObject(Ref) && Ref._NewEnum() {
				SubMenus := this.CreateMenuBar(Ref)
				Menus.Push(SubMenus*)
				Ref := ":" . SubMenus[1]
			}
			Try Menu, % Menus[1], Add, % Item[1], % Ref
		}
		
		Return Menus
	}
	
	Class PDMenu extends Functor
	{
		Call(Self, ItemName, ItemPos, MenuName) 
		{
			PDName := SubStr(SubStr(ItemName, 1, InStr(ItemName, "`t")), 1, -1)

			If (MenuName == "TwitchMenu")
				this.Twitch(PDName)
			Else If (MenuName != "TwitchMenu") {
				_PDName := jXon[PDName]

				If !(_PDName) {
					new MsgBox("로다 플러그인", "아직 방송주소가 서버에 추가되지 않았습니다"
					, "추가되기 전까지는 수동으로 입장해주세요`n`n금방 추가됩니다!", "확인", "YELLOW", Self.PotPlayer["Hwnd"])
					Return
				}

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
			this.StreamURL	:= "http://" . DefaultServer . "/" . jXon[PDName] . "/video/playlist.m3u8"
			this.ChatURL	:= "https://livehouse.in/en/channel/" . jXon[PDName] . "/chatroom"
		}
		
		Streamup(PDName, Self)
		{
			this.StreamURL 	:= jXon[PDName]["m3u8"]
			this.ChatURL 	:= jXon[PDName]["chat"]
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
	
	Class MenuButtons ;ty, GeekDude!
	{
		__New(Parent) 
		{
			this.Parent := Parent
		}
		
		IE(ItemName, ItemPos, MenuName) 
		{
			For Each, Item in {"파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, Each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "iexplore.exe"
		}
		
		FireFox(ItemName, ItemPos, MenuName)
		{
			For Each, Item in {"익스플로러 사용": "Loda_1", "크롬 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, Each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "firefox.exe"
		}
		
		Chrome(ItemName, ItemPos, MenuName) 
		{
			For Each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "채팅창 도킹": "Loda_1"}
				this.Icon(Item, Each, "off")
			this.Icon(MenuName, ItemName, "on")
			
			this.Parent.Docking	:= ""
			this.Parent.ChatMethod	:= "chrome.exe"
		}
		
		Docking(ItemName, ItemPos, MenuName)
		{
			Docker := new MsgBox("로다 플러그인", "채팅창을 팟플레이어와 함께 움직이기", "확인' 후 도킹할 윈도우를 우클릭하세요!", "확인|취소", "GREEN", this.Parent.PotPlayer["Hwnd"])
			If (Docker == "확인") {
				While !GetKeyState("RButton", "P") {
					MouseGetPos, , , id, control
					WinGetTitle, title, ahk_id %id%
					ToolTip, %title%`n`n이 윈도우를 도킹하려면 우클릭 하세요!
					Sleep, 100
				}
				ToolTip,
				MsgBox, 262180, Dock, %title%`n`n윈도우를 도킹할까요?
				IfMsgBox, Yes
				{
					For Each, Item in {"익스플로러 사용": "Loda_1", "파이어폭스 사용": "Loda_1", "크롬 사용": "Loda_1"}
						this.Icon(Item, Each, "off")
					this.Icon(MenuName, ItemName, "on")
					
					this.Parent.Docking	:= id
					this.Parent.ChatMethod	:= "Docking"
				}
			}
		}
		
		ChangeServer(ItemName)
		{
			If (ItemName == "기본")
				this.Parent.ChatServer := jXon.parse.Server1
			Else If (ItemName == "주소2")
				this.Parent.ChatServer := jXon.parse.Server2 ;220.130.187.73"
			Else If (ItemName == "주소3")
				this.Parent.ChatServer := jXon.parse.Server3
			Else If (ItemName == "주소4")
				this.Parent.ChatServer := jXon.parse.Server4 ;106.187.40.237"
			For each, Item in {"기본": "Loda_2", "주소2": "Loda_2", "주소3": "Loda_2", "주소4": "Loda_2"}
				this.Icon(Item, each, "off")
			this.Icon("Loda_2", ItemName, "on")
		}

		AdBlock(ItemName, ItemPos, MenuName)
		{
			static Toggle := False

			If !(Toggle) {
				Tick := new MsgBox("로다 플러그인", "팟플레이어 광고 차단하기"
						, "마술은 제가 두 달 정도를 계속해서 배운것 같아요", "확인|취소", "BLUE", this.Parent.PotPlayer["Hwnd"])

				If (Tick == "취소")
					Return

				Host := FileOpen("C:\Windows\System32\Drivers\etc\hosts", "rw", "UTF-8")

				If !FileExist(RsrcPath . "hosts")
					FileOpen(RsrcPath . "hosts", "w", "UTF-8").Write( Host.Read() ).Close()

				BlockList := JSON.Get("https://goo.gl/DoLcgj")
				Host.Seek(0, 2)
				Host.Write("`n" . BlockList).Close()
			}

			Else If (Toggle) {
				Host := FileOpen("C:\Windows\System32\Drivers\etc\hosts", "w", "UTF-8")
				Backup := FileOpen(RsrcPath . "hosts", "r", "UTF-8").Read()
				Host.Write(Backup).Close()
			}

			Toggle := !Toggle
			this.Icon(MenuName, ItemName, (Toggle ? "on" : "off"))
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
			Gui Add, Picture, x10 y10, % RsrcPath . "LodaPlugin.png"
			Gui Add, Text, x70 y6 w210, 로다 플러그인
			Gui Font
			Gui Add, Text, x214 y22 Disabled, % "v" . pVersion
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
		
		Class Icon extends Functor
		{
			Call(Self, MenuName, ItemName, ico)
			{
				Try Menu, % MenuName, Icon, % ItemName, % RsrcPath . ico . ".png",, 0
				Sleep, 50
			}
		}
	}
	
	Class Transition extends Functor
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
			If !(this.Parent.ChatMethod) {
				Why := new MsgBox("로다 플러그인", "채팅창 설정이 되지 않았어요"
				, "지금 설정은 채팅창을 자동으로 열지 않습니다`n`n방송을 입장할까요?`n`n채팅창을 열려면 취소 후 설정-채팅창 열기를 설정하세요"
				, "예|취소", "YELLOW", this.Parent.PotPlayer["Hwnd"])
				If (Why == "취소")
					Return
			}
			
			this.DePrev("ahk_class #32770", "주소 열기")
			this.PotPlayer(StreamURL)
			this.Talk(ChatURL, ChatMethod)
			If (this.isMini)
				this.Repos()
		}
		
		PotPlayer(StreamURL)
		{
			Input.Send("{Ctrl Down}u{Ctrl Up}", this.Parent.PotPlayer["Hwnd"],, True), Work := ""
			While !Work
				Work := WinActive("ahk_class #32770", "주소 열기")
			WinSet, Transparent, 0, % "ahk_id " . Work
			
			Holding := ""
			While !Holding {
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
			If (ChatMethod != "Docking") && !(ChatMethod == "")
				Try Run, % this.Parent.ChatMethod . " " . ChatURL
			Else If (ChatMethod == "Docking") {
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
			For Key, Value in ["다음 팟플레이어", "playlist.m3u8 - 다음 팟플레이어"]
			{
				Holding := ""
				While, Holding != Value
					WinGetTitle, Holding, % "ahk_id " . this.Parent.PotPlayer["Hwnd"]
				Sleep, % this.Interval * 5
			}
			Resizer.(this.Parent.PotPlayer["Hwnd"], pX, pY, pW, pH)
		}
		
		DePrev(WinTitle, WinText)
		{
			If WinExist(WinTitle, WinText)
				WinKill, % WinTitle, % WinText
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
			MsgBox, 4160, 로다 플러그인, 업데이트 파일을 내려받았습니다`n`n폴더내의 %File% 의 압축을 풀고 새로 실행하세요!
			ExitApp
		}
	}
	
	Class Parser extends Functor
	{
		Call(Self, Option := "New", MenuBind := "")
		{
			If (Option == "Refresh") {
				Gui, Menu
				For each, Item in ["영화:방송", "애니:방송", "예능:방송", "기타:방송", "TwitchMenu"]
					Try Menu, % Item, Delete,
			} Else If (Option == "New") {
				this.isLatest()
			}
			
			poo := this.DOM("http://poooo.ml/")
			this.LiveHouseIn(poo, MenuBind)
			this.Twitch(poo, MenuBind)
			poo.Quit()
			Try WinKill, % "ahk_id" . poo.Hwnd ;Kill remaining proc
			poo := ""
			
			If (Option == "Refresh") {
				Gui, Menu, MenuBar
			}
		}
		
		DOM(url)
		{
			Obj := ComObjCreate("InternetExplorer.Application")
			Obj.Visible := False
			Obj.Navigate(url)
			While Obj.readyState != 4 || Obj.document.readyState != "complete"
				Sleep, 100
			
			Return Obj
		}
		
		isLatest() 
		{
			If ( jXon.parse.pVersion > pVersion ) {
				Result := new MsgBox("로다 플러그인", "최신 " jXon.parse.pVersion " 버전이 존재합니다", "업데이트 버전을 내려받을까요?", "예|아니오", "BLUE", __Noti.hNotify)
				If (Result == "예") {
					LodaPlugin.Download( jXon.parse.UpdatePath, "로다 플러그인 " . jXon.parse.pVersion . ".zip" )
				}
			}
		}
		
		LiveHouseIn(poo, MenuBind)
		{
			static Selector := {1: "영화:방송", 2: "애니:방송", 3: "예능:방송", 4: "기타:방송"}
			
			Packet := {}
			Loop, 4
				Packet[A_Index] := poo.document.getElementsByClassName("livelist")[A_Index-1]
			
			For Key, Value in Packet
			{
				MenuName 	:= Selector[Key]
				Now 		:= Packet[A_Index]
				
				While Now.getElementsByClassName(ParsePos["PD"])[A_Index-1].innerText
				{
					PD 		:= Now.getElementsByClassName(ParsePos["PD"])[A_Index-1].innerText
					Title 		:= Now.getElementsByClassName(ParsePos["Title"])[A_Index-1].innerText
					ItemName 	:= PD . "`t" . Title
					
					If !(__Noti == "") {
						__Noti.Mod("", "확인 중...`n" ItemName)
						Sleep, 50
					}
					
					Try Menu, % MenuName, Add, % ItemName, % MenuBind
					LodaPlugin.MenuButtons.Icon(MenuName, ItemName, "on")
				}
				
				Try Menu, MenuBar, Add, % MenuName, % ":" . MenuName
				LodaPlugin.MenuButtons.Icon("MenuBar", MenuName, "PD")
			}
		}
		
		Twitch(poo, MenuBind)
		{
			TwitchPDCount := 0, TwitchPD := "", TwitchChannel := ""
			
			HTML := poo.document.getElementsByClassName(ParsePos["TwitchPos"])[0]
			
			while HTML.getElementsByClassName(ParsePos["TwitchPD"])[A_Index-1].innerText {
				Name_Red := HTML.getElementsByClassName("red")[A_Index-1].innerText 
				Name_Blue := HTML.getElementsByClassName(ParsePos["TwitchPD"])[A_Index-1].innerText
				TwitchPD .= Name_Red . Name_Blue "`n"
				TwitchPDCount := A_Index
			}
			
			Loop, % TwitchPDCount * 2 {
				If !( HTML.GetElementsByTagName("a")[A_Index-1].title )
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
				Try Menu, TwitchMenu, Add, % ItemName, % MenuBind
				LodaPlugin.MenuButtons.Icon("TwitchMenu", ItemName, "on")
			}
			
			Try Menu, MenuBar, Add, 트위치:방송, % ":TwitchMenu"
			LodaPlugin.MenuButtons.Icon("MenuBar", "트위치:방송", "Twitch")
		}
	}
}