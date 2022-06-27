

class UserConfig {
 </ label="Enble background Scanline", help="Show scanline effect", options="none,light,medium,dark", order=17 /> enable_scanline="none";
}

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

if ( my_config["enable_scanline"] == "none" )

{

local scanline = fe.add_image( "", 0, 0, flw, flh );

}


if ( my_config["enable_scanline"] == "light" )

{

local scanline = fe.add_image( "images/scanline.png", 0, 0, flw, flh );

scanline.preserve_aspect_ratio = false;

scanline.alpha = 100;

}


if ( my_config["enable_scanline"] == "medium" )

{

local scanline = fe.add_image( "images/scanline.png", 0, 0, flw, flh );

scanline.preserve_aspect_ratio = false;
scanline.alpha = 200;

}


if ( my_config["enable_scanline"] == "dark" )

{

local scanline = fe.add_image( "images/scanline.png", 0, 0, flw, flh );

scanline.preserve_aspect_ratio = false;

scanline.alpha = 255;

}