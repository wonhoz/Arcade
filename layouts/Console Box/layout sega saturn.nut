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
    </ label="배경 영상", help="배경 영상을 선택하세요.", options="black,gray,red,orange,green,cyan,blue,purple,violet,dot,drop,dust,square,none", order=6 /> bg_media="blue";

    </ label="--------------------------", help=" ", options=" ", order=7 /> divider4="";
    //-----------------------------------------------------------------
    </ label="선택 박스 색상", help="선택 박스의 테두리 색상을 선택하세요.", options="blue,green,pink", order=8 /> select_box_color="green";
    </ label="캐릭터 표시방식", help="디스플레이 이름별 (By Display), 또는 게임 파일별 (By Game) 중에서 표시방식을 선택하세요.", options="By Display,By Game,None", order=9 /> select_character="By Display";
    </ label="캐릭터 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=10 /> character_alpha="254";
    
    </ label="--------------------------", help=" ", options=" ", order=11 /> divider5="";
    //-----------------------------------------------------------------
    </ label="전단 영상", help="전단 영상을 리스트 박스 배경으로 사용할 수 있습니다.", options="Yes,No", order=12 /> enable_flyer="No";
    </ label="전단 영상 투명도", help="0 (투명) 에서 254 (불투명) 사이의 값을 입력하세요.", options="", order=13 /> flyer_alpha="120";

    </ label="--------------------------", help=" ", options=" ", order=14 /> divider6="";
    //-----------------------------------------------------------------
    </ label="게임 로고 애니메이션", help="게임의 마키 영상을 애니메이션에 사용할 수 있습니다.", options="Yes,No", order=15 /> enable_gamelogo="Yes";
    </ label="아트웍 영상 선택", help="선택된 아트웍 영상이 콘솔 시스템 오른쪽에 표시됩니다.", options="Cartridge Disc,3D Box,None", order=16 /> boximage_type="Cartridge Disc";
    // </ label="히스토리 파일 위치", help="히스토리 파일의 위치를 입력하세요.", order=17 /> history_path=".\\history.dat";

    </ label="--------------------------", help=" ", options=" ", order=17 /> divider7="";
    //-----------------------------------------------------------------
    </ label="조작 방법 안내", help="조작 방법을 선택하세요.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=18 /> select_keyinfo="Arcade";

    </ label="--------------------------", help=" ", options=" ", order=19 /> divider8="";
    //-----------------------------------------------------------------
}


local my_config = fe.get_config();

fe.layout.font=my_config["select_font"];


fe.load_module( "fade" );
fe.load_module( "animate" );
fe.load_module( "pan-and-scan" );

fe.layout.width  = 1500;
fe.layout.height = 1200;

local blip = fe.layout.height;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;




// default background image (if background art is not enabled) ------------- START

// image animation
local bgArt1 = fe.add_image("background/purple.png", 0, 0, flw, flh );
local bgArt2 = fe.add_clone(bgArt1);

animation.add( PropertyAnimation( bgArt1, {when = Transition.StartLayout, property = "x", start =   0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end =    0, time = 28000, loop=true}));			
// animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));


// video
// local bg = fe.add_image( "background/dot.mp4", 0, 0, flw, flh );

// default background image (if background art is not enabled) ------------- END




// 모니터 동영상 배경
local blackbg = fe.add_image("black.png", 0.061*flw, 0.132*flh, 0.375*flw, 0.502*flh );


// 모니터와 콘솔기기
fe.add_image("monitor/monitor.png",      0.027*flw, 0.068*flh, 0.442*flw, 0.752*flh );
fe.add_image("system/[DisplayName].png", 0.102*flw, 0.75*flh, 0.245*flw, 0.242*flh );


// 동영상
local snap = fe.add_artwork("snap", 0.064*flw, 0.14*flh, 0.368*flw, 0.49*flh );
//snap.preserve_aspect_ratio = true;
snap.trigger = Transition.EndNavigation;
fe.add_image("scanline.png", 0.064*flw, 0.14*flh, 0.369*flw, 0.49*flh );




//Game Marquee Animation
::OBJECTS <- {
    marquee = fe.add_artwork( "marquee", 0.154*flw, 0.019*flh, 0.188*flw, 0.111*flh ),
}

if ( my_config["enable_gamelogo"] == "Yes" )
{
    local move_marquee1 = {
        when = Transition.ToNewSelection ,property = "y", start = 0, end = 0.028*flh, time = 100
    }

    local move_marquee2 = {
        when = Transition.ToNewSelection ,property = "y", start = 0.028*flh, end = 0.019*flh, delay = 100, time = 300
    }

    animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee1 ) );
    animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee2 ) );
}

