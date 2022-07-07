class UserConfig
{
    
}  

local my_config = fe.get_config();

local blip = fe.layout.height;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local bgArt1 = fe.add_image("bg_blue.png", 0, 0, flw, flh );
local bgArt2 = fe.add_clone(bgArt1);

fe.load_module("animate");
animation.add( PropertyAnimation( bgArt1, {when = Transition.StartLayout, property = "x", start =   0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end =    0, time = 28000, loop=true}));	
//animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));



// 모니터 동영상 배경
local blackbg = fe.add_image("black.png", 0.061*flw, 0.132*flh, 0.375*flw, 0.502*flh );

// 모니터와 콘솔기기
fe.add_image("monitor.png",     0.027*flw, 0.068*flh, 0.442*flw, 0.752*flh );
fe.add_image("console_ps1.png", 0.094*flw, 0.769*flh, 0.28*flw, 0.22*flh );

// 동영상
local snap = fe.add_artwork("snap", 0.064*flw, 0.14*flh, 0.368*flw, 0.49*flh );
//snap.preserve_aspect_ratio = true;
snap.trigger = Transition.EndNavigation;
fe.add_image("scanline.png", 0.064*flw, 0.14*flh, 0.369*flw, 0.49*flh );

//Game Marquee Animation
::OBJECTS <- {
    marquee = fe.add_artwork( "marquee", 0.154*flw, 0.019*flh, 0.188*flw, 0.111*flh ),
}

// if ( my_config["enable_gamelogo"] == "Yes" )
// {
//     local move_marquee1 = {
//         when = Transition.ToNewSelection ,property = "y", start = 0, end = 0.028*flh, time = 100
//     }

//     local move_marquee2 = {
//         when = Transition.ToNewSelection ,property = "y", start = 0.028*flh, end = 0.019*flh, delay = 100, time = 300
//     }

//     animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee1 ) );
//     animation.add( PropertyAnimation( OBJECTS.marquee, move_marquee2 ) );
// }

OBJECTS.marquee.trigger = Transition.EndNavigation;



// 게임 리스트 배경
local listbg = fe.add_image("list_bg_34.png", 0.521*flw, 0.019*flh, 0.453*flw, 0.969*flh );
listbg.alpha = 150;

// // 리스트 박스 백그라운드 이미지 선택
// if ( my_config["enable_flyer"] == "Yes" )
// {
// 	local flyer = fe.add_artwork( "flyer", 0.525*flw, 0.206*flh, 0.445*flw, 0.683*flh );
// 	flyer.alpha = abs(("0"+my_config["select_Alpha2"]).tointeger()) % 255;;
// 	flyer.trigger = Transition.EndNavigation;
// }

// // 게임 캐릭터 이미지 표시 (권장 이미지 사이즈: 480x760)
// if ( my_config["select_character"] == "By Display" )
// {
// 	local mascot = fe.add_image ( "systems/[DisplayName]" + "_character_" + my_config["select_character_no"] +".png", 0.75*flw, 0.185*flh, 0.25*flw, 0.704*flh );
// 	mascot.alpha = abs(("0"+my_config["select_Alpha"]).tointeger()) % 255;;
// 	mascot.preserve_aspect_ratio = true;
// }

// 에뮬 디스플레이 타이틀
local displayName = fe.add_image ( "systems/[DisplayName]", 0.63*flw, 0.022*flh, 0.234*flw, 0.185*flh );

// 게임 선택 박스
fe.add_image( "box.png", 0.524*flw, 0.507*flh, 0.446*flw, 0.074*flh );

// 리스트 박스 게임번호 그림자
local listbox1b = fe.add_listbox( 0.531*flw, 0.213*flh, 0.18*flw, 0.676*flh );
listbox1b.charsize = 40;
listbox1b.set_sel_rgb( 208, 56, 0 );
listbox1b.set_rgb( 0, 0, 0 );
listbox1b.selbg_alpha = 0;
listbox1b.align = Align.Left;
listbox1b.font="texgyreheros-bold";
listbox1b.format_string = "[ListEntry]";

