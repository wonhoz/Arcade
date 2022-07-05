//class UserConfig 
//{ 
//</ label="User custom text",help="Enter text to display on the layout", order=1 /> uct="Change this text in the Layout Options";
//}
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
//local my_config = fe.get_config();

//local copyright1 = fe.add_text( "어트랙트모드 한방팩 Ver.1.1", flx-fly*0.17, fly*0.007, fly*0.1852, flh*0.016);
//local copyright2 = fe.add_text( "테마/미디어 제작: CSOne", flx-fly*0.17, fly*0.026, fly*0.1852, flh*0.016);
//copyright1.align = Align.Left;
//copyright2.align = Align.Left;
//copyright1.font="TmonMonsori";
//copyright2.font="TmonMonsori";
//copyright1.set_rgb( 205, 205, 205 );
//copyright2.set_rgb( 205, 205, 205 );

//local uct = fe.add_text( my_config["uct"], flx*0.380, fly*0.012, flw*0.550, flh*0.050 );
//local uct = ScrollingText.add( "[Overview]", flx*0.280, fly*0.012, flw*0.9, flh*0.03);
local uct = fe.add_text( "[Overview]", flx*0.19, fly*0.012, flw*0.9, flh*0.03);
uct.settings.delay = 200
uct.settings.loop = -1
uct.align = Align.Left;
uct.text.charsize = 24;
uct.set_rgb( 205, 205, 205 );
uct.set_bg_rgb( 0, 0, 0 );
uct.bg_alpha = 000;
uct.font="TmonMonsori";


