// -------------------------------------------------------
//
// "NEVATO" theme for Attract-Mode Front-End
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


class UserConfig {

</ label="NEVATO theme", help=" ", options=" ", order=1 /> divider1="";
</ label="--------------------------", help=" ", options=" ", order=1 /> divider1="";
//-----------------------------------------------------------------
</ label="글꼴 선택", help="화면에 표시되는 글자 폰트를 변경할 수 있습니다.", options="TmonMonsori,TT,Font,NanumGothicBold,User1,User2,User3", order=2 /> select_font1="Font";
</ label="동영상 음소거", help="방향키(위/아래)를 이용하여, 사운드를 끄려면 yes, 사운드를 켜려면 no를 선택하세요.", options="yes,no", order=2 /> mute_videoSnaps="no";
</ label="모니터 표시항목", help="모니터에 미리보기 동영상을 재생하려면 video를, 스냅샷을 표시하려면 screenshot을 선택하세요.", options="video, screenshot", order=3 /> cabScreenType="video";
</ label="모니터 스캔라인", help="화면 스캔라인의 강도를 선택하거나 스캔라인을 제거할 수 있습니다.", options="light,medium,dark,off", order=4 /> enable_scanlines="light";
</ label="marquee 도안", help="사용자 제작도안을 사용하려면 그림파일명을 ''my-own-marquee.jpg'' 으로 하세요.", options="marquee,wheel,emulator-name,my-own", order=5 /> marquee_type="marquee"; 
</ label="LCD 우측 표시항목", help="표시할 항목을 선택하세요.", options="filter, emulator, display-name, rom-filename, off,", order=6 /> lcdRight="filter"; 
</ label="--------------------------", help=" ", options=" ", order=7 /> divider2="";
//-----------------------------------------------------------------
</ label="게임목록 표시방식", help="회전식 휠메뉴는 marquee 또는 wheel 선택, 목록 상자는 listbox를 선택하세요.", options="marquee,wheel,listbox", order=8 /> spinwheelArt="listbox";
</ label="회전식 휠메뉴의 전환시간", help="전환시간 단위는 밀리세컨드(1/1000초)입니다.", order=9 /> transition_ms="80";
</ label="--------------------------", help=" ", options=" ", order=10 /> divider3="";
//-----------------------------------------------------------------
</ label="배경화면 색상 (레이아웃1)", help="레이아웃1의 배경화면 색상을 선택합니다.", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,none", order=11 /> enable_static_bkg1="gray";
</ label="배경화면 색상 (레이아웃2)", help="레이아웃2의 배경화면 색상을 선택합니다.", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,none", order=12 /> enable_static_bkg2="blue";
</ label="배경화면 색상 (레이아웃3)", help="레이아웃3의 배경화면 색상을 선택합니다.", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,none", order=13 /> enable_static_bkg3="red";
</ label="배경화면 마스크", help="medium 과 dark 중에 선택하거나, 끌 수 있습니다.", options="dark,medium,none", order=14 /> enable_mask="dark";
</ label="배경화면 추가 도안", help="배경화면에 추가로 표시할 항목을 선택합니다. (플라이어/팬아트/스냅샷/동영상/표시안함)", options="flyer,fanart,snap,video,none", order=15 /> enable_bg_art="flyer";
</ label="--------------------------", help=" ", options=" ", order=16 /> divider4="";
//-----------------------------------------------------------------
</ label="게임 캐릭터 이미지 표시방식 지정", help="디스플레이 이름별로, 또는 게임 파일명별로 표시해줄 수 있습니다.", options="By Display,By Game,None", order=17 /> select_character="By Display";
</ label="게임 캐릭터 이미지 선택", help="이 옵션은 게임 캐릭터 표시방식을 디스플레이 이름별(By Display)로 선택했을때만 동작합니다. 번호를 선택하세요.", options="01,02,03", order=18 /> select_character_no="01";
</ label="게임 캐릭터 이미지 투명도 (0~254)", help="투명도를 지정해줄 수 있습니다. 0에 가까울수록 투명해집니다.", options="", order=19 /> select_Alpha3="254";
</ label="조작키 안내", help="조작키 설명 이미지를 표시할 수 있습니다.", options="Arcade,XBOX360,PS Pad,Keyboard,off", order=20 /> select_Keyinfo="Arcade";
}  


