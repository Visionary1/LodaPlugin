Class DaumPotPlayer
{
	Class Run extends Functor
	{
		static is64	:= InStr(A_ScriptName, "64") ? "64" : ""
		, isMini	:= InStr(A_ScriptName, "Mini") ? "Mini" : ""
		
		Call(Self)
		{
			this.UseStreamTimeShift()
			
			Try Run, % this.GetPath() . "\PotPlayer" . this.isMini . this.is64 . ".exe",,, TargetPID
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
			If !ErrorLevel
				Return PotPlayerPath
			Else {
				FileSelectFile, PotPlayerPath,, C:\, 팟플레이어 파일을 선택하세요, *.exe
				MsgBox, 4132, 로다 플러그인, %PotPlayerPath% `n`n팟플레이어가 맞습니까?
				IfMsgBox, No
					Return this.GetPath()
					
				Return PotPlayerPath
			}
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