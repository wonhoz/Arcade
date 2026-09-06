이 폴더는 비어 있어야 한다.

  ekmame64.exe(MAME 0.212) 는 pluginspath 의 boot.lua 를 Lua 엔진 부트스트랩으로
  읽는데, 같은 폴더의 plugins\boot.lua 는 mame64.exe(0.246) 용이라 API 가 맞지 않는다.
  그대로 두면 게임을 띄울 때마다 이런 오류 대화상자가 떠서 게임이 시작되지 않는다.

      [LUA ERROR] in run: plugins\boot.lua:11:
      attempt to index a function value (field 'options')

  그래서 EKMAME 계열 에뮬레이터 정의는 args 에 -pluginspath plugins-none 을 준다.
  boot.lua 가 없으므로 Lua 엔진을 건너뛰고 게임이 정상 기동한다.

  여기에 파일을 넣지 말 것. 특히 boot.lua 를 넣으면 원래 증상으로 돌아간다.

  해당 정의:  EKMAME.cfg / EKMAME Vertical.cfg
              MAME Legacy.cfg / MAME Legacy Vertical.cfg / MAME Legacy Adult.cfg
