Attach:
    global objShell
    global hCon
    global cPid
        
    ;;adb방식 컨트롤 하는 cmd 생성
    DetectHiddenWindows, on ;숨겨진 윈도우 조작 가능
    Run, %comspec% /k ,, UseErrorLevel , cPid  ;hide 추가하면 숨겨짐
    WinWait, ahk_pid %cPid%,, 10
    WinHide, ahk_pid %cPid% ;나중에 숨기기
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
