// -------------------------------------------------------
//
// "NEVATO" theme for Attract-Mode Front-End
// version 1.0
// 
// graphic design and coding = www.ClanLogoDesign.com
// cabinet design and photo = www.tenDESIGN.pro
//
// read more at www.ONYXarcade.com/nevato
//
// spinwheel code forked from omegaman's "ROBOSPIN" theme
//
// -------------------------------------------------------
//
// this theme is free for private use only
// and can be distributed only with Attract Mode front-end
// for other uses please contact ONYXarcade.com for permission
//
// -------------------------------------------------------
//
// special thanks to omegaman for ROBOSPIN theme
// without it - we wouldn't be able to learn how
// to code AM themes
//
// -------------------------------------------------------

class UserConfig
{
    </ label="NEVATO 테마", help=" ", options=" ", order=1 /> divider1="";
    </ label="--------------------------", help=" ", options=" ", order=1 /> divider1="";
    //-----------------------------------------------------------------
    </ label="글꼴 선택", help="화면에 표시되는 글꼴을 변경할 수 있습니다.", options="Font,TmonMonsori,NanumGothicBold,TT", order=2 /> select_font="Font";

    </ label="--------------------------", help=" ", options=" ", order=3 /> divider2="";
    //-----------------------------------------------------------------
    </ label="동영상 음소거", help="소리를 끄려면 yes, 그렇지 않으면 no 를 선택하세요.", options="yes,no", order=4 /> mute_videoSnaps="no";

    </ label="--------------------------", help=" ", options=" ", order=5 /> divider3="";
    //-----------------------------------------------------------------
    </ label="모니터 표시항목", help="동영상은 video, 스크린샷은 screenshot 을 선택하세요.", options="video, screenshot", order=6 /> cabScreenType="video";
    </ label="모니터 스캔라인", help="모니터 스캔라인 효과를 조절할 수 있습니다.", options="light,medium,dark,off", order=7 /> enable_scanlines="light";

    </ label="--------------------------", help=" ", options=" ", order=8 /> divider4="";
    //-----------------------------------------------------------------
    </ label="마키 아트웍", help="마퀴 타입을 선택하세요. 커스텀 마키 파일명: ''my-own-marquee.jpg''", options="marquee,emulator-name,my-own", order=9 /> marquee_type="marquee"; 
    
    </ label="--------------------------", help=" ", options=" ", order=10 /> divider5="";
    //-----------------------------------------------------------------
    </ label="LCD 우측 표시항목", help="표시할 항목을 선택하세요.", options="filter, emulator, display-name, rom-filename, off,", order=11 /> lcdRight="filter"; 

    </ label="--------------------------", help=" ", options=" ", order=12 /> divider6="";
    //-----------------------------------------------------------------
    </ label="스핀휠 아트웍", help="marquee, wheel, listbox 중에 선택하세요.", options="marquee,wheel,listbox", order=13 /> spinwheelArt="listbox";
    </ label="스핀휠 전환시간", help="시간 단위는 ms 입니다.", order=14 /> transition_ms="80";
    
    </ label="--------------------------", help=" ", options=" ", order=15 /> divider7="";
    //-----------------------------------------------------------------
    </ label="배경 아트",   help="플라이어, 팬아트, 스크린샷, 비디오 중에서 배경에 표시할 항목을 선택하세요.", options="flyer,fanart,snap,video,none", order=16 /> enable_bg_art="flyer";
    </ label="배경 이미지", help="배경 이미지를 선택하세요.", options="black,gray,red,orange,green,cyan,blue,purple,violet,none", order=17 /> enable_static_bkg="blue";
    </ label="배경 마스크", help="medium 또는 dark 로 배경 마스크를 선택하세요.", options="dark,medium", order=18 /> enable_mask="dark";

    </ label="--------------------------", help=" ", options=" ", order=19 /> divider8="";
    //-----------------------------------------------------------------
    </ label="선택 박스 색상", help="선택 박스의 테두리 색상을 선택하세요.", options="blue,green,pink", order=20 /> select_box_color="green";
    </ label="캐릭터 표시방식", help="디스플레이 이름별 (By Display), 또는 게임 파일별 (By Game) 중에서 표시방식을 선택하세요.", options="By Display,By Game,None", order=21 /> select_character="By Display";
    </ label="캐릭터 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=22 /> select_Alpha="254";

    </ label="--------------------------", help=" ", options=" ", order=23 /> divider9="";
    //-----------------------------------------------------------------
    </ label="조작 방법 안내", help="조작 방법을 선택하세요.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=24 /> select_Keyinfo="XBOX360";

    </ label="--------------------------", help=" ", options=" ", order=25 /> divider10="";
    //-----------------------------------------------------------------
}

