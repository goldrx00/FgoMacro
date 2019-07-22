#SingleInstance Force

Gui,Add,Combobox,vCOM,A|B|C
Gui,Show
return

F1::
GuiControl,,COM,|ㅋㅋ|ㅎㅎ||ㅅㅅ
GuiControlGet,COM
msgbox, %COM%
return