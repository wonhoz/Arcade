//
// Attract-Mode Front-End - "Controller" layout
// Made by CSOne 2018.11.28
//

class UserConfig { 
</ label="Enable CRT effect", help="Enable CRT effect", options="Yes,No", order=1 /> enable_crt="No";
</ label="Background Artwork", help="Select Background Artwork", options="blue,blue2,gray,gray2,green,green2,orange,red,pink,purple,purple2,retro,user1,user2,user3,video", order=2 /> 
   select_bgArt="red";
</ label="Enable Flyer", help="Enable Flyer Yes or No?", options="Yes,No", order=3 /> enable_flyer="Yes";
</ label="Flyer Alpha", help="Input Flyer Alpha value 0~255", options="", order=4 /> select_Alpha="70";   
</ label="Display Game Logo", help="Display game's marquee image.", options="Yes,No", order=5 /> enable_history="No";
</ label="History.dat", help="History.dat location. Be sure to enable and config History.dat from the plugins menu.", order=6 />
	dat_path=".\\history.dat";  
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
// dofile(fe.script_dir + "file_util.nut" );


// 백그라운드 지정 및 스크롤 애니메이션 효과
if ( my_config["select_bgArt"] == "video" ){
bgArt = fe.add_artwork("bg.mp4", 0, 0, flw, flh );
}
bgArt = fe.add_image("bg_" + my_config["select_bgArt"] + ".png", 0, 0, flw, flh );
bgArt2 = fe.add_clone(bgArt);

fe.load_module("animate");
animation.add( PropertyAnimation( bgArt, {when = Transition.StartLayout, property = "x", start = 0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end = 0, time = 28000, loop=true}));			
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));


// 모니터와 콘솔기기
fe.add_image( "Controller.png", 0, 0, 1920, 1080);



if ( my_config["enable_crt"] == "Yes" )
{
 fe.add_image( "scanline.png", 0, 0, 1920, 1080);
}