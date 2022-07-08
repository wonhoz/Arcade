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
    </ label="배경 아트", help="플라이어, 팬아트, 스크린샷, 비디오 중에서 배경에 표시할 항목을 선택하세요.", options="flyer,fanart,snap,video,none", order=16 /> bg_art="flyer";
    </ label="배경 영상", help="배경 영상을 선택하세요.", options="black,gray,red,orange,green,cyan,blue,purple,violet,dot,drop,dust,square,none", order=17 /> bg_media="blue";
    </ label="배경 마스크", help="medium 또는 dark 로 배경 마스크를 선택하세요.", options="dark,medium", order=18 /> bg_mask="dark";

    </ label="--------------------------", help=" ", options=" ", order=19 /> divider8="";
    //-----------------------------------------------------------------
    </ label="선택 박스 색상", help="선택 박스의 테두리 색상을 선택하세요.", options="blue,green,pink", order=20 /> select_box_color="green";
    </ label="캐릭터 표시방식", help="디스플레이 이름별 (By Display), 또는 게임 파일별 (By Game) 중에서 표시방식을 선택하세요.", options="By Display,By Game,None", order=21 /> select_character="By Display";
    </ label="캐릭터 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=22 /> character_alpha="254";

    </ label="--------------------------", help=" ", options=" ", order=23 /> divider9="";
    //-----------------------------------------------------------------
    </ label="조작 방법 안내", help="조작 방법을 선택하세요.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=24 /> select_keyinfo="XBOX360";

    </ label="--------------------------", help=" ", options=" ", order=25 /> divider10="";
    //-----------------------------------------------------------------
}


local my_config = fe.get_config();

fe.layout.font=my_config["select_font"];


fe.load_module( "fade" );
fe.load_module( "animate" );
fe.load_module( "pan-and-scan" );

local blip = fe.layout.height;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;






//coordinates table for different screen aspects -------------------------- START



local settings = {
    "default": {
        aspectDepend = {
            snap_skewX = 42.0, 
            snap_skewY = -8.0, 

            snap_pinchX = 0, 
            snap_pinchY = 29.0, 
            snap_rotation = 0.9, 

            marquee_skewX = 17, 
            marquee_skewY = 0, 
            marquee_pinchX = -2, 
            marquee_pinchY = 7, 
            marquee_rotation = 6.2, 

            wheelNumElements = 10
        }
    },
    "16x10": {
        aspectDepend = {
            res_x = 1920,
            res_y = 1200,

            maskFactor = 1.9,

            snap_skewX = 62.5, 
            snap_skewY = -12.9, 
            snap_pinchX = 0, 
            snap_pinchY = 40.0, 
            snap_rotation = 1.0, 

            wheelNumElements = 10
        }
    },
    "16x9": {
        aspectDepend = {
            res_x = 2133,
            res_y = 1200,

            maskFactor = 1.9,

            snap_skewX = 62.5, 
            snap_skewY = -12.9, 
            snap_pinchX = 0, 
            snap_pinchY = 40.0, 
            snap_rotation = 1.0, 

            wheelNumElements = 8
        }
    },
    "4x3": {
        aspectDepend = {
            res_x = 1600,
            res_y = 1200,

            maskFactor = 1.6,

            snap_skewX = 62.5, 
            snap_skewY = -12.9, 
            snap_pinchX = 0, 
            snap_pinchY = 40.0, 
            snap_rotation = 1.0, 

            wheelNumElements = 10
        }
    },
    "5x4": {
        aspectDepend = {
            res_x = 1500,
            res_y = 1200,

            maskFactor = 1.6,

            snap_skewX = 62.5, 
            snap_skewY = -12.9, 
            snap_pinchX = 0, 
            snap_pinchY = 40.0, 
            snap_rotation = 1.0, 

            wheelNumElements = 10
        }
    }
}




local aspect = fe.layout.width / fe.layout.height.tofloat();
print (aspect);
local aspect_name = "";
switch( aspect.tostring() )
{
    case "1.77865":  //for 1366x768 screen
    case "1.77778":  //for any other 16x9 resolution
        aspect_name = "16x9";
        break;
    case "1.6":
        aspect_name = "16x10";
        break;
    case "1.33333":
        aspect_name = "4x3";
        break;
    case "1.25":
        aspect_name = "5x4";
        break;
    case "0.75":
        aspect_name = "3x4";
        break;
}


function Setting( id, name )
{
    if ( aspect_name in settings && id in settings[aspect_name] && name in settings[aspect_name][id] )
    {
        ::print("\tusing settings[" + aspect_name + "][" + id + "][" + name + "] : " + settings[aspect_name][id][name] + "\n" );
        return settings[aspect_name][id][name];
    }
    else if ( aspect_name in settings == false )
    {
        ::print("\tsettings[" + aspect_name + "] does not exist\n");
    }
    else if ( name in settings[aspect_name][id] == false )
    {
        ::print("\tsettings[" + aspect_name + "][" + id + "][" + name + "] does not exist\n");
    }

    ::print("\t\tusing default value: " + settings["default"][id][name] + "\n" );
    return settings["default"][id][name];
}




fe.layout.width = Setting("aspectDepend", "res_x");
fe.layout.height = Setting("aspectDepend", "res_y");

local blip = fe.layout.height;

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local mask_factor = Setting("aspectDepend", "maskFactor");


//coordinates table for different screen aspects -------------------------- END









// mute audio variable - definable via user config ------------------------ START

if ( my_config["mute_videoSnaps"] == "yes") 
{
    ::videoSound <- Vid.NoAudio;
}
if ( my_config["mute_videoSnaps"] == "no") 
{
    ::videoSound <- Vid.Default;
}

// mute audio variable - definable via user config ------------------------ END

