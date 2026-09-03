
local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

//local l = fe.add_artwork("snap" , 190, 0, 0, flh );

local n = fe.add_image("bg.png" , flx*0.175, fly*0.085, flw*0.825, flh*0.83 );

local l = fe.add_artwork("snap" , flx*0.175, fly*0.085, flw*0.825, flh*0.83 );
l.preserve_aspect_ratio = true;

local m = fe.add_artwork("marquee" , flx*0.19, fly*0.012, flw*0.9, flh*0.037 );
m.preserve_aspect_ratio = true;
// 위 marquee 는 아래 arcade_name.nut 의 [Overview] 텍스트와 좌표가 똑같다.
// 겹쳐 보이는 사고가 아니라 서로 배타적인 레이어다.
//   - 디스플레이 21개: menu-art\marquee 에 해당 이미지가 없어 marquee 는 빈 채로 지나가고
//     그 위에 한국어 Overview 문장이 그려진다 (scraper\@\overview\*.txt 21개).
//   - 종료(exit) 항목: scraper\@exit\overview 가 비어 있어 Overview 가 빈 문자열이라
//     menu-art\marquee\exit.png 만 보인다.
// layout.nut 의 do_nut 순서가 snap(26행) -> arcade_name(32행) 이라 텍스트가 항상 위에 온다.
//
// 그래서 둘 중 하나를 지우거나 옮기면 안 된다. 대신 이 전제가 깨지는 경우만 조심한다:
//   디스플레이용 marquee 이미지를 넣거나, @exit 에 overview 를 쓰면 그때는 진짜로 겹친다.