local my_config = fe.get_config();

fe.load_module( "fade" );
fe.load_module( "animate" );
fe.load_module( "pan-and-scan" );
fe.layout.font=my_config["select_font1"];

local blip = fe.layout.height;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

//fe.layout.width = 1920;
//fe.layout.height = 1080;

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

        wheelNumElements = 10 }
   },
    "21x9": {
      aspectDepend = { 
        res_x = 1920,
        res_y = 1080,

        maskFactor = 1.9,

        snap_skewX = 62.5, 
        snap_skewY = -12.9, 
        snap_pinchX = 0, 
        snap_pinchY = 40.0, 
        snap_rotation = 1.0, 

        wheelNumElements = 8 }
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

        wheelNumElements = 10 }
   },
    "16x9": {
      aspectDepend = { 
        res_x = 1920,
        res_y = 1080,

        maskFactor = 1.9,

        snap_skewX = 62.5, 
        snap_skewY = -12.9, 
        snap_pinchX = 0, 
        snap_pinchY = 40.0, 
        snap_rotation = 1.0, 

        wheelNumElements = 8 }
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

        wheelNumElements = 10 }
   }
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

        wheelNumElements = 10 }
   }
}


local aspect = fe.layout.width / fe.layout.height.tofloat();
print (aspect);
local aspect_name = "";
switch( aspect.tostring() )
{
    case "2.37037":
        aspect_name = "21x9";
        break;
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
  } else if ( aspect_name in settings == false )
  {
    ::print("\tsettings[" + aspect_name + "] does not exist\n");
  } else if ( name in settings[aspect_name][id] == false )
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

if ( my_config["enable_static_bkg2"] == "none") 
{
 local bg = fe.add_image( "", 0, 0, flw, flh );
}

local bgArt = fe.add_image("bg_" + my_config["enable_static_bkg2"] + ".png", 0, 0, flw, flh );
local bgArt2 = fe.add_clone(bgArt);

animation.add( PropertyAnimation( bgArt, {when = Transition.StartLayout, property = "x", start = 0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end = 0, time = 28000, loop=true}));			
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));


// default background image (if background art is not enabled) ------------- END



// background art --------------------------------------------------------- START

