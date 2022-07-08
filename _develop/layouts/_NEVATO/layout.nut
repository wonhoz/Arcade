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







// default background image (if background art is not enabled) ------------- START

// if ( my_config["enable_static_bkg"] == "blue") 
// {
//     local bg = fe.add_image( "background_blue.png", 0, 0, flw, flh );
// }
// if ( my_config["enable_static_bkg"] == "black")
// {
//     local bg = fe.add_image( "background_black.png", 0, 0, flw, flh );
// }
switch( my_config["bg_media"] )
{
    case "black":
    case "gray":
    case "red":
    case "orange":
    case "green":
    case "cyan":
    case "blue":
    case "purple":
    case "violet":
        local bgArt1 = fe.add_image("background/" + my_config["bg_media"] + ".png", 0, 0, flw, flh );
        local bgArt2 = fe.add_clone(bgArt1);

        animation.add( PropertyAnimation( bgArt1, {when = Transition.StartLayout, property = "x", start =   0, end = -flw, time = 28000, loop=true}));
        animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end =    0, time = 28000, loop=true}));			
        // animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));
        break;
    case "dot":
    case "drop":
    case "dust":
    case "square":
        local bg = fe.add_image( "background/" + my_config["bg_media"] + ".mp4", 0, 0, flw, flh );
        break;
    default:
        local bg = fe.add_image( "", 0, 0, flw, flh );
        break;
}

// default background image (if background art is not enabled) ------------- END







// background art --------------------------------------------------------- START

if ( my_config["bg_art"] == "flyer") 
{
    //  local bgart = fe.add_artwork( "flyer", flw*0.2, flw*0, flw*0.6, 0);
    local bgart = PanAndScanArt( "flyer", flw*0.2, 0, flw*0.6, flh);
    bgart.preserve_aspect_ratio = true;
    local mask = fe.add_image( "mask_edges.png", 0 , 0, mask_factor*flh, flh );  //gradient to mask left and right edge of the flyer 1.6 for 4:3 and 16:10  1.9 for 16:9
    mask.preserve_aspect_ratio = false;

    bgart.trigger = Transition.EndNavigation;
    bgart.set_fit_or_fill("fill");
    bgart.set_anchor(::Anchor.Center);
    bgart.set_zoom(4.5, 0.00008);
    bgart.set_animate(::AnimateType.Bounce, 0.50, 0.50);

    bgart.set_randomize_on_transition(true);
    bgart.set_start_scale(1.1);
    local alpha_cfg = {
        when = Transition.ToNewSelection, property = "alpha", start = 0, end = 240, time = 1500
    }
    animation.add( PropertyAnimation( bgart, alpha_cfg ) );
}



if ( my_config["bg_art"] == "fanart") 
{
    local bgart = FadeArt( "fanart", 0, 0, 0, flh);
    bgart.preserve_aspect_ratio = true;
    local mask = fe.add_image( "mask_edges.png", 0 , 0, mask_factor*flh, flh );  //gradient to mask left and right edge of the flyer
    mask.preserve_aspect_ratio = false;
    //mask.alpha = 255;
}



if ( my_config["bg_art"] == "snap") 
{
    local bgart = fe.add_artwork( "snap", flx-flh*1.34, 0, flh*1.34, 0);
    bgart.preserve_aspect_ratio = true;
    bgart.video_flags=Vid.ImagesOnly;
}



if ( my_config["bg_art"] == "video") 
{
    local bgart = fe.add_artwork( "snap", flx-flh*1.34, 0, flh*1.34, 0);
    bgart.preserve_aspect_ratio = true;
    bgart.video_flags = videoSound;
}


// background art --------------------------------------------------------- END






//masking background (adding scanlines and vignette) -------------------- START

if ( my_config["bg_mask"] == "none" )
{
    local masking = fe.add_image( "", 0, 0, flw, 0 );
}


if ( my_config["bg_mask"] == "medium" )
{
    local masking = fe.add_image( "background_mask.png", 0, 0, flx, fly );
    masking.preserve_aspect_ratio = false;
    masking.alpha = 150;           // here you can change mask opacity light=100, medium=150, dark (default)=255
    local maskingMedium = fe.add_image( "background_mask_medium.png", 0, 0, flx, fly );
    maskingMedium.preserve_aspect_ratio = false;
}


if ( my_config["bg_mask"] == "dark" )
{
    local masking = fe.add_image( "background_mask.png", 0, 0, flx,fly);   //for 4:3 fix 1.6*fly
    masking.preserve_aspect_ratio = false;
    masking.alpha = 255;           // here you can change mask opacity light=100, medium=150, dark (default)=255
}

//masking background (adding scanlines and vignette) -------------------- END







//static tv effect on cab screen snap change (of if no snap at all) ------------- START

local tvStatic = fe.add_image( "static.jpg", blip*0.0984, blip*0.24, blip*0.405, blip*0.3536);
tvStatic.skew_x = Setting("aspectDepend", "snap_skewX");
tvStatic.skew_y = Setting("aspectDepend", "snap_skewY");
tvStatic.pinch_x = Setting("aspectDepend", "snap_pinchX");
tvStatic.pinch_y = Setting("aspectDepend", "snap_pinchY");
tvStatic.rotation = Setting("aspectDepend", "snap_rotation");





//snap (video or screenshot) on cab screen ------------- START

