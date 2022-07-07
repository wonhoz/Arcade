// -------------------------------------------------------
//
// "Console Box" theme for Attract-Mode Front-End
// version 1.0
//
// read more at malio.tistory.com
//
// -------------------------------------------------------
//
// this theme is free for private use only
// and can be distributed only with Attract Mode front-end
// for other uses please contact malio.tistory.com for permission
//
// -------------------------------------------------------

class UserConfig
{
    </ label="Console Box 테마", help=" ", options=" ", order=1 /> divider1="";
    </ label="--------------------------", help=" ", options=" ", order=1 /> divider1="";
    //-----------------------------------------------------------------
    </ label="글꼴 선택", help="화면에 표시되는 글꼴을 변경할 수 있습니다.", options="Font,TmonMonsori,NanumGothicBold,TT", order=2 /> select_font="Font";

    </ label="--------------------------", help=" ", options=" ", order=3 /> divider2="";
    //-----------------------------------------------------------------
    </ label="모니터 스캔라인", help="모니터 스캔라인 효과를 조절할 수 있습니다.", options="light,medium,dark,off", order=4 /> enable_scanlines="light";

    </ label="--------------------------", help=" ", options=" ", order=5 /> divider3="";
    //-----------------------------------------------------------------
    </ label="선택 박스 색상", help="선택 박스의 테두리 색상을 선택하세요.", options="blue,green,pink", order=6 /> select_box_color="green";
    </ label="캐릭터 표시방식", help="디스플레이 이름별 (By Display), 또는 게임 파일별 (By Game) 중에서 표시방식을 선택하세요.", options="By Display,By Game,None", order=7 /> select_character="By Display";
    </ label="캐릭터 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=8 /> select_Alpha="254";
    
    </ label="--------------------------", help=" ", options=" ", order=9 /> divider4="";
    //-----------------------------------------------------------------
    </ label="전단 영상", help="전단 영상을 리스트 박스 배경으로 사용할 수 있습니다.", options="Yes,No", order=10 /> enable_flyer="Yes";
    </ label="전단 영상 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=11 /> flyer_Alpha="120";

    </ label="--------------------------", help=" ", options=" ", order=12 /> divider5="";
    //-----------------------------------------------------------------
    </ label="게임 로고 애니메이션", help="게임의 마키 영상을 애니메이션에 사용할 수 있습니다.", options="Yes,No", order=13 /> enable_gamelogo="Yes";
    </ label="아트웍 영상 선택", help="선택된 아트웍 영상이 콘솔 시스템 오른쪽에 표시됩니다.", options="Cartridge_Disc,3D Box,None", order=14 /> enable_boximage="cartridge_disc";
    </ label="히스토리 파일 위치", help="히스토리 파일의 위치를 입력하세요.", order=15 /> dat_path=".\\history.dat";

    </ label="--------------------------", help=" ", options=" ", order=16 /> divider6="";
    //-----------------------------------------------------------------
    </ label="조작 방법 안내", help="조작 방법을 선택하세요.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=17 /> select_Keyinfo="XBOX360";

    </ label="--------------------------", help=" ", options=" ", order=18 /> divider7="";
    //-----------------------------------------------------------------
}


local my_config = fe.get_config();