if ( my_config["enable_bg_art"] == "flyer") 
{
// local bgart = fe.add_artwork( "flyer", flw*0.2, 0, flw*0.6, flh);
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

if ( my_config["enable_bg_art"] == "fanart") 
{
 local bgart = FadeArt( "fanart", 0, 0, 0, flh);
 bgart.preserve_aspect_ratio = true;
 local mask = fe.add_image( "mask_edges.png", 0 , 0, mask_factor*flh, flh );  //gradient to mask left and right edge of the flyer
 mask.preserve_aspect_ratio = false;
 //mask.alpha = 255;
}

if ( my_config["enable_bg_art"] == "snap") 
{
 local bgart = fe.add_artwork( "snap", flx-flh*1.34, 0, flh*1.34, 0);
 bgart.preserve_aspect_ratio = true;
 bgart.video_flags=Vid.ImagesOnly;
}


if ( my_config["enable_bg_art"] == "video") 
{
 local bgart = fe.add_artwork( "snap", flx-flh*1.34, 0, flh*1.34, 0);
 bgart.preserve_aspect_ratio = true;
 bgart.video_flags = videoSound;
}



// background art --------------------------------------------------------- END



//masking background (adding scanlines and vignette) -------------------- START

if ( my_config["enable_mask"] == "none" )
{
local masking = fe.add_image( "", 0, 0, flw, 0 );
}


if ( my_config["enable_mask"] == "medium" )
{
local masking = fe.add_image( "background_mask.png", 0, 0, flx, fly );
masking.preserve_aspect_ratio = false;
masking.alpha = 150;           // here you can change mask opacity light=100, medium=150, dark (default)=255
local maskingMedium = fe.add_image( "background_mask_medium.png", 0, 0, flx, fly );
maskingMedium.preserve_aspect_ratio = false;
}


if ( my_config["enable_mask"] == "dark" )
{
local masking = fe.add_image( "background_mask_scanline.png", 0, 0, flx,fly);   //for 4:3 fix 1.6*fly
masking.preserve_aspect_ratio = false;
masking.alpha = 255;           // here you can change mask opacity light=100, medium=150, dark (default)=255
}

//masking background (adding scanlines and vignette) -------------------- END


//static tv effect on cab screen snap change (of if no snap at all) ------------- START

local tvStatic = fe.add_image( "static.jpg", blip*0.128, blip*0.302, blip*0.646, blip*0.480);
//tvStatic.skew_x = Setting("aspectDepend", "snap_skewX");
//tvStatic.skew_y = Setting("aspectDepend", "snap_skewY");
//tvStatic.pinch_x = Setting("aspectDepend", "snap_pinchX");
//tvStatic.pinch_y = Setting("aspectDepend", "snap_pinchY");
//tvStatic.rotation = Setting("aspectDepend", "snap_rotation");



//snap (video or screenshot) on cab screen ------------- START

local cabScreen = fe.add_artwork ("snap", blip*0.128, blip*0.302, blip*0.646, blip*0.480);
//cabScreen.skew_x = Setting("aspectDepend", "snap_skewX");
//cabScreen.skew_y = Setting("aspectDepend", "snap_skewY");
//cabScreen.pinch_x = Setting("aspectDepend", "snap_pinchX");
//cabScreen.pinch_y = Setting("aspectDepend", "snap_pinchY");
//cabScreen.rotation = Setting("aspectDepend", "snap_rotation");
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
local scanlines = fe.add_image( "scanlines.png", blip*0.128, blip*0.302, blip*0.646, blip*0.480 );
//scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
//scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
//scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
//scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
//scanlines.rotation = Setting("aspectDepend", "snap_rotation");
scanlines.preserve_aspect_ratio = false;
scanlines.alpha = 50;
}

if ( my_config["enable_scanlines"] == "medium" )
{
local scanlines = fe.add_image( "scanlines.png", blip*0.128, blip*0.302, blip*0.646, blip*0.480 );
//scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
//scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
//scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
//scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
//scanlines.rotation = Setting("aspectDepend", "snap_rotation");
scanlines.preserve_aspect_ratio = false;
scanlines.alpha = 150;
}

if ( my_config["enable_scanlines"] == "dark" )
{
local scanlines = fe.add_image( "scanlines.png", blip*0.128, blip*0.302, blip*0.646, blip*0.480 );
//scanlines.skew_x = Setting("aspectDepend", "snap_skewX");
//scanlines.skew_y = Setting("aspectDepend", "snap_skewY");
//scanlines.pinch_x = Setting("aspectDepend", "snap_pinchX");
//scanlines.pinch_y = Setting("aspectDepend", "snap_pinchY");
//scanlines.rotation = Setting("aspectDepend", "snap_rotation");
scanlines.preserve_aspect_ratio = false;
scanlines.alpha = 200;
}

//scanlines over cab screen --------------------------- END






//marquee  ------------------------------------------ START

