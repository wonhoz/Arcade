//
// Attract-Mode Front-End - "Consol Box" layout
// Made by CSOne 2018.11.06
//

class UserConfig { 
</ label="Enable CRT effect", help="Enable CRT effect", options="Yes,No", order=1 /> enable_crt="No";
</ label="Select Character", help="Select Character Image's Display Type", options="By Display,By Game,None", order=2 /> select_character="By Display";
</ label="Select Character No.", help="[By Display] type only. Select Image Number.", options="01,02,03", order=2 /> select_character_no="01";
</ label="Character Image Alpha (0~254)", help="Input Character Image Alpha value 0~254", options="", order=3 /> select_Alpha="254";
</ label="Enable Flyer Image", help="Enable List Box's Backgound Image (Flyer)", options="Yes,No", order=4 /> enable_flyer="Yes";
</ label="Flyer Image Alpha (0~254)", help="Input Flyer Image Alpha value 0~254", options="", order=5 /> select_Alpha2="120"; 
</ label="Game Logo Animation", help="Animated game's marquee image.", options="Yes,No", order=6 /> enable_gamelogo="Yes";
</ label="History.dat", help="History.dat location. Be sure to enable and config History.dat from the plugins menu.", order=8 />
	dat_path=".\\history.dat";  
</ label="BG Artwork (NEC PC-Engine)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=9 /> 
   select_bgArt_pce="pink";
</ label="BG Artwork (NEC PC-Engine CD-ROM)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=10 /> 
   select_bgArt_pcecd="pink";
</ label="BG Artwork (NEC PC-FX)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=11 /> 
   select_bgArt_pcfx="pink";
</ label="BG Artwork (Nintendo Famicom)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=12 /> 
   select_bgArt_nes="orange";
</ label="BG Artwork (Nintendo Super Famicom)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=13 /> 
   select_bgArt_snes="gray2"
</ label="BG Artwork (Nintendo GameBoy Advance)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=14 /> 
   select_bgArt_gba="gray";  
</ label="BG Artwork (Nintendo Nintendo 64)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=15 /> 
   select_bgArt_n64="green2";
</ label="BG Artwork (Nintendo GameCube & Wii)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=16 /> 
   select_bgArt_gc="green";
</ label="BG Artwork (SEGA Master System)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=17 /> 
   select_bgArt_sms="red";
</ label="BG Artwork (SEGA Mega Drive)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=18 /> 
   select_bgArt_md="orange";
</ label="BG Artwork (SEGA MEGA-CD)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=19 /> 
   select_bgArt_mcd="retro";
</ label="BG Artwork (Neogeo CD)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=20 /> 
   select_bgArt_neocd="gray";
</ label="BG Artwork (LG 3DO ALIVE)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=26 /> 
   select_bgArt_3do="orange";
</ label="BG Artwork (SEGA Saturn)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=20 /> 
   select_bgArt_ss="gray";
</ label="BG Artwork (SEGA DreamCast)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=21 /> 
   select_bgArt_dc="pink";  
</ label="BG Artwork (MSX)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=22 /> 
   select_bgArt_msx="blue2";
</ label="BG Artwork (GP32)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=23 /> 
   select_bgArt_gp32="orange";
</ label="BG Artwork (SONY Play Station)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=24 /> 
   select_bgArt_ps1="retro";
</ label="BG Artwork (SONY Play Station 2)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=25 /> 
   select_bgArt_ps2="gray";
</ label="BG Artwork (SONY Play Station Portable)", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=26 /> 
   select_bgArt_psp="gray";
</ label="Select Artwork Image", help="Selected Artwork Image is displayed at the right of consol game machine.", options="Cartridge_Disc,3D Box,None", order=27 /> enable_boximage="cartridge_disc";
}  

// 변수지정 및 폰트 및 화면 해상도
local my_config = fe.get_config();
local bgArt;
local bgArt2;
fe.layout.font="font";
fe.layout.width=1920;
fe.layout.height=1080;
local flw = fe.layout.width;
local flh = fe.layout.height;
fe.layout.preserve_aspect_ratio = true;
// Include the utilities to read the history.dat file
dofile(fe.script_dir + "file_util.nut" );

// 이미지 변형 변수값 지정
// local snap_skewX = 62.5
// local snap_skewY = -12.9
// local snap_pinchX = 0
// local snap_pinchY = 40.0
// local snap_rotation = 1.0


// 백그라운드 지정 및 스크롤 애니메이션 효과
if ( my_config["select_bgArt_pcecd"] == "video" ){
bgArt = fe.add_artwork("bg.mp4", 0, 0, flw, flh );
}
bgArt = fe.add_image("bg_" + my_config["select_bgArt_pcecd"] + ".png", 0, 0, flw, flh );
bgArt2 = fe.add_clone(bgArt);

