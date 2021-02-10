global gRatio := 1 ;;1080/450
global cropX := 0
global cropY := 0
global cropW := 800
global cropH := 450

;SetFormat,FLOAT, 0.2 ;소수점 자리밑으로 안보이게 하기

크기조절비트맵() 
{
    addlog("ss")
    sCmd := adb " -s " AdbSN " exec-out screencap"
    if(hbm := ADBScreenCapStdOutToHBitmap(sCmd ))
    {
        ret := Gdip_CreateBitmapFromHBITMAP(hbm)
        ;Gdip_SaveBitmapToFile(ret,"adbCapture\aa.png")
        resizedPbm := Gdip_ResizeBitmap(ret, 800, 0) ;뒤에 변수 두개 추가해서 바꿀수 있음
        Gdip_SaveBitmapToFile(resizedPbm,"adbCapture\bb.png")
        DeleteObject(hbm)
        Gdip_DisposeImage(ret)
        return resizedPbm
    }
    else
    {
        addlog("# ADB 스크린 캡쳐 실패")
        return false
    }
    
    return pBitmap
}


getAdbScreen() ;;adb에서 화면 가져와서 hBitmap에 저장
{
    if(g_pScreenBmp)
    {
        Gdip_DisposeImage(g_pScreenBmp) ;이전 pBitmap 주소의 메모리를 비운다. 메모리 누수를 막기 위함
    }

    g_pScreenBmp := ADBScreencapToPBitmap()
    ; sCmd := adb " -s " AdbSN " exec-out screencap" ;sehll은 화면이 깨지지만 exec-out은 안깨진다
    ; if(!hBitmap := ADBScreenCapStdOutToHBitmap(sCmd ))
    ; {
    ;     addlog(" @ ADB 스크린 캡쳐 실패")
    ;     return false
    ; }  
    
    ; ret := Gdip_CreateBitmapFromHBITMAP(hBitmap)
    ; Guicontrol,2: , Pic, HBITMAP:%hBitmap%

    ; GuiControlGet, IsResize,
    ; if(IsResize)
    ; {
    ;     g_pScreenBmp := Gdip_CropResizeBitmap(ret, gRatio ,cropX,cropY,cropW,cropH)
    ; }
    ; else
    ;     g_pScreenBmp := ret
    ; ;Gdip_SaveBitmapToFile(g_pScreenBmp,"adbCapture\g_pScreenBmp.png")
    ; Gdip_DisposeImage(ret)
    ; DeleteObject(hBitmap)

    ;Gui, 2: Add, Picture,, %g_pScreenBmp%
    ;Gui, 2: Add, text,, %g_pScreenBmp%
    return true
}

IsImgPlusAdb(ByRef clickX, ByRef clickY, ImageName, errorRange, trans="", sX = 0, sY = 0, eX = 0, eY = 0) ;이즈이미지플러스 adb
{	
    StringReplace, ImageName2, ImageName, Image\ , , All
    StringReplace, ImageName2, ImageName2, .bmp , , All		
    if(!bmpPtrArr[(ImageName2)]) ;;해당 이미지가 없으면 이미지 없다는 로그 출력하고 리턴
    {
        log := "  @ 이미지 없음: " ImageName
        AddLog(log)
        return false
    }

    pBitmap := ADBScreencapToPBitmap()
    
    ; sCmd := adb " -s " AdbSN " exec-out screencap"
    ; if(!hBitmap := ADBScreenCapStdOutToHBitmap(sCmd ))
    ; {
    ;     addlog("  @ ADB 스크린 캡쳐 실패")
    ;     return false
    ; }
    ; ret := Gdip_CreateBitmapFromHBITMAP(hBitmap)
    
    ; GuiControlGet, IsResize,
    ; if(IsResize)
    ; {
    ;     pBitmap := Gdip_CropResizeBitmap(ret, gRatio ,cropX,cropY,cropW,cropH)
    ; }
    ; else
    ;     pBitmap := ret   
    ; Gdip_DisposeImage(ret)
    ; DeleteObject(hBitmap)
    If(Gdip_ImageSearchWithPbm(pBitmap, ClickX, ClickY, bmpPtrArr[(ImageName2)], errorRange, trans, sX, sY, eX, eY))
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

ClickAdb(x, y ) ; adb클릭
{
    ;sleep, %ADB_TIME_REFRESH% ;;필요없는 듯
    if(x = 0 && y = 0)
    {
        log := "# 이미지 검색 실패로 클릭 실패"
        AddLog(log)
        return false
    }

    GuiControlGet, IsResize,
    AddLog("# 클릭: " x ", " y)
    if(IsResize)
    {
        ;ratio := gRatio
        ;addlog(ratio)
        x := x*gRatio + CropX
        y*=gRatio
    }
    
    objExec := objShell.Exec(adb " -s " AdbSN " shell input tap " x " " y )
    
    ;while(!objExec.status)
    ;	sleep, 10
    sleep, %ADB_TIME_REFRESH%
}

Gdip_CropResizeBitmap(pBitmap, ratio =1, x =0,y=0,w=800,h=450)
{
    ;addlog(ratio " " x " " y  " " w " " h)
    fixed_width:=floor(w*(1/ratio))
	fixed_height:=floor(h*(1/ratio))
    ;addlog(fixed_width " " fixed_height)

    pBitmap2 := Gdip_CreateBitmap(fixed_width, fixed_height)
    G := Gdip_GraphicsFromImage(pBitmap2)

    Gdip_DrawImage(G, pBitmap, 0, 0, fixed_width, fixed_height, x, y, w, h)
    Gdip_DisposeImage(pBitmap)
	Gdip_DeleteGraphics(G)
    return pBitmap2
}


ADBScreencapToPBitmap()
{
    sCmd := adb " -s " AdbSN " exec-out screencap"
    if(!hBitmap := ADBScreenCapStdOutToHBitmap(sCmd ))
    {
        addlog("  @ ADB 스크린 캡쳐 실패")
        return false
    }
    ret := Gdip_CreateBitmapFromHBITMAP(hBitmap)

    ;hbitmap을 화면에 표시
    IfWinExist, 화면보기
        Guicontrol,2: , Pic, HBITMAP:%hBitmap%
    ;리사이즈일때만 작동
    GuiControlGet, IsResize,
    if(IsResize)
    {
        ;addlog(gRatio " " cropX " " cropY  " " cropW " " cropH)
        pBitmap := Gdip_CropResizeBitmap(ret, gRatio ,cropX,cropY,cropW,cropH)
        Gdip_DisposeImage(ret)
    }
    else
        pBitmap := ret

    DeleteObject(hBitmap)
    ;addlog(pBitmap)
    return pBitmap
}
