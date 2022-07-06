//local my_config = fe.get_config();

local blip = fe.layout.height;
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;

local bgArt1 = fe.add_image("bg_blue.png", 0, 0, flw, flh );
local bgArt2 = fe.add_clone(bgArt1);

fe.load_module("animate");
animation.add( PropertyAnimation( bgArt1, {when = Transition.StartLayout, property = "x", start = 0, end = -flw, time = 28000, loop=true}));
animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "x", start = flw, end = 0, time = 28000, loop=true}));	
//animation.add( PropertyAnimation( bgArt2, {when = Transition.StartLayout, property = "alpha", start = 0, end = 255, time = 500}));

// 동영상 뒷배경
local blackbg = fe.add_image( "black.png", 117, 143, 720, 542 );

// 모니터와 콘솔기기
fe.add_image( "monitor.png", 52, 73, 849, 812);
fe.add_image( "consol_ps1.png", 70, 825, 654, 238);

// 동영상
local snap = fe.add_artwork( "snap", 123, 151, 707, 529 );
//snap.preserve_aspect_ratio = true;
snap.trigger = Transition.EndNavigation;
fe.add_image( "scanline.png", 123, 151, 708, 529);

// 게임 리스트 배경
local listbg = fe.add_image("list_bg.png",1000, 20, 870, 1046 );
listbg.alpha = 150;
