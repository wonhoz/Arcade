local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;


//******clock***********************************************
local clockb = fe.add_text( "", flx*0.865, fly*0.88, flw*0.120, flh*0.160);
clockb.align = Align.Right;
clockb.set_rgb( 185, 183, 183 );
clockb.font ="time";
clockb.charsize = 36;

function update_clock( ttime ){
  local now = date();
  clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
  clock.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );
//******clock END*******************************************

local clock = fe.add_image( "images/clock.png", flx*0.895, fly*0.956, flw*0.025, flh*0.035);
local am = fe.add_image( "am.png", flx*0.513, fly*0.855, flw*0.040, flh*0.030);
am.alpha = 100;
//******************************************