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
    </ label="스핀휠 아트웍", help="marquee, wheel, listbox 중에 선택하세요.", options="marquee,wheel,list box", order=13 /> spinwheelArt="list box";
    </ label="스핀휠 전환시간", help="시간 단위는 ms 입니다.", order=14 /> transition_ms="80";
    
    </ label="--------------------------", help=" ", options=" ", order=15 /> divider7="";
    //-----------------------------------------------------------------
    </ label="배경 아트", help="플라이어, 팬아트, 스크린샷, 비디오 중에서 배경에 표시할 항목을 선택하세요.", options="flyer,fanart,snap,video,none", order=16 /> bg_art="flyer";
    </ label="배경 영상", help="배경 영상을 선택하세요.", options="black,gray,red,orange,green,cyan,blue,purple,violet,dot,drop,dust,square,none", order=17 /> bg_media="black";
    </ label="배경 마스크", help="배경 마스크 효과를 조절할 수 있습니다.", options="light,medium,dark,off", order=18 /> bg_mask="medium";

    </ label="--------------------------", help=" ", options=" ", order=19 /> divider8="";
    //-----------------------------------------------------------------
    </ label="선택 박스 색상", help="선택 박스의 테두리 색상을 선택하세요.", options="blue,green,pink", order=20 /> select_box_color="green";
    </ label="캐릭터 표시방식", help="디스플레이 이름별 (By Display), 또는 게임 파일별 (By Game) 중에서 표시방식을 선택하세요.", options="By Display,By Game,None", order=21 /> select_character="By Display";
    </ label="캐릭터 투명도", help="0 (투명) 에서 255 (불투명) 사이의 값을 입력하세요.", options="", order=22 /> character_alpha="255";

    </ label="--------------------------", help=" ", options=" ", order=23 /> divider9="";
    //-----------------------------------------------------------------
    </ label="조작 방법 안내", help="조작 방법을 선택하세요.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=24 /> select_keyinfo="Arcade";

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

// image animation
local bgArt1 = fe.add_image("background/white.png", 0, 0, flw, flh );
local bgArt2 = fe.add_clone(bgArt1);

animation.add( PropertyAnimation( bgArt1, {when = Transition.StartLayout, property = "x", start =   0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end =    0, time = 28000, loop=true}));			
// animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));


// video
// local bg = fe.add_image( "background/dot.mp4", 0, 0, flw, flh );

// default background image (if background art is not enabled) ------------- END







// background art --------------------------------------------------------- START

if ( my_config["bg_art"] == "flyer") 
{
    //  local bgart = fe.add_artwork( "flyer", flw*0.4, flw*0, flw*0.6, 0);
    local bgart = PanAndScanArt( "flyer", flw*0.4, 0, flw*0.6, flh);
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


if ( my_config["bg_mask"] == "light" )
{
    local masking = fe.add_image( "background_mask.png", 0, 0, flx,fly);   //for 4:3 fix 1.6*fly
    masking.preserve_aspect_ratio = false;
    masking.alpha = 50;           // here you can change mask opacity light=100, medium=150, dark (default)=255
    local maskingMedium = fe.add_image( "background_mask_medium.png", 0, 0, flx, fly );
    maskingMedium.preserve_aspect_ratio = false;
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
    masking.alpha = 200;           // here you can change mask opacity light=100, medium=150, dark (default)=255
}

//masking background (adding scanlines and vignette) -------------------- END







//cabinet image -------------------------------------- START
local cab = fe.add_image( "cabinet/vewlix_white.png", 0, 0, blip*0.674, blip*0.992);
cab.preserve_aspect_ratio = true;







//static tv effect on cab screen snap change (of if no snap at all) ------------- START

//local tvStatic = fe.add_image( "static.jpg", blip*0.1389, blip*0.372, blip*0.524, blip*0.399);
// tvStatic.skew_x = Setting("aspectDepend", "snap_skewX");
// tvStatic.skew_y = Setting("aspectDepend", "snap_skewY");
// tvStatic.pinch_x = Setting("aspectDepend", "snap_pinchX");
// tvStatic.pinch_y = Setting("aspectDepend", "snap_pinchY");
// tvStatic.rotation = Setting("aspectDepend", "snap_rotation");





//snap (video or screenshot) on cab screen ------------- START

local cabScreen = fe.add_artwork ("snap", blip*0.12698, blip*0.32813, blip*0.41797, blip*0.30664);
// cabScreen.skew_x = Setting("aspectDepend", "snap_skewX");
// cabScreen.skew_y = Setting("aspectDepend", "snap_skewY");
// cabScreen.pinch_x = Setting("aspectDepend", "snap_pinchX");
// cabScreen.pinch_y = Setting("aspectDepend", "snap_pinchY");
// cabScreen.rotation = Setting("aspectDepend", "snap_rotation");
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
    local scanlines = fe.add_image( "scanlines.png", blip*0.12698, blip*0.32813, blip*0.41797, blip*0.30664 );
    // scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    // scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    // scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    // scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    // scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 50;
}

