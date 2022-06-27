// my display theme punktoe 2017

class UserConfig 
{ 
</ label="User custom text",help="Enter text to display on the layout", order=1 /> uct="Change this text in the Layout Options";
</ label="휠아트 선택", help="휠 이미지를 선택하세요.", options="marquee, wheel", order=3 /> orbit_art="wheel";
   
</ label="Select vertart instead of wheel", help="Select vertical or wheel art", options="Yes,No", order=4 /> enable_VertArt="no";
   
</ label="휠 전환시간", help="Time in milliseconds for wheel spin.", order=10 /> transition_ms="25";
</ label="스캔라인 효과", help="화면에 스캔라인을 표시합니다.", options="none,light,medium,dark", order=17 /> enable_scanline="none";
}

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

fe.load_module( "fade" );
fe.load_module("animate");
fe.load_module("pan-and-scan");
fe.load_module("objects/scrollingtext");

fe.do_nut("scripts/snap.nut");
fe.do_nut("scripts/scanline.nut");
fe.do_nut("scripts/clock.nut");
fe.do_nut("scripts/sound.nut");
fe.do_nut("scripts/reload.nut");
fe.do_nut("scripts/loading.nut");
fe.do_nut("scripts/arcade_name.nut");
fe.do_nut("scripts/whitebar.nut");
fe.do_nut("scripts/fade.nut");
fe.do_nut("scripts/sidebar.nut");
fe.do_nut("scripts/wheel2.nut");





