global g_pScreenBmp := 0 ;전역 pBitmap
global ADB_TIME_REFRESH := 200

getAdbScreen() ;;adb에서 화면 가져와서 hBitmap에 저장
{
    if(g_pScreenBmp)
    {
        Gdip_DisposeImage(g_pScreenBmp) ;이전 pBitmap 주소의 메모리를 비운다. 메모리 누수를 막기 위함
    }

    g_pScreenBmp := ADBScreencapToPBitmap()
    return true
}

SaveAdbCropImage(filename, x1, y1, x2, y2)
{
    w := x2 - x1
    h := y2 - y1

    sCmd := adb " -s " AdbSN " exec-out screencap"
    if(!hBm := ADBScreenCapStdOutToHBitmap(sCmd ))
    {	
        addlog(" @ ADB 스크린 캡쳐 실패")
        return false
    }
    ret := Gdip_CreateBitmapFromHBITMAP(hBm)
    ret2 := Gdip_CropImage(ret, x1, y1, w, h)
    Gdip_SaveBitmapToFile(ret2, filename)
    addlog("# ADB (" x1 ", " y1 ", " x2 ", " y2 ") " filename " 에 저장")
    
    DllCall("DeleteObject", Ptr, hBm)
    Gdip_DisposeImage(ret)
    Gdip_DisposeImage(ret2)	
}

CaptureAdb(filename)
{
    ;sCmd := adb " -s " AdbSN " shell screencap"
    sCmd := adb " -s " AdbSN " exec-out screencap"
    if hbm := ADBScreenCapStdOutToHBitmap( sCmd )
    {		
        ret := Gdip_CreateBitmapFromHBITMAP(hbm)
        Gdip_SaveBitmapToFile(ret,"adbCapture\" filename)
        DllCall("DeleteObject", Ptr, hbm)
        Gdip_DisposeImage(ret)
    }
    else
    {
        addlog("# ADB 스크린 캡쳐 실패")
        return false
    }
    log := "# 캡처 완료"
    AddLog(log)
    return
}

ClickAdb(x, y) ; adb클릭
{
    ;sleep, %ADB_TIME_REFRESH% ;;필요없는 듯
    if(x = 0 && y = 0)
    {
        log := "# 이미지 검색 실패로 클릭 실패"
        AddLog(log)
        return false
    }	
    objExec := objShell.Exec(adb " -s " AdbSN " shell input tap " x " " y )
    AddLog("# 클릭: " x ", " y)
    ;while(!objExec.status)
    ;	sleep, 10
    sleep, %ADB_TIME_REFRESH%
}

DragAdb(x1,y1,x2,y2,duration)
{	
    objExec := objShell.Exec(adb " -s " AdbSN " shell input swipe " x1 " " y1 " " x2 " " y2) ;" " duration)
    AddLog("# 드래그: " x1 ", " y1 " to " x2 ", " y2)
    sleep, %duration%
}

ClickToImgAdb(ByRef clickX, ByRef clickY, ImageName, errorRange=60, trans="") ;;클릭투이미지 클릭후이미지대기
{
    ;sleep, %ADB_TIME_REFRESH%
    x := clickX
    y := clickY
    if(clickX= 0 && clickY = 0)
    {
        log := "# 이미지 검색 실패로 클릭 실패"
        AddLog(log)
        return false
    }
    Loop
    {
        ClickAdb(x, y)
        log := "  @ 이미지 대기 " ImageName
        AddLog(log)
        ;while(!objExec.status)
        ;	sleep, 10		
        sleep, 1000 ;%ADB_TIME_REFRESH%		
        Loop, 10
        {
            if(IsImgPlusAdb(clickX, clickY, ImageName, errorRange, trans))
                return true
            ; if(AfterRestart = 1)
            ; {
            ;     log := "# 재시작이 일어났습니다"
            ;     AddLog(log)
            ;     return false
            ; }
            sleep, 1000 ;%ADB_TIME_REFRESH%
        }
        if(A_Index > 10)
            return false
            ;AfterRestart := 1
        ; if(AfterRestart = 1)
        ; {
        ;     log := "# 재시작이 일어났습니다"
        ;     AddLog(log)
        ;     return false
        ; }
        sleep, 20000
    }
}