fe.load_module("animate");
animation.add( PropertyAnimation( bgArt, {when = Transition.StartLayout, property = "x", start = 0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end = 0, time = 28000, loop=true}));			
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));

// 동영상 뒷배경
local blackbg = fe.add_artwork( "black.png", 117, 143, 720, 542 );

// 모니터와 콘솔기기
fe.add_image( "monitor.png", 52, 73, 849, 812);
fe.add_image( "consol_pcecd.png", 70, 825, 654, 238);

// 동영상
local snap = fe.add_artwork( "snap", 123, 151, 707, 529 );
//snap.preserve_aspect_ratio = true;
snap.trigger = Transition.EndNavigation;
fe.add_image( "scanline.png", 123, 151, 708, 529);

// 게임 리스트 배경
local listbg = fe.add_artwork("list_bg.png",1000, 20, 870, 1046 );
listbg.alpha = 150;

// 리스트 박스 백그라운드 이미지 선택
if ( my_config["enable_flyer"] == "Yes" )
{
	local flyer = fe.add_artwork("flyer",1008, 222, 854, 738 );
	flyer.alpha = abs(("0"+my_config["select_Alpha2"]).tointeger()) % 255;;
	flyer.trigger = Transition.EndNavigation;
}

// 게임 캐릭터 이미지 표시 (권장 이미지 사이즈: 480x760)
if ( my_config["select_character"] == "By Display" )
{
	local mascot = fe.add_image ("systems/[DisplayName]" + "_character_" + my_config["select_character_no"] +".png",1370, 200 );
	mascot.alpha = abs(("0"+my_config["select_Alpha"]).tointeger()) % 255;;
	mascot.preserve_aspect_ratio = true;
}
//flyer.preserve_aspect_ratio = true;


// 게임 휠 이미지
//local bluebg2 = fe.add_artwork("bg_marquee_1.png",448, 342, 350, 75 );

// Class to assign the history.dat information
// to a text object called ".currom"

	function get_hisinfo() 
	{ 
		local sys = split( fe.game_info( Info.System ), ";" );
		local rom = fe.game_info( Info.Name );
		local text = ""; 
		local currom = "";

		// 
		// we only go to the trouble of loading the entry if 
		// it is not already currently loaded 
		// 
		
		local alt = fe.game_info( Info.AltRomname );
		local cloneof = fe.game_info( Info.CloneOf );
		local lookup = get_history_offset( sys, rom, alt, cloneof );
		
		if ( lookup >= 0 ) 
		{ 

			text = get_history_entry( lookup, my_config );
 			local index = text.find("- TECHNICAL -");
			if (index >= 0)
			{	
				local tempa = text.slice(0, index);
				text = strip(tempa);
			} 
		
	 
		} else { 
			if ( lookup == -2 ) 
				text = "Index file not found.  Try generating an index from the history.dat plug-in configuration menu.";
			else 
				text = "No Information available for:  " + rom; 
		}  
		return text;
	}



//Game Marquee Animation
::OBJECTS <- {
 marquee = fe.add_artwork( "marquee", 295, 20, 360, 120 ),
}


if ( my_config["enable_gamelogo"] == "Yes" )
{
 local move_marquee1 = {
    when = Transition.ToNewSelection ,property = "y", start = 0, end = 30, time = 100
 }

 local move_marquee2 = {
    when = Transition.ToNewSelection ,property = "y", start = 30, end = 20, delay = 100, time = 300
 }

 animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee1 ) );
 animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee2 ) );

}

OBJECTS.marquee.trigger = Transition.EndNavigation;


// 에뮬 디스플레이 타이틀
local displayName = fe.add_image ("systems/[DisplayName]",1210, 24, 450, 200);

// 게임선택 박스
fe.add_image("box_purple.png", 1007, 548, 856, 80 );

// 리스트 게임번호 그림자
local listbox1b = fe.add_listbox( 1020, 230, 345, 730 );
listbox1b.charsize = 40;
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0, 0, 0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.font="texgyreheros-bold";
listbox1b.format_string = "[ListEntry]";

// 리스트 박스 게임번호
local listbox1 = fe.add_listbox( 1017, 227, 345, 730 );
listbox1.charsize = 40;
listbox1.set_sel_rgb( 255 243, 20 );
listbox1.set_rgb( 73, 223, 222 );
listbox1.selbg_alpha = 0;
listbox1.align = Align.Left;
listbox1.font="texgyreheros-bold";
listbox1.format_string = "[ListEntry]";

