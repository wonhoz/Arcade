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
}
  fe.add_ticks_callback( this, "update_clock" );
//******clock END*******************************************

local clock = fe.add_image( "images/clock.png", flx*0.890, fly*0.956, flw*0.025, flh*0.035);

// am.png 를 참조하던 줄은 지웠다.
//   - 그 파일이 레이아웃 어디에도 없어 항상 빈 이미지 객체만 만들어졌다
//   - 좌표(flx*0.513)가 시계(flx*0.865~0.915)와 무관한 화면 좌중앙이었다
//   - 무엇보다 위 시계가 24시간 표기(%02d hour)라 AM/PM 표시 자체가 의미 없다
// 다시 넣을 일이 있으면 시계를 12시간 표기로 바꾸는 것이 먼저다.
//******************************************