local cabScreen = fe.add_artwork ("snap", blip*0.0984, blip*0.24, blip*0.405, blip*0.3536);
cabScreen.skew_x = Setting("aspectDepend", "snap_skewX");
cabScreen.skew_y = Setting("aspectDepend", "snap_skewY");
cabScreen.pinch_x = Setting("aspectDepend", "snap_pinchX");
cabScreen.pinch_y = Setting("aspectDepend", "snap_pinchY");
cabScreen.rotation = Setting("aspectDepend", "snap_rotation");
cabScreen.trigger = Transition.EndNavigation;
cabScreen.preserve_aspect_ratio = false;

cabScreen.video_flags = videoSound;

if ( my_config["cabScreenType"] == "screenshot" )
{
    cabScreen.video_flags=Vid.ImagesOnly;
}





//scanlines over cab screen --------------------------- START

if ( my_config["enable_scanlines"] == "light" )
{
    local scanlines = fe.add_image( "scanlines.png", blip*0.0984, blip*0.24, blip*0.405, blip*0.3536 );
    scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 50;
}

if ( my_config["enable_scanlines"] == "medium" )
{
    local scanlines = fe.add_image( "scanlines.png", blip*0.0984, blip*0.24, blip*0.405, blip*0.3536 );
    scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 150;
}

if ( my_config["enable_scanlines"] == "dark" )
{
    local scanlines = fe.add_image( "scanlines.png", blip*0.0984, blip*0.24, blip*0.405, blip*0.3536 );
    scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 200;
}

//scanlines over cab screen --------------------------- END






//marquee  ------------------------------------------ START

if ( my_config["marquee_type"] == "marquee" )
{
    local marqueeBkg = fe.add_image("[marquee]", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    marqueeBkg.skew_x = Setting("aspectDepend", "marquee_skewX");
    marqueeBkg.skew_y = Setting("aspectDepend", "marquee_skewY");
    marqueeBkg.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    marqueeBkg.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    marqueeBkg.rotation = Setting("aspectDepend", "marquee_rotation");
    marqueeBkg.trigger = Transition.EndNavigation;
    marqueeBkg.preserve_aspect_ratio = false;

    local marquee = FadeArt("marquee", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    marquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    marquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    marquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    marquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    marquee.rotation = Setting("aspectDepend", "marquee_rotation");
    marquee.trigger = Transition.EndNavigation;
    marquee.preserve_aspect_ratio = false;
}

//marquee  ------------------------------------------ END



//marquee (with emulator name)   ---------------------- START

if ( my_config["marquee_type"] == "emulator-name" )

{
    local emuMarquee = fe.add_image("[Emulator]" + "-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    emuMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    emuMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    emuMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    emuMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    emuMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
    emuMarquee.trigger = Transition.EndNavigation;
    emuMarquee.preserve_aspect_ratio = false;
}



//marquee (my own image) ----------------------------- START

if ( my_config["marquee_type"] == "my-own" )
{
    local myOwnMarquee = fe.add_image("my-own-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    myOwnMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    myOwnMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    myOwnMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    myOwnMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    myOwnMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
    myOwnMarquee.trigger = Transition.EndNavigation;
    myOwnMarquee.preserve_aspect_ratio = false;
}






//cabinet image -------------------------------------- START
local cab = fe.add_image( "cabinet/vewlix.png", 0, 0, blip*0.992, blip*1.008);
cab.preserve_aspect_ratio = true;







//LCD display text under cab screen ------------------------------------------------ START

local lcdLeftText = fe.add_text( "PLAYED: " + "[PlayedCount]", blip*0.1536, blip*0.6108, blip*0.48, blip*0.04 );  // here you can change what is displayed on left side
lcdLeftText.set_rgb( 59, 45, 3 );
lcdLeftText.align = Align.Left;  
lcdLeftText.rotation = -6.5;
lcdLeftText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font



if ( my_config["lcdRight"] == "filter" )
{
    local lcdRightText = fe.add_text( "[FilterName]", blip*0.1584, blip*0.6108, blip*0.4, blip*0.04 );
    lcdRightText.set_rgb( 59, 45, 3 );
    lcdRightText.align = Align.Right;
    lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "rom-filename" )
{
    local lcdRightText = fe.add_text( "[Name]", blip*0.1584, blip*0.6108, blip*0.4, blip*0.04 );
    lcdRightText.set_rgb( 59, 45, 3 );
    lcdRightText.align = Align.Right;
    lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "display-name" )
{
    local lcdRightText = fe.add_text( "[DisplayName]", blip*0.1584, blip*0.6108, blip*0.4, blip*0.04 );
    lcdRightText.set_rgb( 59, 45, 3 );
    lcdRightText.align = Align.Right;
    lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "emulator" )
{
    local lcdRightText = fe.add_text( "[Emulator]", blip*0.1584, blip*0.6108, blip*0.4, blip*0.04 );
    lcdRightText.set_rgb( 59, 45, 3 );
    lcdRightText.align = Align.Right;
    lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "off" )
{
    local lcdRightText = fe.add_text( my_config["lcdRightText"], blip*0.1584, blip*0.6108, blip*0.4, blip*0.04 );
    lcdRightText.set_rgb( 59, 45, 3 );
    lcdRightText.align = Align.Right;
    lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}

//LCD display text --------------------------------------------------------- END