if ( my_config["enable_scanlines"] == "medium" )
{
    local scanlines = fe.add_image( "scanlines.png", blip*0.12698, blip*0.32813, blip*0.41797, blip*0.30664 );
    // scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    // scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    // scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    // scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    // scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 150;
}

if ( my_config["enable_scanlines"] == "dark" )
{
    local scanlines = fe.add_image( "scanlines.png", blip*0.12698, blip*0.32813, blip*0.41797, blip*0.30664 );
    // scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
    // scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
    // scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
    // scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
    // scanlines.rotation = Setting("aspectDepend", "snap_rotation");
    scanlines.preserve_aspect_ratio = false;
    scanlines.alpha = 200;
}

//scanlines over cab screen --------------------------- END






//marquee  ------------------------------------------ START

if ( my_config["marquee_type"] == "marquee" )
{
    //local marqueesta = fe.add_image("static.jpg", blip*0.12988, blip*0.05371, blip*0.40918, blip*0.10254 );
    local marqueeBkg = fe.add_image("[marquee]", blip*0.12988, blip*0.05371, blip*0.40918, blip*0.10254 );
    // marqueeBkg.skew_x = Setting("aspectDepend", "marquee_skewX");
    // marqueeBkg.skew_y = Setting("aspectDepend", "marquee_skewY");
    // marqueeBkg.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    // marqueeBkg.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    // marqueeBkg.rotation = Setting("aspectDepend", "marquee_rotation");
    marqueeBkg.trigger = Transition.EndNavigation;
    marqueeBkg.preserve_aspect_ratio = false;

    local marquee = FadeArt("marquee", blip*0.12988, blip*0.05371, blip*0.40918, blip*0.10254 );
    // marquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    // marquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    // marquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    // marquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    // marquee.rotation = Setting("aspectDepend", "marquee_rotation");
    marquee.trigger = Transition.EndNavigation;
    marquee.preserve_aspect_ratio = false;
}

//marquee  ------------------------------------------ END



//marquee (with emulator name)   ---------------------- START

if ( my_config["marquee_type"] == "emulator-name" )

