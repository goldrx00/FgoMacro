
Menu, Tray, Icon, icon.ico

Menu, Submenu, Add, 이미지 로드, LoadImage

Menu, Submenu, Add, 스크린샷, 스크린샷
Menu, Submenu, Add, 이벤트 배너, 이벤트배너
Menu, Submenu, Add, ADB 강제종료, killAdb
;Menu, mymenu, Add, LoadImage, MenuHandler
;Menu, mymenu, Add,&File, :FileMenu
Menu, menuBar,Add , menu, :Submenu

Menu, 폴더열기, Add, 스샷 폴더, 스샷폴더
Menu, 폴더열기, Add, 이미지 폴더, 이미지폴더
Menu, menuBar, Add, 폴더열기, :폴더열기

Gui, Menu, menuBar

Gui, Add, Tab2, x10 w350 h240, 퀘스트|기타|텔레그램|추가설정|설명
Gui, Tab, 퀘스트

Gui, Add, Text, xp+5 yp+30, Android Serial Number:
;Gui, Add, Edit, x+10 vAdbSN,
Gui, Add, ComboBox, x+10 vAdbSN , ;emulator-5554||127.0.0.1:5555|127.0.0.1:21503|127.0.0.1:62001

Gui, Add, Text, x15 y71 , 퀘스트 설정 리스트: ;;점사 기준점
Gui, Add, DropDownList,  v퀘스트설정DDL,
Gui, Add, Button, gshowQusetConfig, 퀘스트 설정 열기
Gui, Add, Button, gScreensView, 화면보기

; Gui, Add, Text, x15 y71 , 1라 타겟: ;;점사 기준점
; Gui, Add, DropDownList,  AltSubmit v점사1, 전||중|후
; Gui, Add, Text, , 2라 타겟:
; Gui, Add, DropDownList, Choose1 AltSubmit v점사2, 전|중|후
; Gui, Add, Text, , 3라 타겟:
; Gui, Add, DropDownList, Choose1 AltSubmit v점사3, 전|중|후

; Gui, Add, Text, x+10 y71 , 보구 사용  ;;보구 사용 기준점
; Gui, Add, checkbox, xp yp+20 v보구1라1, 1
; Gui, Add, checkbox, xp+30 v보구1라2, 2
; Gui, Add, checkbox, xp+30  v보구1라3, 3
; Gui, Add, checkbox, xp-60 yp+45 v보구2라1, 1
; Gui, Add, checkbox, xp+30 v보구2라2, 2
; Gui, Add, checkbox, xp+30  v보구2라3, 3
; Gui, Add, checkbox, xp-60 yp+45 v보구3라1, 1
; Gui, Add, checkbox, xp+30 v보구3라2, 2
; Gui, Add, checkbox, xp+30 v보구3라3, 3

Gui, Add, GroupBox, x220 y71 w120 h160 , 자동스킬
Gui, Add, Text, xp+10 yp+20  w100, 공슼 차지 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v공명1, 1
Gui, Add, checkbox, xp+30  v공명2, 2
Gui, Add, checkbox, xp+30   v공명3, 3

Gui, Add, Text, xp-70 yp+20  w100, 멀린 버프 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v멀린1, 1
Gui, Add, checkbox, xp+30  v멀린2, 2
Gui, Add, checkbox, xp+30   v멀린3, 3

Gui, Add, Text, xp-70 yp+20  w100, 스카디 버프 사용 ;;공멀 기술 기준점
Gui, Add, checkbox, xp+10 yp+20 v스카디1, 1
Gui, Add, checkbox, xp+30  v스카디2, 2
Gui, Add, checkbox, xp+30   v스카디3, 3

Gui, Add, checkbox, x12 y220 v금사과사용, 금사과 사용

Gui, Tab, 텔레그램
Gui, Add, Text, ,텔레그램 Chat ID :
Gui, Add, Edit, vChatID,
Gui, Add, Text, ,텔레그램 BOT api Token :
Gui, Add, Edit, w320 vbotToken,

Gui, Tab, 설명
Gui, Add, Text, ,앱플레이어 해상도: 800 x 450
Gui, Add, Text, ,배틀 메뉴에서 스킬 사용 확인 OFF, 속도 두배
Gui, Add, Text, ,자동스킬 공멀슼 스킬은 1번칸에만 사용


Gui, Tab, 기타
Gui, Add, Button, h30 gLoadImage, 이미지 파일 로드
Gui, Add, Button, h30 g스크린샷, 스크린샷
Gui, Add, Button, h30 g무료소환, 무료소환
Gui, Add, Button, h30 g룰렛돌리기, 룰렛돌리기

Gui, Tab, 추가설정
Gui, Add, checkbox, vHibernate, 절전모드
Gui, Add, Text,  , 유휴시간(분):
Gui, Add, Edit, x+10 v유휴시간,
Gui, Add, Text, x22 y+8, 절전시간(분):
Gui, Add, Edit, x+10 v절전시간,





Gui, Tab

Gui, Add, Button, x10 y250 w70 h30  g실행버튼, 실행
Gui, Add, Button, x+10 w70 h30  gReset, 재시작
Gui, Add, Button, x+10 w70 h30  gPause, 일시정지
; fn := Func("zsa").Bind(2,1)
; Gui, Add, Button, x+10 w70 h30  v테스트, 테스트
; GuiControl,+g,테스트,%fn%
;Gui, Add, Button, x+10 w50 h30 gMenuInfo, 설명

Gui, Add, ListBox, x10 y+10 w350 h200 vLogList,

GuiControl, Focus, LogList 