// 리스트 박스 게임이름 그림자
local listbox2b = fe.add_listbox( 1120, 223, 720, 730 );
listbox2b.charsize = 36;
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;
listbox2b.format_string = "[!gamename]";

// 리스트 박스 게임이름
local listbox2 = fe.add_listbox( 1117, 220, 720, 730 );
listbox2.charsize = 36;
listbox2.set_sel_rgb( 255 243, 20 );
listbox2.set_rgb( 240, 240, 240 );
listbox2.selbg_alpha = 0;
listbox2.align = Align.Left;
listbox2.format_string = "[!gamename]";


// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
 function gamename( index_offset ) {
  local s = split( fe.game_info( Info.Title, index_offset ), "/[" );
 	if ( s.len() > 0 ) return s[0];
  return "";
}



// 시계
local clockbtext = fe.add_text( "TIME:", 970, 1004, 200, 46 );
clockbtext.set_rgb( 0, 0, 0 );
clockbtext.font="Ticketbook W01 Bold";

local clocktext = fe.add_text( "TIME:", 967, 1001, 200, 46 );
clocktext.set_rgb( 211, 250, 255 );
clocktext.font="Ticketbook W01 Bold";

local clockb = fe.add_text( "", 1140, 1009, 320, 46  );
clockb.align = Align.Left;
clockb.font="texgyreheros-bold";
clockb.set_rgb( 0, 0, 0 );

local clock = fe.add_text( "", 1137, 1006, 320, 46  );
clock.align = Align.Left;
clock.font="texgyreheros-bold";
clock.set_rgb( 73, 223, 222 );

function update_clock( ttime ){
  local now = date();
  clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
  clock.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );

// 즐겨찾기 필터
local listtextb = fe.add_text( "[!filter] GAMES:", 1340, 1004, 450, 46 );
listtextb.set_rgb( 0, 0, 0 );
listtextb.font="Ticketbook W01 Bold";
listtextb.align = Align.Left;

local listtext = fe.add_text( "[!filter] GAMES:", 1337, 1001, 450, 46 );
listtext.set_rgb( 211, 250, 255 );
listtext.font="Ticketbook W01 Bold";
listtext.align = Align.Left;

// Change filter name to upper case
 function filter(){
	local text = fe.filters[fe.list.filter_index].name;

                if (text == "Favourites")
                text = "즐겨잦기"
		
		return text.toupper();
 }

local listb = fe.add_text("[ListSize]", 1710, 1009, 200, 46 );
listb.set_rgb( 0, 0, 0 );
listb.font="texgyreheros-bold";
listb.align = Align.Left;

local list = fe.add_text( "[ListSize]", 1707, 1006, 200, 46 );
list.set_rgb( 73, 223, 222 );
list.font="texgyreheros-bold";
list.align = Align.Left;


if ( my_config["enable_crt"] == "Yes" )
{
 fe.add_image( "scanline.png", 0, 0, 1920, 1080);
}


// 게임 캐릭터 이미지 표시 (권장 이미지 사이즈: 480x760)
if ( my_config["select_character"] == "By Game" )
{
::OBJECTS <- {
 effect = fe.add_artwork( "character", 1490, 200 ),
}
 local move_effect1 = {
    when = Transition.ToNewSelection ,property = "x", start = 1920, end = 1490, time = 300
 }
  local move_effect2 = {
 	when = Transition.ToNewSelection, property = "alpha", start = 80, end = 255, time = 700
 }
 animation.add( PropertyAnimation( OBJECTS.effect, move_effect1 ) );
 animation.add( PropertyAnimation( OBJECTS.effect, move_effect2 ) );
 OBJECTS.effect.trigger = Transition.EndNavigation;
}


// 2D 또는 3D 박스 이미지 표시
if ( my_config["enable_boximage"] == "Cartridge_Disc" )
{
	local boximage = fe.add_artwork("cartridge_disc",700, 790, 270, 270 );
	boximage.preserve_aspect_ratio = true;
	local move_boximage = {
       when = Transition.ToNewSelection, property = "alpha", start = 0, end = 254, time = 800
	}
	animation.add( PropertyAnimation( boximage, move_boximage ) );
}

if ( my_config["enable_boximage"] == "3D Box" )
{
	local boximage2 = fe.add_artwork("3dbox",700, 790, 270, 270 );
	boximage2.preserve_aspect_ratio = true;
	local move_boximage2 = {
       when = Transition.ToNewSelection, property = "alpha", start = 0, end = 254, time = 800
	}
	animation.add( PropertyAnimation( boximage2, move_boximage2 ) );
}