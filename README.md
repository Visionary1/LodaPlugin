# Loda plugin 

팟플레이어의 상단에 다른 플랫폼의 방송을 보여주는 메뉴를 추가하고

이를 클릭해 타 플랫폼의 방송을 팟플레이어로 시청할 수 있습니다

그동안 팟플레이어로 스트리밍기능을 이용하려면 

방송주소복사- Ctrl+U 주소창 열고 붙여넣기

채팅방 주소 복사 - 브라우저에서 붙여넣기를 **직접** 해야 했습니다

로다 플러그인은 이 과정을 **자동**으로 합니다

* Currently Supporting
	* [트위치 *twitch.tv*](http://www.twitch.tv/)
	* [스트림업 *streamup.com*](https://streamup.com/)
	* [라이브하우스인 *livehouse.in*](https://livehouse.in/en)


## Downloads
- [GitHub](https://github.com/Visionary1/LodaPlugin/raw/master/Package/0.1.1/%EB%A1%9C%EB%8B%A4%20%ED%94%8C%EB%9F%AC%EA%B7%B8%EC%9D%B8.zip) 에서 내려받기
- [블로그](http://knowledgeisfree.tistory.com/) 에서 내려받기

#### Preference General

- 팟플레이어 **64**비트를 사용하기
	- 파일명에 '**64**' 를 추가하세요 ex) '로다 플러그인**64**.exe'
- 팟플레이어 **재생전용(Mini)** 를 사용하기
	- 파일명에 '**Mini**' 를 추가하세요 ex) '로다 플러그인64 **Mini**.exe'

## Credits
- [공대생](http://poooo.ml/)
- [RONGSPORTS](https://livehouse.in/channel/329050)

## Documentation

LodaPlugin is a free, open-source add-on software for potplayer, written in [AutoHotkey](http://ahkscript.org/)

Feel free to fork, modify the pre-build [source-code](src) under the [MIT License](http://mit-license.org/)

Below are the list of codes that are referenced, used as libraries

- [AutoHotkey](http://ahkscript.org/)
	- [JSON()](https://autohotkey.com/boards/viewtopic.php?f=6&t=627)
	- [WinEvents()](https://www.autohotkey.com/boards/viewtopic.php?t=6113)
	- [Dock()](https://autohotkey.com/boards/viewtopic.php?t=9230&p=51279)
	- [WinEventHook()](https://autohotkey.com/board/topic/32662-tool-wineventhook-messages/)

- MSDN
	- [WinEventProc callback](https://msdn.microsoft.com/ko-kr/library/windows/desktop/dd373885%28v=vs.85%29.aspx)
	- [WINEVENTPROC func pointer](https://msdn.microsoft.com/ko-kr/library/windows/desktop/dd373882%28v=vs.85%29.aspx)

- C++
	- [Hook](http://stackoverflow.com/questions/20732086/setwineventhook-with-createprocess-c)
	- [CallBack](http://www.devpia.com/Maeul/Contents/Detail.aspx?BoardID=51&MAEULNO=20&no=7338&page=48)

## License
[MIT License](http://mit-license.org/)