Gdip_ImageSearchWithPbm(bmpHaystack, Byref X,Byref Y,bmpNeedle,Variation=0,Trans="",sX = 0,sY = 0,eX = 0,eY = 0) ;pBitmap으로 부터 서치
{    
    RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,LIST,sX,sY,eX,eY,Variation,Trans,1,1)
    StringSplit, LISTArray, LIST, `,
    X := LISTArray1
    Y := LISTArray2
    
    if(RET = 1)
    {
        IfWinExist, 화면보기
        {
            Gdip_GetImageDimensions(bmpNeedle, Width, Height)
            네모그리기(X,Y,Width,Height)
        }
        return true
    }
    else
        return false
}

IsImgPlusAdb(ByRef clickX, ByRef clickY, ImageName, errorRange, trans="", sX = 0, sY = 0, eX = 0, eY = 0) ;이즈이미지플러스 adb
{
    ;StringReplace, ImageName2, ImageName, Image\ , , All
    ;StringReplace, ImageName2, ImageName2, .bmp , , All
    if(!bmpPtrArr[(ImageName)]) ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)
        return false
    }

    pBitmap := ADBScreencapToPBitmap() 
   
    If(Gdip_ImageSearchWithPbm(pBitmap, ClickX, ClickY, bmpPtrArr[(ImageName)], errorRange, trans, sX, sY, eX, eY))
    {
        log := "  @ 이미지 찾음 : " ImageName
        AddLog(log)		
        Gdip_DisposeImage(pBitmap)
        return true
    }
    else
    {
        clickX := 0
        clickY := 0
        Gdip_DisposeImage(pBitmap)
        return false
    }
}

;캡쳐없이 미리 있던 파일에서 이미지 서치
IsImgPlusWithFile(ByRef clickX, ByRef clickY, ImageName, errorRange, trans, sX = 0, sY = 0, eX = 0, eY = 0) ;gdip
{
    ; StringReplace, ImageName2, ImageName, Image\ , , All
    ; StringReplace, ImageName2, ImageName2, .bmp , , All		
    If(!bmp_%ImageName%) ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)
        return false
    }
    
    file := "adbCapture\sc.png"
    If(Gdip_ImageSearchWithFile(file, ClickX, ClickY, bmp_%ImageName%, errorRange, trans, sX, sY, eX, eY))
    {
        log := "  @ 이미지 찾음 : " ImageName
        AddLog(log)	
        return true
    }
    else
    {
        clickX := 0
        clickY := 0
        ;log := "  @ 이미지 못 찾음 : " ImageName
        ;AddLog(log)	
        return false
    }
}

IsImgWithoutCap(ByRef clickX, ByRef clickY, ImageName, errorRange, trans, sX = 0, sY = 0, eX = 0, eY = 0) ;gdip
{
    
    ;StringReplace, ImageName2, ImageName, Image\ , , All
    ;StringReplace, ImageName2, ImageName2, .bmp , , All

    if(!bmpPtrArr[(ImageName)]) ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)
        return false
    }	
    If(Gdip_ImageSearchWithPbm(g_pScreenBmp, ClickX, ClickY, bmpPtrArr[(ImageName)], errorRange, trans, sX, sY, eX, eY))
    {
        log := "  @ 이미지 찾음 : " ImageName
        AddLog(log)	
        return true
    }
    else
    {
        clickX := 0
        clickY := 0
        ;log := "  @ 이미지 못 찾음 : " ImageName
        ;AddLog(log)	
        return false
    }
}

IsImgWithoutCapLog(ByRef clickX, ByRef clickY, ImageName, errorRange, trans, sX = 0, sY = 0, eX = 0, eY = 0) ;캡쳐, 로그 둘다 없이 서치
{
    ; StringReplace, ImageName2, ImageName, Image\ , , All
    ; StringReplace, ImageName2, ImageName2, .bmp , , All		
    If(!bmpPtrArr[(ImageName)]) ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)
        return false
    }
    If(Gdip_ImageSearchWithPbm(g_pScreenBmp, ClickX, ClickY, bmpPtrArr[(ImageName)], errorRange, trans, sX, sY, eX, eY))
    {
        ;log := "  @ 이미지 찾음 : " ImageName
        ;AddLog(log)	
        return true
    }
    else
    {
        clickX := 0
        clickY := 0
        return false
    }
}

ADBScreencapToPBitmap()
{
    sCmd := adb " -s " AdbSN " exec-out screencap" ;sehll은 화면이 깨지지만 exec-out은 안깨진다
    if(!hBitmap := ADBScreenCapStdOutToHBitmap(sCmd ))
    {
        addlog("  @ ADB 스크린 캡쳐 실패")
        return false
    }
    pBitmap := Gdip_CreateBitmapFromHBITMAP(hBitmap)

    ;hbitmap을 화면에 표시
    IfWinExist, 화면보기
        Guicontrol,2: , Pic, HBITMAP:%hBitmap%
    ;리사이즈일때만 작동
    ; GuiControlGet, IsResize,
    ; if (IsResize)
    ; {
    ;     ;addlog(gRatio " " cropX " " cropY  " " cropW " " cropH)
    ;     pBitmap := Gdip_CropResizeBitmap(ret, gRatio ,cropX,cropY,cropW,cropH)
    ;     Gdip_DisposeImage(ret)
    ; }
    ; else
    ;     pBitmap := ret

    DeleteObject(hBitmap)
    return pBitmap
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;adb에서 파일쓰기 없이 바로 gdip hbitmap만들기;;;;;;;;;;;;;;;;
;;참조: https://autohotkey.tistory.com/40
;https://autohotkey.com/board/topic/96903-simplified-versions-of-seans-stdouttovar/

;MCode Func
AdjustScreencapData := MCode("2,x86:VVdWU4tsJBSLRCQYjXQF/zn1d1ONfv6NTQGJ6usRZpCJyIPCAYhZ/4PBATnydyI51w+2GnbqgPsNdeWAegENdd8PtloCgPsKdBa7DQAAAOvPKehbXl9dw5CNtCYAAAAAiciDwgPrvjHA6+iQkJCQkA==")

ScreencapToDIB := MCode("2,x86:VVdWU4PsDItEJCiLdCQkhcB+fY0EtQAAAACLVCQsxwQkAAAAAMdEJAQAAAAA99iJRCQIi0QkKIPoAQ+vxo08goX2fjuLRCQgi0wkBDHbjSyIi0SdDInCweoQD7bKicIlAP8AAMHiEIHiAAD/AAnKCdCJBJ+DwwE53nXWAXQkBIMEJAEDfCQIiwQkOUQkKHWwg8QMW15fXcOQkJCQkJCQkA==")

ADBScreenCapStdOutToHBitmap( sCmd ) 
{
    global AdjustScreencapData, ScreencapToDIB
    DllCall( "CreatePipe", UIntP,hPipeRead, UIntP,hPipeWrite, UInt,0, UInt,0 )
    DllCall( "SetHandleInformation", UInt,hPipeWrite, UInt,1, UInt,1 )
    VarSetCapacity( STARTUPINFO, 68,  0 )      ; STARTUPINFO          ;  http://goo.gl/fZf24
    NumPut( 68,         STARTUPINFO,  0 )      ; cbSize
    NumPut( 0x100,      STARTUPINFO, 44 )      ; dwFlags    =>  STARTF_USESTDHANDLES = 0x100 
    NumPut( hPipeWrite, STARTUPINFO, 60 )      ; hStdOutput
    NumPut( hPipeWrite, STARTUPINFO, 64 )      ; hStdError
    
    VarSetCapacity( PROCESS_INFORMATION, 16 )  ; PROCESS_INFORMATION  ;  http://goo.gl/b9BaI      
        
    If ! DllCall( "CreateProcess", UInt,0, UInt,&sCmd, UInt,0, UInt,0 ;  http://goo.gl/USC5a
        , UInt,1, UInt,0x08000000, UInt,0, UInt,0
    , UInt,&STARTUPINFO, UInt,&PROCESS_INFORMATION ) 
        Return "" 
    
    , DllCall( "CloseHandle", UInt,hPipeWrite ) 
    , DllCall( "CloseHandle", UInt,hPipeRead )
    , DllCall( "SetLastError", Int,-1 )
    
    hProcess := NumGet( PROCESS_INFORMATION, 0 )                 
    hThread  := NumGet( PROCESS_INFORMATION, 4 )                      
    
    DllCall( "CloseHandle", UInt,hPipeWrite )
    
    block := {}, blockIndex := 0, allSize := 0, nPipeAvail := 4096
    
    loop
    {
        ++blockIndex
        block[blockIndex] := {data:"", size:0, addr:0}
        ObjSetCapacity(block[blockIndex], "data", nPipeAvail)
        block[blockIndex].addr := ObjGetAddress(block[blockIndex], "data")
        
        nSz := 0
        
        if !DllCall( "ReadFile", UInt,hPipeRead, UInt,block[blockIndex].addr, UInt,nPipeAvail, UIntP,nSz, UInt,0 )
            break
        
        block[blockIndex].size := nSz, allSize += nSz
    }
    
    DllCall( "GetExitCodeProcess", UInt,hProcess, UIntP,ExitCode )
    DllCall( "CloseHandle", UInt,hProcess  )
    DllCall( "CloseHandle", UInt,hThread   )
    DllCall( "CloseHandle", UInt,hPipeRead )
    
    if allSize
    {
        VarSetCapacity( bin, allSize, 0 ), tar := &bin
        for k,v in block
            if v.size
            DllCall("RtlMoveMemory", "UPTR",tar, "UPTR",v.addr, "UInt",v.size), tar += v.size
        ;allSize := DllCall(AdjustScreencapData, "UPTR",&bin, "UInt",allSize, "cdecl") ;exec-out으로 받으면 조정필요없음
        width  := NumGet(&bin, 0, "uint"), height := NumGet(&bin, 4, "uint")
        hBM := CreateDIBSection(width, height,"",32, ppvBits)  
        DllCall(ScreencapToDIB, "UPtr",&bin, "UInt",width, "UInt",height, "UPtr",ppvBits, "cdecl")
        return hBM
    }
}

;--------------------------------------------------------------------
;MCode C언어 등으로 컴파일된 코드를 실행
MCode(mcode) 
{
    static e := {1:4, 2:1}, c := (A_PtrSize=8) ? "x64" : "x86"
    if (!regexmatch(mcode, "^([0-9]+),(" c ":|.*?," c ":)([^,]+)", m))
        return
    if (!DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", 0, "uint*", s, "ptr", 0, "ptr", 0))
        return
    p := DllCall("GlobalAlloc", "uint", 0, "ptr", s, "ptr")
    if (c="x64")
        DllCall("VirtualProtect", "ptr", p, "ptr", s, "uint", 0x40, "uint*", op)
    if (DllCall("crypt32\CryptStringToBinary", "str", m3, "uint", 0, "uint", e[m1], "ptr", p, "uint*", s, "ptr", 0, "ptr", 0))
        return p
    DllCall("GlobalFree", "ptr", p)
    return
}

SaveHBITMAPToFile(hBitmap, sFile)
{
    VarSetCapacity(DIBSECTION, A_PtrSize=8? 104:84, 0)
    NumPut(40, DIBSECTION, A_PtrSize=8? 32:24,"UInt") ;dsBmih.biSize
    DllCall("GetObject", "UPTR", hBitmap, "int", A_PtrSize=8? 104:84, "UPTR", &DIBSECTION)
    hFile:= DllCall("CreateFile", "UPTR", &sFile, "Uint", 0x40000000, "Uint", 0, "Uint", 0, "Uint", 2, "Uint", 0, "Uint", 0)
    DllCall("WriteFile", "UPTR", hFile, "int64P", 0x4D42|14+40+(biSizeImage:=NumGet(DIBSECTION, A_PtrSize=8? 52:44, "UInt"))<<16, "Uint", 6, "UintP", 0, "Uint", 0)
    DllCall("WriteFile", "UPTR", hFile, "int64P", 54<<32, "Uint", 8, "UintP", 0, "Uint", 0)
    DllCall("WriteFile", "UPTR", hFile, "UPTR", &DIBSECTION + (A_PtrSize=8? 32:24), "Uint", 40, "UintP", 0, "Uint", 0)
    DllCall("WriteFile", "UPTR", hFile, "Uint", NumGet(DIBSECTION, A_PtrSize=8? 24:20, "UPtr"), "Uint", biSizeImage, "UintP", 0, "Uint", 0)
    DllCall("CloseHandle", "UPTR", hFile)
}

/*
IsImgPlusAdb(ByRef clickX, ByRef clickY, ImageName, errorRange, trans="", sX = 0, sY = 0, eX = 0, eY = 0) ;이즈이미지플러스 adb
{		
    IfNotExist, %ImageName% ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)		
    }
    
    sCmd := adb " -s " AdbSN " exec-out screencap"
    if(!hBm := ADBScreenCapStdOutToHBitmap(sCmd ))
    {
        addlog(" @ ADB 스크린 캡쳐 실패")
        return false
    }
    If(Gdip_ImageSearchWithHbm(hBm, ClickX, ClickY, ImageName, errorRange, trans, sX, sY, eX, eY))
    {
        log := "  @ 이미지 찾음 : " ImageName
        AddLog(log)
        DllCall("DeleteObject", Ptr, hBm)
        return true
    }
    else
    {
        clickX := 0
        clickY := 0
        DllCall("DeleteObject", Ptr, hBm)
        return false
    }
}

/*
Gdip_ImageSearchWithHbm(hBitmap, Byref X,Byref Y,Image,Variation=0,Trans="",sX = 0,sY = 0,eX = 0,eY = 0) ;hbitmap으로 부터 서치
{
    gdipToken := Gdip_Startup()
    bmpHaystack := Gdip_CreateBitmapFromHBITMAP(hBitmap) 
    bmpNeedle := Gdip_CreateBitmapFromFile(Image)
    AddLog(bmpNeedle)
    RET := Gdip_ImageSearch(bmpHaystack,bmpNeedle,LIST,sX,sY,eX,eY,Variation,Trans,1,1)
    AddLog(RET)
    Gdip_DisposeImage(bmpHaystack)
    Gdip_DisposeImage(bmpNeedle)
    Gdip_Shutdown(gdipToken)
    StringSplit, LISTArray, LIST, `,
    X := LISTArray1
    Y := LISTArray2
    
    if(RET = 1)
        return true
    else
        return false
}
*/