ClickImage()
{
    CoordMode, Mouse, Client
    MouseGetPos, vx, vy
    ;msgbox,Clicked %vx% %vy%
    ClickAdb(vx, vy)
    sleep, 2000
    getAdbScreen()
}


이벤트배너()
{
    getAdbScreen()
    ret := Gdip_CropImage(g_pScreenBmp, 420, 200, 160, 50)
    Gdip_SaveBitmapToFile(ret,"Image\이벤트배너.bmp")      
    Gdip_DisposeImage(ret)
    return
}

LoadImage()
{
    For Key , in bmpPtrArr
        Gdip_DisposeImage(bmpPtrArr[(Key)]) ;기존에 로딩되어있던 이미지 메모리에서 지움

    imageNum := 0
    AddLog("# 이미지 로딩 중...")
    ;gdipTokenA := Gdip_Startup()
    Loop, image\*.bmp, , 1  ; Recurse into subfolders.
    {
        ;imgFileName = %A_LoopFileName%
        imgFileName = %A_LoopFileFullPath%
        StringReplace, imgFileName, imgFileName, Image\ , , All
        ;StringReplace, imgFileName, imgFileName, .bmp , , All
        ;addlog(imgFileName)
                
        if(!bmpPtrArr[(imgFileName)] := Gdip_CreateBitmapFromFile(A_LoopFileFullPath))
            Addlog("  " A_LoopFileName " 로딩 실패")		
        ;else
            ;Addlog("  " A_LoopFileName )
        imageNum++
    }
    
    ; 이미지 비트맵을 복사해서 새로운 비트맵 만들기 (이미지 파일 수정하기 위함)
    For Key , in bmpPtrArr 
    {	
        ;addlog(Key)
        Gdip_GetImageDimensions(bmpPtrArr[(Key)], Width, Height)
        newBitmap := Gdip_CreateBitmap(Width, Height)
        G := Gdip_GraphicsFromImage(newBitmap)
        Gdip_DrawImage(G, bmpPtrArr[(Key)], 0, 0, Width, Height)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(bmpPtrArr[(Key)])
        bmpPtrArr[(Key)] := newBitmap
    }

    AddLog("# 이미지 " imageNum "장 로딩 완료")
    return
}

IniRead(key, Section = "Option")
{
    IniRead, OutputVar, %ConfigFile%, %Section%, %key%
    GuiControl,, %key%, %OutputVar%
}

LoadOption()
{    
    IniRead, initX, %ConfigFile%, Position, X
    IniRead, initY, %ConfigFile%, Position, Y
    if(initX < 0 || initY < 0)
    {
        initX := 100
        initY := 100
    }
    ;재입장
    ; IniRead, IniAdbSN, %ConfigFile%, Option, AdbSN
    ; GuiControl,, AdbSN, %IniAdbSN%
    IniRead("AdbSN")
    IniRead("botToken")
    IniRead("chatID")
    IniRead("Hibernate")
    IniRead("유휴시간")
    IniRead("절전시간")    
    
    loop, 3
    {       
        IniRead, 점사%a_index%, %ConfigFile%, Option, 점사%a_index%
        temp := 점사%a_index%
        GuiControl, Choose, 점사%a_index%, %temp%
    }
    loop,3
    {
        ii := a_index
        loop, 3
        {
            IniRead("보구" ii "라" a_index) 
        }	
    }
    loop, 3
    {
        IniRead("공명" a_index)
    }
    loop, 3
    {
         IniRead("멀린" a_index)
    }
    loop, 3
    {
        IniRead("스카디" a_index)
    }
    log := "# 설정 불러오기 완료"
    AddLog(log)
    return
}

IniWrite(key, section ="Option")
{
    GuiControlGet, %key%, 1:
    Value := %key%
    IniWrite, %Value%, %ConfigFile%,  %section%, %key%
}

SaveOption() ;세이브옵션
{
    WinGetPos, posX, posY, width, height,  %MacroID%
    IniWrite, %posX%, %ConfigFile%, Position, X
    IniWrite, %posY%, %ConfigFile%, Position, Y
    ;ADB 시리얼
    ; GuiControlGet, AdbSN, 1:
    ; IniWrite, %AdbSN%, %ConfigFile%,  Option, AdbSN
    IniWrite("AdbSN")
    IniWrite("chatID")
    IniWrite("botToken")
    IniWrite("유휴시간")
    IniWrite("절전시간")
    IniWrite("Hibernate")
    
    loop, 3
    {
        IniWrite("점사" a_index)
        ; GuiControlGet, 점사%a_index%, 1:
        ; temp := 점사%a_index%
        ; IniWrite, %temp%, %ConfigFile%,  Option, 점사%a_index%

    }
    loop, 3
    {
        ii := a_index
        loop, 3
        {            
            IniWrite("보구" ii "라" a_index)
        }
    }
    loop, 3
    {
        IniWrite("공명" a_index)
    }
    loop, 3
    {
        IniWrite("멀린" a_index)
    }
    loop, 3
    {
        IniWrite("스카디" a_index)
    }
    return
}