OBJECTS.marquee.trigger = Transition.EndNavigation;




// 게임 리스트 박스 표시 ------------------------------------------------ START

// 게임 리스트 배경
local listbg = fe.add_image("listbox/listbox_34.png", flw*0.53125, flh*0.0185185, flw*0.453125, flh*0.96852 );
listbg.alpha = 150;


// 리스트 박스 백그라운드 이미지 선택
if ( my_config["enable_flyer"] == "Yes" )
{
	local flyer = fe.add_artwork( "flyer", 0.525*flw, 0.206*flh, 0.445*flw, 0.683*flh );
	flyer.alpha = abs(("0"+my_config["flyer_alpha"]).tointeger()) % 255;;
	flyer.trigger = Transition.EndNavigation;
}


// 게임 캐릭터 이미지 표시 (권장 이미지 사이즈: 480x760)
if ( my_config["select_character"] == "By Display" )
{
	local mascot = fe.add_image ("character/[DisplayName].png", 0.75*flw, 0.15625*flh, 480, 760);
	mascot.alpha = abs(("0" + my_config["character_alpha"]).tointeger()) % 255;;
	mascot.preserve_aspect_ratio = true;
}
//flyer.preserve_aspect_ratio = true;

if ( my_config["select_character"] == "By Game" )
{
    ::OBJECTS <- {
    effect = fe.add_artwork( "character", 0.75*flw, 0.15625*flh, 480, 760 ),
    }

    local move_effect1 = {
        when = Transition.ToNewSelection, property = "alpha", start = 80, end = 255, time = 700
    }
    
    animation.add( PropertyAnimation( OBJECTS.effect, move_effect1 ) );
    OBJECTS.effect.trigger = Transition.EndNavigation;
}


// 2D 또는 3D 박스 이미지 표시
if ( my_config["boximage_type"] == "Cartridge Disc" )
{
	local boximage = fe.add_artwork( "cartridge", 0.354*flw, 0.718*flh, 0.146*flw, 0.259*flh );
	boximage.preserve_aspect_ratio = true;
	local move_boximage = {
       when = Transition.ToNewSelection, property = "alpha", start = 0, end = 254, time = 800
	}
	animation.add( PropertyAnimation( boximage, move_boximage ) );
}

if ( my_config["boximage_type"] == "3D Box" )
{
	local boximage2 = fe.add_artwork( "3dbox", 0.354*flw, 0.718*flh, 0.146*flw, 0.259*flh );
	boximage2.preserve_aspect_ratio = true;
	local move_boximage2 = {
       when = Transition.ToNewSelection, property = "alpha", start = 0, end = 254, time = 800
	}
	animation.add( PropertyAnimation( boximage2, move_boximage2 ) );
}


// 게임 휠 이미지
//local bluebg2 = fe.add_image( "bg_marquee_1.png", 0.233*flw, 0.317*flh, 0.182*flw, 0.069*flh );

// 에뮬 디스플레이 타이틀
local displayName = fe.add_image ( "wheel/[DisplayName]", flw*0.56771, flh*0.02222, flw*0.3906, flh*0.1852 );

// 게임선택 박스
fe.add_image( "listbox/box_green.png", flw*0.534896, flh*0.507407407, flw*0.445833, flh*0.074074074 );


// 리스트 박스 게임번호 그림자
local listbox1b = fe.add_listbox( flw*0.541666667,flh*0.2064815, flw*0.1796875, flh*0.6759259 );
listbox1b.charsize = 36;
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0, 0, 0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.charsize=36;
listbox1b.format_string = "[ListEntry]";

// 리스트 박스 게임번호
local listbox1 = fe.add_listbox( flw*0.540104167, flh*0.2037037, flw*0.1796875, flh*0.6759259 );
listbox1.charsize = 36;
listbox1.set_sel_rgb( 255 243, 20 );
listbox1.set_rgb( 73, 223, 222 );
listbox1.selbg_alpha = 0;
listbox1.align = Align.Left;
listbox1.charsize=36;
listbox1.format_string = "[ListEntry]";


// 리스트 박스 게임이름 그림자
local listbox2b = fe.add_listbox( flw*0.59375, flh*0.2064815, flw*0.39, flh*0.6759259 );
listbox2b.charsize = 36;
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;
listbox2b.format_string = "[!gamename]";

// 리스트 박스 게임이름
local listbox2 = fe.add_listbox( flw*0.5921875, flh*0.2037037, flw*0.39, flh*0.6759259 );
listbox2.charsize = 36;
listbox2.set_sel_rgb( 255 243, 20 );
listbox2.set_rgb( 240, 240, 240 );
listbox2.selbg_alpha = 0;
listbox2.align = Align.Left;
listbox2.format_string = "[!gamename]";