if ( my_config["marquee_type"] == "marquee" )
{
local marqueeBkg0 = fe.add_image("static.jpg", blip*0.0639, blip*0.0037, blip*0.774, blip*0.206 );
local marqueeBkg = fe.add_image("[marquee]", blip*0.0639, blip*0.0037, blip*0.774, blip*0.206 );
//marqueeBkg.skew_x = Setting("aspectDepend", "marquee_skewX");
//marqueeBkg.skew_y = Setting("aspectDepend", "marquee_skewY");
//marqueeBkg.pinch_x = Setting("aspectDepend", "marquee_pinchX");
//marqueeBkg.pinch_y = Setting("aspectDepend", "marquee_pinchY");
//marqueeBkg.rotation = Setting("aspectDepend", "marquee_rotation");
marqueeBkg.trigger = Transition.EndNavigation;
marqueeBkg.preserve_aspect_ratio = false;

local marquee = FadeArt("marquee", blip*0.0639, blip*0.0037, blip*0.774, blip*0.206 );
//marquee.skew_x = Setting("aspectDepend", "marquee_skewX");
//marquee.skew_y = Setting("aspectDepend", "marquee_skewY");
//marquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
//marquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
//marquee.rotation = Setting("aspectDepend", "marquee_rotation");
marquee.trigger = Transition.EndNavigation;
marquee.preserve_aspect_ratio = false;
}

//marquee  ------------------------------------------ END



//marquee (with emulator name)   ---------------------- START

if ( my_config["marquee_type"] == "emulator-name" )