ScreensView()
{
    static toggle
    if(!toggle)
    {
        RealWinSize(posX, posY, width, height, MacroID)
        ChildX := posX + width + 10
        ChildY := posY
        Gui, 2: Show, x%ChildX% y%ChildY% w800 , 화면보기 ;w800 h450
        toggle := !toggle
    }
    else
    {
        Gui, 2: Show, hide
        toggle := !toggle
    }
}

스샷폴더()
{
    run adbCapture\
}

이미지폴더()
{
    run Image\
}

adbConnect()
{
    objExec := objShell.Exec(adb " devices")
    strStdOut:=strStdErr:=""    
    while, !objExec.StdOut.AtEndOfStream
        strStdOut := objExec.StdOut.ReadAll()

    IfNotInString, strStdOut, %AdbSN%
    {
        addlog("# " AdbSN " 에 연결")
        objExec := objShell.Exec(adb " connect " AdbSN)
        while(!objExec.status)
            sleep, 10
    }
    
}

절전모드()
{
    GuiControlGet, Hibernate,
    GuiControlGet, 유휴시간, 
    addlog("# TimeIdle: " A_TimeIdle)
    if(Hibernate = true && A_TimeIdle > 60000*유휴시간)
    {
        MsgBox, 1, , 10초 후 절전모드가 실행됩니다., 10
        IfMsgBox, Cancel
        {
            sleeplog(20000)            
        }
        else
        {   
            fileName := "절전알림.png"
            CaptureAdb(fileName)		
            SendTelegramImg("adbCapture/" fileName)
            SendTelegram("절전모드 실행")
            addlog("# 절전모드 실행")
            sleep, 1000
            ;Run rundll32.exe user32.dll`,LockWorkStation ;화면잠금
            DllCall( "PowrProf\SetSuspendState", UInt,0, UInt,0, UInt,0 )  ;절전모드
            sleeplog(20000)            
        }
        addlog("# Pause")
        pause
    }
}

튕김확인()
{
    if(IsImgPlusAdb(clickX, clickY, "튕김확인.bmp", 60, 0))
    {		
        SendTelegram("블택튕김 감지")        
        addlog("# 블택튕김 감지")
        절전모드()
    }
}

스크린샷()
{
    adbConnect()	
    fileName := A_yyyy a_mm A_DD "_" A_HOUR  A_MIN  A_SEC ".png"
    CaptureAdb(fileName)
    return
}

TelegramGetUpdates()
{
    if(!msg := getTelegramMsg())
        return
    
    Addlog("# 텔레그램 커맨드")
    switch msg
    {
        case "스샷":
            fileName := A_yyyy a_mm A_DD "_" A_HOUR  A_MIN  A_SEC ".png"
            CaptureAdb(fileName)		
            SendTelegramImg("adbCapture/" fileName)	
                
        case "정보":
            SendTelegram("반복 횟수: " rCount)

        case "철수하기":	
            ClickAdb(200, 200)
            메인종료 := 1

        case "영주사용":
            ClickAdb(400, 200)
            sleep, 5000
            fileName := "영주사용.png"
            CaptureAdb(fileName)		
            SendTelegramImg("adbCapture/" fileName)

        case "중지":
            SendTelegram("중지")
            addlog("# 중지")           
            메인종료 := 1

         
        case "실행":
            if(메인종료 =1)
            {
                SendTelegram("실행")
                addlog("# 실행")
                실행버튼()              
            }
           
    }
}

좌표툴팁(x, y, str)
{
    RealWinSize(posX, posY, width, height, "페이트/그랜드오더")
    tipX := posX 
    tipY := posY + 36 ;뮤뮤 제목 높이
    tipX+= x
    tipY+= y
    ToolTip, %str%, %tipX%,%tipY%
}

global sqNum := 1
네모그리기(x,y,w,h)
{
    ;addlog("네모그리기")
    pBitmap := Gdip_CreateBitmap(w, h)
    G := Gdip_GraphicsFromImage(pBitmap)
    pPen := Gdip_CreatePen(0xFFFF0000, 4)
    ;pPen := Gdip_CreatePen(0xFFFFFFFF, 3)
    Gdip_DrawRectangle(G, pPen, 1, 1, w-2, h-2)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    ;GuiControl, 2: Hide,  Rectangle%sqNum%
    GuiControl, 2: move,  square%sqNum%, x%x% y%y% w%w% h%h%
    Guicontrol, 2: , square%sqNum%, HBITMAP:%hBitmap%
    GuiControl, 2: Show,  square%sqNum%

    ; pBitmap := Gdip_CreateBitmap(800, 450)
    ; G := Gdip_GraphicsFromImage(pBitmap)
    ; pPen := Gdip_CreatePen(0xFFFF0000, 1)
    ; Gdip_DrawRectangle(G, pPen, x, y, w, h)
    ; hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    ; Guicontrol, 2: , square1, HBITMAP:%hBitmap%     
    
    fn := Func("네모지우기").Bind(sqNum)
    SetTimer, %fn%, -3000 ; 음수로 시간 적으면 한번만
    ;addlog("타이머%aa% on")

    Gdip_DeletePen(pPen)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    DeleteObject(hBitmap)

    sqNum++
    if(sqNum >10)
        sqNum := 1
}


네모지우기(num)
{
    ;addlog(num " 끄기")
    ;SetTimer, 네모지우기%num%, off    
    GuiControl, 2: Hide,  square%num%
}