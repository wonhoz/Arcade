//
// Attract-Mode Front-End - "Pandoras Box" layout
// Renovated by CSOne 2019.01.26
//

class UserConfig { 
</ label="CRT 모니터 효과", help="화면전체에 스탠라인 효과를 줍니다.위아래 방향키로 적용유무를 선택하세요.", options="Yes,No", order=1 /> enable_crt="Yes";
</ label="Flyer 표시", help="리스트에 게임 광고전단 이미지를 보여줍니다.위아래 방향키로 적용유무를 선택하세요.", options="Yes,No", order=2 /> enable_flyer="Yes";
</ label="Flyer 투명도 값 지정", help="0~255 사이의 투명도값을 입력해주세요.값이 작을수록 이미지가 투명하게 표시됩니다.", options="", order=3 /> select_Alpha="70";   
</ label="미리보기 동영상 강제늘리기", help="'Yes' 선택시 미리보기 동영상을 강제로 늘립니다. 'No' 선택시 화면비율을 유지합니다.", options="Yes,No", order=4 /> enable_stretch="Yes";
</ label="History.dat 파일 경로입력", help="History.dat location. Be sure to enable and config History.dat from the plugins menu.", order=5 />
	dat_path=".\\history.dat";  
}  

local my_config = fe.get_config();
fe.layout.font="TmonMonsori";
fe.layout.width=1920;
fe.layout.height=1080;



// 레이아웃 비율조절 

fe.layout.preserve_aspect_ratio = true;


fe.load_module("animate");
// Include the utilities to read the history.dat file
dofile(fe.script_dir + "file_util.nut" );


// Class to assign the history.dat information
// to a text object called ".currom"16/9


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

	
	
// 배경 이미지, 디스플레이 타이틀

fe.add_image( "bg_green_4x3.png", 0, 0, 1920, 1080);
local displayName = fe.add_image ("systems/[DisplayName]",260, 0, 600, 219);



// 휠 이미지 페이드인 전환효과

::OBJECTS <- {
marquee = fe.add_artwork( "marquee", 1241, 774, 530, 161 ),
}
    local move_marquee1 = {
 	when = Transition.ToNewSelection, property = "alpha", start = 0, end = 255, time = 500
    }
    animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee1 ) );
OBJECTS.marquee.trigger = Transition.EndNavigation;

// local marquee_bg = fe.add_artwork( "marquee_bg_green_4x3.png", 1226, 766, 560, 177 );
// marquee_bg.alpha = 50;


// 미리보기 동영상 화면늘리기 or 화면비율유지

local snap = fe.add_artwork( "snap", 1184, 207, 640, 480 );
fe.add_image( "scanline.png", 1184, 207, 640, 480);
if ( my_config["enable_stretch"] == "No" )
{
snap.preserve_aspect_ratio = true;
}
snap.trigger = Transition.EndNavigation;



// 게임 flyer의 옵션 투명도 선택값에 따른 페이드인 전환효과

if ( my_config["enable_flyer"] == "Yes" )
{
::OBJECTS <- {
flyer = fe.add_artwork( "flyer", 77, 202, 964, 753 ),
}
    local flyer_alpha = abs(("0"+my_config["select_Alpha"]).tointeger()) % 255;;
    local move_flyer1 = {
 	when = Transition.ToNewSelection, property = "alpha", start = 0, end = flyer_alpha, time = 500
 }
    animation.add( PropertyAnimation( OBJECTS.flyer, move_flyer1 ) );
OBJECTS.flyer.trigger = Transition.EndNavigation;
}


// 게임 리스트 박스 (게임번호, 게임이름)

local listbox1b = fe.add_listbox( 70, 221, 931, 723 );
listbox1b.charsize = 33;
listbox1b.font="TmonMonsori";
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0,0,0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.format_string = "[ListEntry]";
local listbox1b = fe.add_listbox( 70, 219, 931, 723 );
listbox1b.charsize = 33;
listbox1b.font="TmonMonsori";
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0,0,0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.format_string = "[ListEntry]";
local listbox1b = fe.add_listbox( 68, 221, 931, 723 );
listbox1b.charsize = 33;
listbox1b.font="TmonMonsori";
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0,0,0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.format_string = "[ListEntry]";
local listbox1b = fe.add_listbox( 68, 219, 931, 723 );
listbox1b.charsize = 33;
listbox1b.font="TmonMonsori";
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0,0,0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.format_string = "[ListEntry]";

