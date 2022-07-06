

class UserConfig 
{ 
</ label="사용자 지정 텍스트",help="레이아웃에 표시 할 텍스트를 입력하세요.", order=1 /> uct="Change this text in the Layout Options";
}

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

//local uct = fe.add_text( my_config["uct"], flx*0.380, fly*0.012, flw*0.550, flh*0.050 );
local uct = fe.add_text( "AttractMode Remaked by wonhoz", flx*0.380, fly*0.012, flw*0.550, flh*0.050 );
uct.charsize = 25;
uct.set_rgb( 205, 205, 205 );
uct.set_bg_rgb( 0, 0, 0 );
uct.bg_alpha = 000;
uct.font="TmonMonsori";
uct.align = Align.Left;