{
local emuMarquee = fe.add_image("[Emulator]" + "-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
//emuMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
//emuMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
//emuMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
//emuMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
//emuMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
emuMarquee.trigger = Transition.EndNavigation;
emuMarquee.preserve_aspect_ratio = false;
}



//marquee (my own image) ----------------------------- START

if ( my_config["marquee_type"] == "my-own" )
{
local myOwnMarquee = fe.add_image("my-own-marquee.jpg", blip*0.1032, blip*0.0763, blip*0.3984, blip*0.1349 );
//myOwnMarquee.skew_x = Setting("aspectDepend", "marquee_skewX");
//myOwnMarquee.skew_y = Setting("aspectDepend", "marquee_skewY");
//myOwnMarquee.pinch_x = Setting("aspectDepend", "marquee_pinchX");
//myOwnMarquee.pinch_y = Setting("aspectDepend", "marquee_pinchY");
//myOwnMarquee.rotation = Setting("aspectDepend", "marquee_rotation");
myOwnMarquee.trigger = Transition.EndNavigation;
myOwnMarquee.preserve_aspect_ratio = false;
}


//cabinet image -------------------------------------- START
local cab = fe.add_image( "cab_body_wonhoz.png", 0, 0, blip*1.7778, blip);
cab.preserve_aspect_ratio = true;


//LCD display text under cab screen ------------------------------------------------ START

local lcdLeftText1 = fe.add_text( "PLAYED: " + "[PlayedCount]", blip*0.528, blip*0.2378, blip*0.231, blip*0.04 );  // here you can change what is displayed on left side
local lcdLeftText2 = fe.add_text( "YEAR: " + "[Year]", blip*0.1621, blip*0.2378, blip*0.231, blip*0.04 );
lcdLeftText1.set_rgb( 170, 220, 240);
lcdLeftText1.align = Align.Centre;  
lcdLeftText2.set_rgb( 170, 220, 240);
lcdLeftText2.align = Align.Centre;  
// lcdLeftText.rotation = -6.5;
lcdLeftText1.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
lcdLeftText2.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font


if ( my_config["lcdRight"] == "filter" )
{
local lcdRightText = fe.add_text( "[FilterName]", blip*0.345, blip*0.2378, blip*0.231, blip*0.04 );
lcdRightText.set_rgb( 170, 220, 240);
lcdRightText.align = Align.Centre;
// lcdRightText.rotation = -6.6;
lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "rom-filename" )
{
local lcdRightText = fe.add_text( "[Name]", blip*0.345, blip*0.2378, blip*0.231, blip*0.04 );
lcdRightText.set_rgb( 170, 220, 240);
lcdRightText.align = Align.Centre;
// lcdRightText.rotation = -6.6;
lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "display-name" )
{
local lcdRightText = fe.add_text( "[DisplayName]", blip*0.345, blip*0.2378, blip*0.231, blip*0.04 );
lcdRightText.set_rgb( 170, 220, 240);
lcdRightText.align = Align.Centre;
// lcdRightText.rotation = -6.6;
lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "emulator" )
{
local lcdRightText = fe.add_text( "[Emulator]", blip*0.345, blip*0.2378, blip*0.231, blip*0.04 );
lcdRightText.set_rgb( 170, 220, 240);
lcdRightText.align = Align.Centre;
// lcdRightText.rotation = -6.6;
lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}


if ( my_config["lcdRight"] == "off" )
{
local lcdRightText = fe.add_text( my_config["lcdRightText"], blip*0.345, blip*0.2378, blip*0.231, blip*0.04 );
lcdRightText.set_rgb( 170, 220, 240);
lcdRightText.align = Align.Centre;
// lcdRightText.rotation = -6.6;
lcdRightText.font="digital-7 (italic)";  // free font (for personal use) - can be downloaded here: http://www.dafont.com/digital-7.font
}

//LCD display text --------------------------------------------------------- END



//Display Name ----------------------------------------------------------- START

//local dpLogo = fe.add_image( "Logos/[Manufacturer].png", flx*0.31, fly*0.16, flw*0.16, flh*0.12  );
//dpLogo.preserve_aspect_ratio = true;

//local move_dp = {
//       when = Transition.ToNewList, property = "alpha", start = 0, end = 255, time = 1500
// }
// animation.add( PropertyAnimation( dpLogo, move_dp ) );

//local titleText = fe.add_text( "[Title]", flx*0.07313, fly*0.7991, flw*0.307, flh*0.024  );
//titleText.align = Align.Centre;
//titleText.set_rgb(170,220,240);
//titleText.font = "NanumBarunGothicBold";

//local titleText = fe.add_text( "© [Year] [Manufacturer]", flx*0.31, fly*0.325, flw*0.6, flh*0.0235  );
//titleText.align = Align.Left;
//titleText.set_rgb(170,220,240);
//titleText.font = "NanumBarunGothicBold";

//local titleText = fe.add_text( "[Category]", flx*0.312, fly*0.360, flw*0.6, flh*0.0235  );
//titleText.align = Align.Left;
//titleText.set_rgb(170,220,240);
//titleText.font = "NanumBarunGothicBold";


//Display Name -------------------------------------------------------END 




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


if ( my_config["spinwheelArt"] == "listbox" )
{
// 게임 리스트 배경
local listbg = fe.add_artwork("list_bg.png",flw*0.53125, flh*0.0185185, flw*0.453125, flh*0.96852 );
listbg.alpha = 150;

// 게임 캐릭터 이미지 표시 (기본 이미지 사이즈: 480x760)
if ( my_config["select_character"] == "By Display" )
{
	local mascot = fe.add_image ("Display/[DisplayName]" + "_character_" + my_config["select_character_no"] +".png",1440, 200, 480, 760);
	mascot.alpha = abs(("0"+my_config["select_Alpha3"]).tointeger()) % 255;;
	mascot.preserve_aspect_ratio = true;
}

if ( my_config["select_character"] == "By Game" )
{
::OBJECTS <- {
 effect = fe.add_artwork( "character", 1440, 200, 480, 760 ),
}

  local move_effect1 = {
 	when = Transition.ToNewSelection, property = "alpha", start = 80, end = 255, time = 700
 }
 animation.add( PropertyAnimation( OBJECTS.effect, move_effect1 ) );
 OBJECTS.effect.trigger = Transition.EndNavigation;
 }

// 에뮬 디스플레이 타이틀
local displayName = fe.add_image ("Display/[DisplayName]",flw*0.56771, flh*0.02222, flw*0.3906, flh*0.1852);

// 게임선택 박스
fe.add_image("box_blue.png", flw*0.534896, flh*0.507407407, flw*0.445833, flh*0.074074074 );


// 리스트 게임번호 그림자
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
 function gamename( index_offset ) {
  local s = split( fe.game_info( Info.Title, index_offset ), "[/" );
 	if ( s.len() > 0 ) return s[0];
  return "";
}

// 시계
local clockbtext = fe.add_text( "TIME:", flw*0.515625, flh*0.92962963, flw*0.104166667, flh*0.042592593 );
clockbtext.set_rgb( 0, 0, 0 );
clockbtext.charsize = 36;

local clocktext = fe.add_text( "TIME:", flw*0.5140625, flh*0.926851852, flw*0.104166667, flh*0.042592593 );
clocktext.set_rgb( 211, 250, 255 );
clocktext.charsize = 36;

local clockb = fe.add_text( "", flw*0.604166667, flh*0.92962963, flw*0.166666667, flh*0.042592593  );
clockb.align = Align.Left;
clockb.charsize = 36;
clockb.set_rgb( 0, 0, 0 );

local clock = fe.add_text( "", flw*0.602604167, flh*0.926851852, flw*0.166666667, flh*0.042592593  );
clock.align = Align.Left;
clock.charsize = 36;
clock.set_rgb( 73, 223, 222 );

function update_clock( ttime ){
  local now = date();
  clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
  clock.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );

// 즐겨찾기 필터
local listtextb = fe.add_text( "[!filter] 게임:", flw*0.708333333, flh*0.92962963, flw*0.234375, flh*0.042592593 );
listtextb.set_rgb( 208, 56, 0 );
listtextb.charsize = 36;
listtextb.align = Align.Left;

local listtext = fe.add_text( "[!filter] 게임:", flw*0.706770833, flh*0.926851852, flw*0.234375, flh*0.042592593 );
listtext.set_rgb( 255 243, 20 );
listtext.charsize = 36;
listtext.align = Align.Left;

// Change filter name to upper case
 function filter(){
	local text = fe.filters[fe.list.filter_index].name;

                if (text == "Favourites")
                text = "즐겨찾기"
		
		return text.toupper();
 }

local listb = fe.add_text("[ListSize]", flw*0.9140625, flh*0.92962963, flw*0.104166667, flh*0.042592593 );
listb.set_rgb( 0, 0, 0 );
listb.charsize=36;
listb.align = Align.Left;

local list = fe.add_text( "[ListSize]", flw*0.9125, flh*0.926851852, flw*0.104166667, flh*0.042592593 );
list.set_rgb( 73, 223, 222 );
list.charsize=36;
list.align = Align.Left;
}


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


// 즐겨찾기 아이콘 표시

if ( my_config["spinwheelArt"] == "listbox" )
{
function getFavs(index_offset){
  if(fe.game_info( Info.Favourite, index_offset ) == "1") return "fav.png";
  else return "";
}
local romFav = fe.add_image(getFavs(0), flw*0.5, flh*0.5185, flw*0.03125, flh*0.0555 );

fe.add_transition_callback( "update_my_list" );
function update_my_list( ttype, var, ttime )
{
    if(ttype == Transition.ToNewSelection){
        romFav.file_name = getFavs(var);
    }
    return false;
}
}

if ( my_config["spinwheelArt"] != "listbox" )
{
function getFavs(index_offset){
  if(fe.game_info( Info.Favourite, index_offset ) == "1") return "fav.png";
  else return "";
}
local romFav = fe.add_image(getFavs(0), flx*0.412, fly*0.2378, flw*0.03125, flh*0.0555 );

fe.add_transition_callback( "update_my_list" );
function update_my_list( ttype, var, ttime )
{
    if(ttype == Transition.ToNewSelection){
        romFav.file_name = getFavs(var);
    }
    return false;
}
}

fe.add_signal_handler( "updateFavs" );
function updateFavs( signal_str )
{
    if(signal_str == "add_favourite"){
        if(romFav.file_name != "") romFav.file_name = "";
        else romFav.file_name = "fav.png";
    }
}

// 조작키 안내
fe.add_image("key_" + my_config["select_Keyinfo"] + ".png", flw*0.01823, flh*0.9167, flw*0.4948, flh*0.07037 );
