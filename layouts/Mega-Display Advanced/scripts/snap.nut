
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

//local l = fe.add_artwork("snap" , 190, 0, 0, flh );

local l = fe.add_artwork("snap" , flx*0.175, fly*0.085, flw*0.825, flh*0.83 );
l.preserve_aspect_ratio = true;