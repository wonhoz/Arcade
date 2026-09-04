// my display theme punktoe 2017

class UserConfig 
{ 
</ label="사용자 지정 텍스트",help="레이아웃에 표시 할 텍스트를 입력하세요.", order=1 /> uct="Change this text in the Layout Options";
</ label="스핀 휠 아트 선택", help="휠 이미지를 선택하세요.", options="marquee, wheel", order=3 /> orbit_art="wheel";
   
</ label="휠 대신 vertart 선택", help="Select vertical or wheel art", options="Yes,No", order=4 /> enable_VertArt="no";
   
</ label="휠 전환 시간", help="Time in milliseconds for wheel spin.", order=10 /> transition_ms="25";
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
// fe.do_nut("scripts/fade.nut") 는 지웠다. 이 레이아웃의 scripts/ 에는 fade.nut 이 없어
// (Mega-Display Advanced 에만 있다) 여기서 Squirrel 예외가 나고, 그 아래 sidebar.nut 과
// wheel2.nut 이 한 번도 실행되지 않았다. fade.nut 이 정의하는 FadeArt 클래스는 두 레이아웃
// 어디에서도 쓰이지 않으므로 파일을 복사하는 대신 호출을 없앴다. (docs/ISSUES.md 29번)
fe.do_nut("scripts/sidebar.nut");
fe.do_nut("scripts/wheel2.nut");