// 문자 생략
// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
function gamename( index_offset )
{
    local s = split( fe.game_info( Info.Title, index_offset ), "[/" );
    if ( s.len() > 0 ) return s[0];
    return "";
}


// 시계
local clockbtext = fe.add_text( "현재시각:", flw*0.5259375, flh*0.92962963, flw*0.124166667, flh*0.042592593 );
clockbtext.set_rgb( 0, 0, 0 );
clockbtext.charsize = 36;

local clocktext = fe.add_text( "현재시각:", flw*0.52434375, flh*0.926851852, flw*0.124166667, flh*0.042592593 );
clocktext.set_rgb( 211, 250, 255 );
clocktext.charsize = 36;

local clockb = fe.add_text( "", flw*0.6253125003, flh*0.92962963, flw*0.166666667, flh*0.042592593  );
clockb.align = Align.Left;
clockb.charsize = 36;
clockb.set_rgb( 0, 0, 0 );

local clock = fe.add_text( "", flw*0.6236953128, flh*0.926851852, flw*0.166666667, flh*0.042592593  );
clock.align = Align.Left;
clock.charsize = 36;
clock.set_rgb( 73, 223, 222 );

function update_clock( ttime )
{
    local now = date();
    clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
    clock.msg  = format("%02d", now.hour) + ":" + format("%02d", now.min );
}

fe.add_ticks_callback( this, "update_clock" );


// 즐겨찾기 필터
local listtextb = fe.add_text( "[!filter] 게임:", flw*0.7331249997, flh*0.92962963, flw*0.234375, flh*0.042592593 );
listtextb.set_rgb( 208, 56, 0 );
listtextb.charsize = 36;
listtextb.align = Align.Left;

local listtext = fe.add_text( "[!filter] 게임:", flw*0.7315078122, flh*0.926851852, flw*0.234375, flh*0.042592593 );
listtext.set_rgb( 255 243, 20 );
listtext.charsize = 36;
listtext.align = Align.Left;

// Change filter name to upper case
function filter()
{
    local text = fe.filters[fe.list.filter_index].name;

    switch( text )
    {
        case "All"        : text = "모든";     break;
        case "Favourites" : text = "즐겨찾는"; break;
        case "Fighting"   : text = "격투";     break;
        case "GunShooting": text = "건슈팅";   break;
        case "Racing"     : text = "레이싱";   break;
        case "Rhythm"     : text = "리듬";     break;
        case "Board"      : text = "보드";     break;
        case "Shooting"   : text = "슈팅";     break;
        case "Arcade"     : text = "아케이드"; break;
        case "Action"     : text = "액션";     break;
        case "Quiz"       : text = "퀴즈";     break;
        case "Puzzle"     : text = "퍼즐";     break;
        case "1980s"      : text = "80년대";   break;
        case "1990s"      : text = "90년대";   break;
        case "2000s"      : text = "2000년대"; break;
        case "2010s"      : text = "2010년대"; break;
    }

    return text.toupper();
}

local listb = fe.add_text("[ListSize]", flw*0.9140625, flh*0.92962963, flw*0.124166667, flh*0.042592593 );
listb.set_rgb( 0, 0, 0 );
listb.charsize=36;
listb.align = Align.Left;

local list = fe.add_text( "[ListSize]", flw*0.9125, flh*0.926851852, flw*0.124166667, flh*0.042592593 );
list.set_rgb( 73, 223, 222 );
list.charsize=36;
list.align = Align.Left;

// 게임 리스트 박스 표시 --------------------------------------------------------- END






// 즐겨찾기 아이콘 표시 ------------------------------------------------ START

function getFavs(index_offset)
{
    if (fe.game_info( Info.Favourite, index_offset ) == "1") return "fav.png";
    else return "";
}

local romFav = fe.add_image( getFavs(0), flw*0.5, flh*0.5185, flw*0.03125, flh*0.0555 );

fe.add_transition_callback( "update_my_list" );
function update_my_list( ttype, var, ttime )
{
    if(ttype == Transition.ToNewSelection)
    {
        romFav.file_name = getFavs(var);
    }
    return false;
}

fe.add_signal_handler( "updateFavs" );
function updateFavs( signal_str )
{
    if(signal_str == "add_favourite"){
        if(romFav.file_name != "") romFav.file_name = "";
        else romFav.file_name = "fav.png";
    }
}

// 즐겨찾기 아이콘 표시 --------------------------------------------------------- END




// 조작키 안내
fe.add_image("key/" + my_config["select_keyinfo"] + ".png", flw*0.01823, flh*0.9167, flw*0.4948, flh*0.07037 );
