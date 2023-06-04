Gui, 2: +Owner1 ;메인 gui (1번)에 귀속시킨다. 추가로 작업표시줄에 안뜸
Gui, 2: Add, Picture, x0 y0 w800 h450 gClickImage vPic,

global squareCount := 20
loop, %squareCount%
{
    Gui, 2: Add, Picture, x0 y0  BackGroundTrans vsquare%a_index%
}

global touchCount := 10
loop, %touchCount%
{
Gui, 2: Add, Picture, w20 h20  BackGroundTrans vTouch%a_index%, image\터치.png
GuiControl, 2: hide,  Touch%a_index%
}

Gui, 2: Add, Text , xs y460 , X:
Gui, 2: Add, Edit, x+10 w50 vX좌표,
Gui, 2: Add, Text, x+10 , Y:
Gui, 2: Add, Edit, x+10 w50 vY좌표,
Gui, 2: Add, Button, x+10 w100 ggetAdbScreen, 화면업데이트

 ;Gui, 2: Add, Picture, 0xE w500 h300 hwndhPic          ; SS_Bitmap    = 0xE


ScreensView()
{
    static toggle
    ;IfWinNotExist, 화면보기
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

ClickImage()
{
    CoordMode, Mouse, Client
    MouseGetPos, vx, vy
    ;msgbox,Clicked %vx% %vy%
    GuiControl, 2:,  X좌표, %vx%
    GuiControl, 2:,  Y좌표, %vy%
    ; ClickAdb(vx, vy)
    ; sleep, 2000
    ; getAdbScreen()
}

네모그리기(x,y,w,h)
{
    static squareNUm := 1
    ;addlog("네모그리기")
    pBitmap := Gdip_CreateBitmap(w+4, h+4)
    G := Gdip_GraphicsFromImage(pBitmap)
    pPen := Gdip_CreatePen(0xFFFF0000, 4)
    ;pPen := Gdip_CreatePen(0xFFFFFFFF, 3)
    Gdip_DrawRectangle(G, pPen, 2, 2, w, h)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    ;GuiControl, 2: Hide,  Rectangle%squareNUm%
    x-=2, y-=2, w+=4, h+=4
    GuiControl, 2: move,  square%squareNUm%, x%x% y%y% w%w% h%h%
    Guicontrol, 2: , square%squareNUm%, HBITMAP:%hBitmap%
    GuiControl, 2: Show,  square%squareNUm%

    ; pBitmap := Gdip_CreateBitmap(800, 450)
    ; G := Gdip_GraphicsFromImage(pBitmap)
    ; pPen := Gdip_CreatePen(0xFFFF0000, 1)
    ; Gdip_DrawRectangle(G, pPen, x, y, w, h)
    ; hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
    ; Guicontrol, 2: , square1, HBITMAP:%hBitmap%     
    
    fn := Func("네모지우기").Bind(squareNUm)
    SetTimer, %fn%, -2000 ; 음수로 시간 적으면 한번만
    ;addlog("타이머%aa% on")

    Gdip_DeletePen(pPen)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    DeleteObject(hBitmap)

    squareNUm++
    if(squareNUm > squareCount)
        squareNUm := 1
}

네모지우기(ii)
{  
    GuiControl, 2: Hide,  square%ii%
}


터치표시(x,y)
{
    static touchNum := 1
    x-=10
    y-=10
    GuiControl, 2: move,  Touch%touchNum%, x%x% y%y%
    GuiControl, 2: Show,  Touch%touchNum%    

    fn := Func("터치지우기").Bind(touchNum)
    SetTimer, %fn%, -1000

    touchNum++
    if(touchNum > touchCount )
        touchNum := 1
}

터치지우기(ii)
{
    ;addlog(ii " 터치지우기")
    GuiControl, 2: Hide,  Touch%ii%
}

동그라미()
{
    w := h := 20
    pBitmap := Gdip_CreateBitmap(w+3, h+3)
    G := Gdip_GraphicsFromImage(pBitmap)
    pBrush := Gdip_BrushCreateSolid(0xFFFFFFFF)    
    Gdip_FillEllipse(G, pBrush, 1, 1, w, h)
    pPen := Gdip_CreatePen(0xFF000000, 2)
    Gdip_DrawEllipse(G, pPen, 1, 1, w, h)
    hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)    
    Guicontrol, 2: , Circle, HBITMAP:%hBitmap%

    Gdip_SaveBitmapToFile(pBitmap,"Image\동그라미.png")  

    Gdip_DeleteBrush(pBrush)
    Gdip_DeletePen(pPen)
    Gdip_DeleteGraphics(G)
    Gdip_DisposeImage(pBitmap)
    DeleteObject(hBitmap)
}