local listbox1 = fe.add_listbox( 69, 220, 931, 723 );
listbox1.charsize = 33;
listbox1.font="TmonMonsori";
listbox1.set_sel_rgb( 255 243, 20 );
listbox1.set_rgb( 73, 223, 222 );
listbox1.selbg_alpha = 0;
listbox1.align = Align.Left;
listbox1.format_string = "[ListEntry]";


local listbox2b = fe.add_listbox( 160, 221, 951, 723 );
listbox2b.charsize = 33;
listbox2b.font="TmonMonsori";
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;

listbox2b.format_string = "[!gamename]";
local listbox2b = fe.add_listbox( 160, 219, 931, 723 );
listbox2b.charsize = 33;
listbox2b.font="TmonMonsori";
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;

listbox2b.format_string = "[!gamename]";
local listbox2b = fe.add_listbox( 158, 221, 931, 723 );
listbox2b.charsize = 33;
listbox2b.font="TmonMonsori";
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;

listbox2b.format_string = "[!gamename]";
local listbox2b = fe.add_listbox( 158, 219, 931, 723 );
listbox2b.charsize = 33;
listbox2b.font="TmonMonsori";
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;

listbox2b.format_string = "[!gamename]";
local listbox2 = fe.add_listbox( 159, 220, 931, 723 );
listbox2.charsize = 33;
listbox2.font="TmonMonsori";
listbox2.set_sel_rgb( 255, 243, 20 );
listbox2.set_rgb( 240, 240, 240 );
listbox2.selbg_alpha = 0;
listbox2.align = Align.Left;

listbox2.format_string = "[!gamename]";

fe.add_image("box_4x3.png", 81, 539, 959, 82 );


// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
 function gamename( index_offset ) {
  local s = split( fe.game_info( Info.Title, index_offset ), "(/[" );
 	if ( s.len() > 0 ) return s[0];
  return "";
}



// 현재시각, 선택한 즐겨찾기명, 게임개수, 게임장르, 제작년도, 에뮬기종 표시

local clockbtext = fe.add_text( "시간 :", 1635, 42, 300, 36 );
clockbtext.set_rgb( 0, 0, 0 );
clockbtext.charsize = 24
clockbtext.font="TmonMonsori";
clockbtext.align = Align.Left;

local clocktext = fe.add_text( "시간 :", 1633, 40, 300, 36 );
clocktext.set_rgb( 211, 250, 255 );
clocktext.charsize = 24
clocktext.font="TmonMonsori";
clocktext.align = Align.Left;

local clockb = fe.add_text( "", 1722, 42, 477, 36  );
clockb.align = Align.Left;
clockb.charsize = 25
clockb.set_rgb( 0, 0, 0 );

local clock = fe.add_text( "", 1720, 40, 477, 36  );
clock.align = Align.Left;
clock.charsize = 25
clock.set_rgb( 73, 223, 222 );

function update_clock( ttime ){
  local now = date();
  clockb.msg = format("%02d", now.hour) + "시 " + format("%02d", now.min )+ "분";
  clock.msg = format("%02d", now.hour) + "시 " + format("%02d", now.min )+ "분";
}
  fe.add_ticks_callback( this, "update_clock" );

local listtextb = fe.add_text( "[!filter] :", 1290, 28, 477, 36 );
listtextb.set_rgb( 0, 0, 0 );
listtextb.charsize = 24
listtextb.font="TmonMonsori";
listtextb.align = Align.Left;

local listtext = fe.add_text( "[!filter] :", 1288, 26, 477, 36 );
listtext.set_rgb( 211, 250, 255 );
listtext.charsize = 24
listtext.font="TmonMonsori";
listtext.align = Align.Left;