// 리스트 박스 게임번호
local listbox1 = fe.add_listbox( 0.53*flw, 0.21*flh, 0.18*flw, 0.676*flh );
listbox1.charsize = 40;
listbox1.set_sel_rgb( 255 243, 20 );
listbox1.set_rgb( 73, 223, 222 );
listbox1.selbg_alpha = 0;
listbox1.align = Align.Left;
listbox1.font="texgyreheros-bold";
listbox1.format_string = "[ListEntry]";

// 리스트 박스 게임이름 그림자
local listbox2b = fe.add_listbox( 0.583*flw, 0.206*flh, 0.375*flw, 0.676*flh );
listbox2b.charsize = 36;
listbox2b.set_sel_rgb( 208, 56, 0 );
listbox2b.set_rgb( 0, 0, 0 );
listbox2b.selbg_alpha = 0;
listbox2b.align = Align.Left;
listbox2b.format_string = "[!gamename]";

// 리스트 박스 게임이름
local listbox2 = fe.add_listbox( 0.582*flw, 0.204*flh, 0.375*flw, 0.676*flh );
listbox2.charsize = 36;
listbox2.set_sel_rgb( 255 243, 20 );
listbox2.set_rgb( 240, 240, 240 );
listbox2.selbg_alpha = 0;
listbox2.align = Align.Left;
listbox2.format_string = "[!gamename]";

// Game name text. We do this in the layout as the frontend doesn't chop up titles with a forward slash
function gamename( index_offset )
{
    local s = split( fe.game_info( Info.Title, index_offset ), "/[" );
    if ( s.len() > 0 ) return s[0];
    return "";
}



// 시계 텍스트 그림자
local clockbtext = fe.add_text(  "현재시각:", 0.505*flw, 0.93*flh, 0.134*flw, 0.043*flh );
clockbtext.set_rgb( 0, 0, 0 );
clockbtext.font="Ticketbook W01 Bold";

// 시계 텍스트
local clocktext = fe.add_text(  "현재시각:", 0.504*flw, 0.927*flh, 0.134*flw, 0.043*flh );
clocktext.set_rgb( 211, 250, 255 );
clocktext.font="Ticketbook W01 Bold";

// 현재 시각 그림자
local clockb = fe.add_text(  "", 0.614*flw, 0.934*flh, 0.167*flw, 0.043*flh );
clockb.align = Align.Left;
clockb.font="texgyreheros-bold";
clockb.set_rgb( 0, 0, 0 );

// 현재 시각
local clock = fe.add_text(  "", 0.612*flw, 0.931*flh, 0.167*flw, 0.043*flh );
clock.align = Align.Left;
clock.font="texgyreheros-bold";
clock.set_rgb( 73, 223, 222 );

function update_clock( ttime )
{
    local now  = date();
    clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
    clock.msg  = format("%02d", now.hour) + ":" + format("%02d", now.min );
}

fe.add_ticks_callback( this, "update_clock" );



// 즐겨찾기 필터
local listtextb = fe.add_text(  "[!filter] GAMES:", 0.718*flw, 0.93*flh, 0.234*flw, 0.043*flh );
listtextb.set_rgb( 0, 0, 0 );
listtextb.font="Ticketbook W01 Bold";
listtextb.align = Align.Left;

local listtext = fe.add_text(  "[!filter] GAMES:", 0.716*flw, 0.927*flh, 0.234*flw, 0.043*flh );
listtext.set_rgb( 211, 250, 255 );
listtext.font="Ticketbook W01 Bold";
listtext.align = Align.Left;

// Change filter name to upper case
function filter()
{
    local text = fe.filters[fe.list.filter_index].name;

    if (text == "Favourites") text = "FAV"
    
    return text.toupper();
}

local listb = fe.add_text( "[ListSize]", 0.891*flw, 0.934*flh, 0.104*flw, 0.043*flh );
listb.set_rgb( 0, 0, 0 );
listb.font="texgyreheros-bold";
listb.align = Align.Left;

local list = fe.add_text(  "[ListSize]", 0.889*flw, 0.931*flh, 0.104*flw, 0.043*flh );
list.set_rgb( 73, 223, 222 );
list.font="texgyreheros-bold";
list.align = Align.Left;