{
    local emuMarquee = fe.add_image("[Emulator]" + "-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    // emuMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    // emuMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    // emuMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    // emuMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    // emuMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
    emuMarquee.trigger = Transition.EndNavigation;
    emuMarquee.preserve_aspect_ratio = false;
}



//marquee (my own image) ----------------------------- START

if ( my_config["marquee_type"] == "my-own" )
{
    local myOwnMarquee = fe.add_image("my-own-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
    // myOwnMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
    // myOwnMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
    // myOwnMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
    // myOwnMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
    // myOwnMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
    myOwnMarquee.trigger = Transition.EndNavigation;
    myOwnMarquee.preserve_aspect_ratio = false;
}






//cabinet image -------------------------------------- START
// local cab = fe.add_image( "cabinet/vewlix_white.png", 0, 0, blip*0.992, blip*1.008);
// cab.preserve_aspect_ratio = true;







//LCD display text under cab screen ------------------------------------------------ START

// local lcdLeftText = fe.add_text( "PLAYED: " + "[PlayedCount]", blip*0.1021, blip*0.2728, blip*0.231, blip*0.04 );  // here you can change what is displayed on left side
local lcdLeftText = fe.add_text( "YEAR: " + "[Year]", blip*0.1021, blip*0.2728, blip*0.231, blip*0.04 );
lcdLeftText.set_rgb( 170, 220, 240);
lcdLeftText.align = Align.Centre;  
// lcdLeftText.rotation = -6.5;
lcdLeftText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font



if ( my_config["lcdRight"] == "filter" )
{
    local lcdRightText = fe.add_text( "[FilterName]", blip*0.375, blip*0.2728, blip*0.231, blip*0.04 );
    lcdRightText.set_rgb( 170, 220, 240);
    lcdRightText.align = Align.Centre;
    // lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "rom-filename" )
{
    local lcdRightText = fe.add_text( "[Name]", blip*0.375, blip*0.2728, blip*0.231, blip*0.04 );
    lcdRightText.set_rgb( 170, 220, 240);
    lcdRightText.align = Align.Centre;
    // lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "display-name" )
{
    local lcdRightText = fe.add_text( "[DisplayName]", blip*0.375, blip*0.2728, blip*0.231, blip*0.04 );
    lcdRightText.set_rgb( 170, 220, 240);
    lcdRightText.align = Align.Centre;
    // lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "emulator" )
{
    local lcdRightText = fe.add_text( "[Emulator]", blip*0.375, blip*0.2728, blip*0.231, blip*0.04 );
    lcdRightText.set_rgb( 170, 220, 240);
    lcdRightText.align = Align.Centre;
    // lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "off" )
{
    local lcdRightText = fe.add_text( my_config["lcdRightText"], blip*0.375, blip*0.2728, blip*0.231, blip*0.04 );
    lcdRightText.set_rgb( 170, 220, 240);
    lcdRightText.align = Align.Centre;
    // lcdRightText.rotation = -6.6;
    lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}

//LCD display text --------------------------------------------------------- END

 







// SpinWheel -------------------------- START - this part is slightly modified code from omegaman's ROBOSPIN theme

 
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.87, flx*0.79, flx*0.765, flx*0.745, flx*0.73, flx*0.72, flx*0.67, flx*0.72, flx*0.73, flx*0.745, flx*0.765, flx*0.79, ]; 
local wheel_y = [ -fly*0.22, -fly*0.105, fly*0.0, fly*0.105, fly*0.215, fly*0.325, fly*0.436, fly*0.61, fly*0.72 fly*0.83, fly*0.935, fly*0.99, ];
local wheel_w = [ flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.28, flw*0.18, flw*0.18, flw*0.18, flw*0.18, flw*0.18, ];
local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
local wheel_h = [  flw*0.07,  flw*0.07,  flw*0.07,  flw*0.08,  flw*0.08,  flw*0.08, flw*0.11,  flw*0.07,  flw*0.07,  flw*0.07,  flw*0.07,  flw*0.07, ];
//local wheel_r = [  31,  26,  21,  16,  11,   6,   0, -11, -16, -21, -26, -31, ];
local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
local num_arts = Setting("aspectDepend", "wheelNumElements");  // number of elements in wheel - depending on screen aspect ratio




class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["spinwheelArt"] ) );
        preserve_aspect_ratio = true;
        video_flags=Vid.ImagesOnly; // added just in case if you have video marquees - like I do :)
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)

for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }






// 게임 개발사 로고 표시 ----------------------------------------------------------- START

// local dpLogo = fe.add_image( "logo/[Manufacturer].png", flx*0.31, fly*0.16, flw*0.16, flh*0.12  );
// dpLogo.preserve_aspect_ratio = true;

// local move_dp = {
//     when = Transition.ToNewSelection, property = "alpha", start = 0, end = 255, time = 1500
// }
// animation.add( PropertyAnimation( dpLogo, move_dp ) );

local titleText = fe.add_text( "[Title]", flx*0.11913, fly*0.6401, flw*0.307, flh*0.024  );
titleText.align = Align.Centre;
titleText.set_rgb(170,220,240);
titleText.font = "NanumBarunGothicBold";

// local titleText = fe.add_text( "© [Year] [Manufacturer]", flx*0.31, fly*0.325, flw*0.6, flh*0.0235  );
// titleText.align = Align.Left;
// titleText.set_rgb(170,220,240);
// titleText.font = "NanumBarunGothicBold";

// local titleText = fe.add_text( "[Category]", flx*0.312, fly*0.360, flw*0.6, flh*0.0235  );
// titleText.align = Align.Left;
// titleText.set_rgb(170,220,240);
// titleText.font = "NanumBarunGothicBold";

// 게임 개발사 로고 표시 -------------------------------------------------------END






// 게임 리스트 박스 표시 ------------------------------------------------ START

if ( my_config["spinwheelArt"] == "list box" )
{
    // 게임 리스트 배경
    local listbg = fe.add_image("listbox/listbox_34.png", flw*0.53125, flh*0.0185185, flw*0.453125, flh*0.96852 );
    listbg.alpha = 150;


    // 게임 캐릭터 이미지 표시 (권장 이미지 사이즈: 480x760)
    if ( my_config["select_character"] == "By Display" )
    {
        local mascot = fe.add_image ("character/[DisplayName].png", 0.65*flw, 0.20625*flh, 480, 760);
        mascot.alpha = abs(("0" + my_config["character_alpha"]).tointeger()) % 256;
        mascot.preserve_aspect_ratio = true;
    }

    if ( my_config["select_character"] == "By Game" )
    {
        ::OBJECTS <- {
        effect = fe.add_artwork( "character", 0.65*flw, 0.20625*flh, 480, 760 ),
        }

        local move_effect1 = {
            when = Transition.ToNewSelection, property = "alpha", start = 80, end = 255, time = 700
        }
        
        animation.add( PropertyAnimation( OBJECTS.effect, move_effect1 ) );
        OBJECTS.effect.trigger = Transition.EndNavigation;
    }


    // 에뮬 디스플레이 타이틀
    local displayName = fe.add_image ("wheel/[DisplayName]", flw*0.56771, flh*0.02222, flw*0.3906, flh*0.1852 );




    // 게임선택 박스 --------------------------- START

    if ( my_config["select_box_color"] == "blue" )
    {
        fe.add_image( "listbox/box_blue.png", flw*0.534896, flh*0.507407407, flw*0.445833, flh*0.074074074 );
    }

    if ( my_config["select_box_color"] == "green" )
    {
        fe.add_image( "listbox/box_green.png", flw*0.534896, flh*0.507407407, flw*0.445833, flh*0.074074074 );
    }

    if ( my_config["select_box_color"] == "pink" )
    {
        fe.add_image( "listbox/box_pink.png", flw*0.534896, flh*0.507407407, flw*0.445833, flh*0.074074074 );
    }

    // 게임선택 박스 --------------------------- END




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
    local clockbtext = fe.add_text( "현재시각:", flw*0.528515625, flh*0.92962963, flw*0.124166667, flh*0.042592593 );
    clockbtext.set_rgb( 0, 0, 0 );
    clockbtext.charsize = 36;

    local clocktext = fe.add_text( "현재시각:", flw*0.5269140625, flh*0.926851852, flw*0.124166667, flh*0.042592593 );
    clocktext.set_rgb( 211, 250, 255 );
    clocktext.charsize = 36;

    local clockb = fe.add_text( "", flw*0.6283333337, flh*0.92962963, flw*0.166666667, flh*0.042592593  );
    clockb.align = Align.Left;
    clockb.charsize = 36;
    clockb.set_rgb( 0, 0, 0 );

    local clock = fe.add_text( "", flw*0.6267083337, flh*0.926851852, flw*0.166666667, flh*0.042592593  );
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
}

// 게임 리스트 박스 표시 --------------------------------------------------------- END






// 즐겨찾기 아이콘 표시 ------------------------------------------------ START

local romFav;

function getFavs(index_offset)
{
    if (fe.game_info( Info.Favourite, index_offset ) == "1") return "★.png";
    else return "";
}

if ( my_config["spinwheelArt"] == "list box" )
{
    local listFav = fe.add_listbox( flw*0.494, flh*0.2037037, flw*0.03125, flh*0.6759259 );
    listFav.charsize = 30;
    listFav.set_sel_rgb( 255, 255, 0 );
    listFav.set_rgb( 255, 255, 0 );
    listFav.selbg_alpha = 0;
    listFav.align = Align.Left;
    listFav.format_string = "[!getFavs]";

    romFav = fe.add_image( getFavs(0), flw*0.5, flh*0.5185, flw*0.03125, flw*0.03125 );
}
else
{
    romFav = fe.add_image( getFavs(0), flx*0.312, fly*0.40, flw*0.03125, flw*0.03125 );
}

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
        else romFav.file_name = "★.png";
    }
}

// 즐겨찾기 아이콘 표시 --------------------------------------------------------- END




// 조작키 안내
fe.add_image("key/" + my_config["select_keyinfo"] + ".png", flw*0.01823, flh*0.9167, flw*0.4948, flh*0.07037 );
