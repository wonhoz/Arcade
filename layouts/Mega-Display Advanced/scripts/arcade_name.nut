//class UserConfig 
//{ 
//</ label="사용자 지정 텍스트",help="레이아웃에 표시 할 텍스트를 입력하세요.", order=1 /> uct="Change this text in the Layout Options";
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

// 아래 스타일 지정은 ScrollingText.add 를 쓰던 시절의 코드다.
// fe.add_text 로 바꾼 뒤 uct.settings.delay 가 예외를 던지면서 이 아래로는
// 한 줄도 실행되지 않아 왔고, 화면은 줄곧 fe.add_text 기본값(가운데 정렬)으로
// 그려져 왔다. 그 모습이 정상이다.
//
// 특히 Align.Left 를 되살리면 안 된다. 텍스트 상자가 x=0.19 에서 시작하는데
// 좌측 사이드바 아트가 그 위를 덮고 있어 문장 앞부분이 잘려 보이지 않는다.
// 예외만 없애고 나머지는 기본값을 유지한다.
//
//uct.align = Align.Left;
//uct.charsize = 24;
//uct.set_rgb( 205, 205, 205 );
//uct.set_bg_rgb( 0, 0, 0 );
//uct.bg_alpha = 000;
//uct.font="TmonMonsori";


