local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;


fe.load_module("animate");

::OBJECTS <- {
pac = fe.add_image("images/logo.png", 000, 000, flw, flx),
}
local pacmon = {
	when = Transition.StartLayout ,
	property = "alpha", 
	start = 255, 
	end = 0, 
	time = 2000,
	delay = 500,	 		
 }

animation.add( PropertyAnimation( OBJECTS.pac, pacmon ) );
//OBJECTS.pac.preserve_aspect_ratio = true;
