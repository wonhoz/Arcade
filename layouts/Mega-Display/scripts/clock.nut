local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;


//******clock***********************************************
local clockb = fe.add_text( "", flx*0.865, fly*0.879, flw*0.120, flh*0.160);
clockb.align = Align.Right;
clockb.set_rgb( 185, 183, 183 );
clockb.font ="time";
clockb.charsize = 30;

function update_clock( ttime ){
  local now = date();
  clockb.msg = format("%02d", now.hour) + ":" + format("%02d", now.min );
}
  fe.add_ticks_callback( this, "update_clock" );
//******clock END*******************************************

local clock = fe.add_image( "images/clock.png", flx*0.915, fly*0.945, flw*0.025, flh*0.035);

// Mega-Display Advanced 와 동일하게 정리했다.
//   - clock.msg 대입: clock 은 여기서 지역변수가 아직 선언되기 전이라
//     Squirrel 내장 clock() 함수로 해석되어 예외가 났다. 예외는 스크립트 나머지를
//     통째로 중단시키므로 이 아래 줄들이 실행되지 않았다.
//   - am.png: 파일이 없고, 시계가 24시간 표기라 AM/PM 표시가 의미 없다.
//******************************************