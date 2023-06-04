Attach:
    global objShell
    global hCon
    global cPid
        
    ;;adb방식 컨트롤 하는 cmd 생성
    DetectHiddenWindows, on ;숨겨진 윈도우 조작 가능
    Run, %comspec% /k ,,hide UseErrorLevel , cPid ; hide ;추가하면 숨겨짐
    WinWait, ahk_pid %cPid%,, 10
    ;WinHide, ahk_pid %cPid% ;나중에 숨기기
    DllCall("AttachConsole","uint",cPid)
    hCon:=DllCall("CreateFile","str","CONOUT$","uint",0xC0000000,"uint",7,"uint",0,"uint",3,"uint",0,"uint",0)
    objShell := ComObjCreate("WScript.Shell")
return

GuiClose:
Clean_up: ;매크로 끌때
    SaveOption()
    ;DllCall("DeleteObject", Ptr,g_hBitmap) ;파일쓰기 없이 adb서치용 hBitmap 비움.
    DllCall("CloseHandle", "uint", hCon) ;;cmd 생성
    DllCall("FreeConsole") ;cmd 생성
    Process, Close, %cPid% ;cmd 생성
    Gdip_Shutdown(gdipToken) ;gdip 끄기
    ExitApp
return


Reset:
Reload
return

Pause:
Pause,,1
return


; 설정불러오기:
; {
   
;     GuiControlGet, 퀘스트설정DDL, 1:
;     ; global 퀘스트설정DDL
;     ;gui := "q:"
; 	section := "QUEST_" 퀘스트설정DDL	
; 	loop, 3
;     {
;         IniRead, 타겟%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 타겟%a_index%    
;     }

; 	loop,3
;     {
        
;         ii := a_index
;         loop, 3 {
;             IniRead, 보구%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 보구%ii%라%a_index%
;         }
;     }
;     ;addlog(" ㅊㅊㅊ" 보구1라1)
; 	loop,3
;     {
;         ii := a_index
;         loop, 3 {
;             IniRead, 마스터%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 마스터%ii%라%a_index%
;         }
; 	}
; 	loop,3
;     {
; 		ii := a_index
; 		loop, 9 {
;             IniRead, 스킬%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 스킬%ii%라%a_index%
;         }
; 	}
;     loop,3
;     {
; 		ii := a_index
; 		loop, 2 {
;             IniRead, 오더%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 오더%ii%라%a_index%
;         }
; 	}
;     loop,3
;     {
; 		ii := a_index
; 		loop, 3 {
;             IniRead, 오첸스킬%ii%라%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 오첸스킬%ii%라%a_index%
;         }
; 	}
;     loop, 3
;     {
;         ;
;         IniRead, 자동스킬%a_index%, %ConfigFile%, QUEST_%퀘스트설정DDL%, 자동스킬%a_index%      
; 		;IniRead("타겟" a_index, gui, section, cmd)
;     }
;     ;global g카드순위
; 	IniRead, 카드순위, %ConfigFile%, QUEST_%퀘스트설정DDL%, 카드순위, BE>AE>QE>BN>AN>QN>BR>AR>QR  
;     ;global g프렌드체크  
;     IniRead, 프렌드체크, %ConfigFile%, QUEST_%퀘스트설정DDL%, 프렌드체크, 0
;     ;global g예장체크
;     IniRead, 예장체크, %ConfigFile%, QUEST_%퀘스트설정DDL%, 예장체크, 0
;     ;global g풀돌체크
;     IniRead, 풀돌체크, %ConfigFile%, QUEST_%퀘스트설정DDL%, 풀돌체크 , 0
; return
; }