// Change filter name to upper case
 function filter(){
	local text = fe.filters[fe.list.filter_index].name;

                if (text == "Favourites")
                text = "즐겨찾기"
		        if (text == "All")
                text = "전체게임"
				if (text == "VS Fight")
                text = "대전격투게임"
                if (text == "Shooting")
                text = "슈팅게임"
		        if (text == "Gun ST")
                text = "건슈팅게임"
				if (text == "Action")
                text = "액션게임"
                if (text == "Belt Action")
                text = "벨트스크롤액션"
		        if (text == "Racing")
                text = "레이싱게임"
				if (text == "Puzzle")
                text = "퍼즐오락게임"
                if (text == "Board")
                text = "보드게임"
		        if (text == "Quiz")
                text = "퀴즈게임"
				if (text == "Rhythm")
                text = "리듬게임"
		        if (text == "RPG")
                text = "롤플레잉게임"
				if (text == "Adventure")
                text = "어드벤처게임"
                if (text == "1980s")
                text = "1980년대 게임"
		        if (text == "1990s")
                text = "1990년대 게임"
				if (text == "2000s")
                text = "2000년대 게임"
				if (text == "2010s")
                text = "2010년대 게임"
		        if (text == "MSX(Zemmix)")
                text = "재믹스(MSX)게임"
				if (text == "Famicom")
                text = "패미컴 게임"
                if (text == "Super-Famicom")
                text = "슈퍼패미컴 게임"
		        if (text == "Mega-Drive(Mega-CD)")
                text = "메가드라이브 시디"
				if (text == "PC-Engein(CD-ROM)")
                text = "피시엔진 시디"
				if (text == "Playstation 1")
                text = "플레이스테이션1"
                if (text == "Playstation 2")
                text = "플레이스테이션2"
		        if (text == "Game Cube")
                text = "닌텐도 게임큐브"
				if (text == "Nintendo Wii")
                text = "닌텐도 위 게임"
				if (text == "All Arcade Games")
                text = "전체오락실 게임"
		return text.toupper();
 }

local listb = fe.add_text("[ListSize] 개", 1290, 64, 224, 32 );
listb.set_rgb( 0, 0, 0 );
listb.charsize = 25
listb.font="TmonMonsori";
listb.align = Align.Right;

local list = fe.add_text( "[ListSize] 개", 1288, 62, 224, 32 );
list.set_rgb( 73, 223, 222 );
list.charsize = 25
list.font="TmonMonsori";
list.align = Align.Right;


local listcc = fe.add_text( "[Category]", 1270, 112, 450, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Left;
local listcc = fe.add_text( "[Category]", 1270, 110, 450, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Left;
local listcc = fe.add_text( "[Category]", 1272, 110, 450, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Left;
local listcc = fe.add_text( "[Category]", 1272, 112, 450, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Left;
local listc = fe.add_text( "[Category]", 1271, 111, 450, 26 );
listc.font="TmonMonsori";
listc.align = Align.Left;


local listcc = fe.add_text( "[Year]", 1410, 112, 100, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Right;
local listcc = fe.add_text( "[Year]", 1410, 110, 100, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Right;
local listcc = fe.add_text( "[Year]", 1412, 110, 100, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Right;
local listcc = fe.add_text( "[Year]", 1412, 112, 100, 26 );
listcc.font="TmonMonsori";
listcc.set_rgb( 0, 0, 0 );
listcc.align = Align.Right;
local listc = fe.add_text( "[Year]", 1411, 111, 100, 26 );
listc.font="TmonMonsori";
listc.align = Align.Right;

local listdd = fe.add_text( "[Emulator]", 1636, 112, 350, 26 );
listdd.font="TmonMonsori";
listdd.set_rgb( 0, 0, 0 );
listdd.align = Align.Left;
local listdd = fe.add_text( "[Emulator]", 1636, 114, 350, 26 );
listdd.font="TmonMonsori";
listdd.set_rgb( 0, 0, 0 );
listdd.align = Align.Left;
local listdd = fe.add_text( "[Emulator]", 1634, 112, 350, 26 );
listdd.font="TmonMonsori";
listdd.set_rgb( 0, 0, 0 );
listdd.align = Align.Left;
local listdd = fe.add_text( "[Emulator]", 1634, 114, 350, 26 );
listdd.font="TmonMonsori";
listdd.set_rgb( 0, 0, 0 );
listdd.align = Align.Left;
local listd = fe.add_text( "[Emulator]", 1635, 113, 350, 26 );
listd.font="TmonMonsori";
listd.align = Align.Left;


// CRT 모니터 스캔라인 설정

if ( my_config["enable_crt"] == "Yes" )
{
 fe.add_image( "scanline.png", 0, 0, 1920, 1080);
}