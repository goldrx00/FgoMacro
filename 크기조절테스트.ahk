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

ClickAdb2(x, y ) ; adb클릭
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

global pBitmap3 := 0
;global G2 := Gdip_GraphicsFromImage(pBitmap3) 
그림그리기(x,y,w,h)
{
    addlog("그림그리기" x y w h)
    if(pBitmap3 = 0)
        pBitmap3 := Gdip_CreateBitmap(800, 450)
    ; if(hBitmap = 0)
    ;     pBitmap := Gdip_CreateBitmap(800, 450)
    ; else
    ;     pBitmap :=Gdip_CreateBitmapFromHBITMAP(hBitmap)
    G2 := Gdip_GraphicsFromImage(pBitmap3)    
    pPen := Gdip_CreatePen(0xFFFF0000, 1)
    ;Gdip_DrawLine(G, pPen, 10, 10, 280, 280)
    Gdip_DrawRectangle(G2, pPen, x, y, w, h)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap3)
    Guicontrol, 2: , pic2, HBITMAP:%hBitmap%



    Gdip_DeletePen(pPen)
    Gdip_DeleteGraphics(G)
    DeleteObject(hBitmap)
}


; fn := Func("zsa").Bind(2,1)
; Gui, Add, Button, x+10 w70 h30  v테스트, 테스트