SEGA Model 2 Emulator
by ElSemi
http://nebula.emulatronia.com


--- HISTORY ---
v1.1a
- Added back the game options that were removed in the previous version due to compilation issues (Cheats & options, dump texture cache, reload LUA script)
- Fixed texture replacement that was also removed.
- Diferent alpha filtering code that should improve the extra lines in some textures.

v1.1
- Fixed sound output only outputting mono audio
- Added customizable pixel shader for texture replacement (see model2lua.txt)
- Fixed Emulator->Exit not saving configuration
- The emulator will now try to use pixel shader 2.0 when pixel shader 3.0 is unavailable
- Added Full screen antialiasing (fsaa=1 in emulator.ini)
- Fixed some 3D errors in dynamite cop causing low res textures to be used
- Fixed texture replacement when two textures share the same tag data


v1.0
- Finally fixed VF2 hair problems, now all graphics are correct
- Added LUA script support for options, cheats and other uses (check model2lua.txt in SCRIPTS folder)
- Added texture replacement support (check model2lua.txt in SCRIPTS folder)
- Added widescreen support (needs per-game lua scripts to know when to enable it). Requires a wide
fullscreen resolution or WideScreenWindow set in emulator.ini
- Fixed texture border detection for textures that caused wrong colors & pixelation on borders
- Simplified pixel shaders (half the texture fetches)
- Improved House of the dead FM sound
- Fixed VF2 wrong sound speeds
- Fixed background distortion on Dural stage in VF2
- Added STCC Euro
- Added Sonic the fighters.
- Fixed Virtual On missing background color on title screen
- Rewritten SCSP code for improved accuracy
- Fixed ATI video card gfx problems
- Fixed audio stuttering on some windows 7 machines
- Added Sega Rally Championship rev B


v0.9
Lots of changes in this version:
- Fixed TGP emulation bugs and added missing opcodes. Virtua Fighter 2 and Virtua Cop 2 are now
playable. There is still a bug with VF2 hair/body collisions, probably another TGP bug, but it's
quite hard to find...
- Fixed I960 bug that caused daytona invisible walls/holes in the road.
- Fixed timer bug that caused missing hair in Fighting vipers, tails in sonic and slow cars in 
Sega Rally (although they still don't work properly).
- Added support for "return to neutral". Enable it with HoldGears=1 option in emulator.ini. This
setting will cause the emu to return to neutral when no gear button is pressed.
- Redone rasterizer color decoding and texture mapping. Now it works the same way the real hardware
does, performing all the same table lookups and calculations, so color should be accurate now. The 
color decoding is now done at pixel shader level so you'll need a PS 2.0 capable video card in order
to run the emulator now.
- Fixed white borders in some transparent textures.
- Redone texture caching code. Improved dirty texture detection. Fixes wrong textures in some
games when a new texture overlaps partially with an existing one.
- Changed ManxTT sound roms to the Twin ones. The previous romset was using the Deluxe ones that
have 2 sound boards. Fixes the "japanese speech when braking" bug :).Set the machine to Twin.
- Added 2 mice support for shooting games. Enable it with RawInput=1 in emulator.ini. Read some
other options there to tell the emu how to map a mouse to a player. When using RawInput the mouse
will be locked to the emulator window. In order to switch to another window, either press Alt to
bring the menu and unlock the mouse or use Alt-Tab to switch to another application.
- Fixed Alt key not activating the window menu.
- Fixed MB86235 bug when handling denormalized numbers that caused top skater and overrev lock the
emu sometimes.
- Fixed corrupt textures sometimes when loading a savestate
- Fixed frameskipping bug that caused some data not being updated in the TGP memory when 
frameskipping (daytona windows not updating windows after entering/leaving the tunnel)
- Added an option to hide the crosshair in shooting games (DrawCross=0 in emulator.ini)
- Fixed Daytona to the maxx rom loading that caused wrong and missing graphics.
- Improved FM emulation support to the SCSP for some HOTD tunes requiring it.
- Fixed various bugs in the new MultiPCM sound emulation, causing some wrong loops and sounds.
- Fixed meshed transparencies size. Now they will scale to the selected resolution.
- Fixed specular highlights calculation.
- Added Daytona USA '93 edition and Daytona USA: GTX 2004.
- Added Rail Chase 2
- Added Virtua Cop 2
- Added Virtua Fighter 2, Rev A, Rev B and 2.1
- Added Sega Water Ski. The current sound rom dump seems to be bad so the game will run without
sound. This game will start in Japan region mode. To change the region, enter Test menu (F2) and
press the sequence up,up,down,down,service (f1),test (f2)
- Added Indianapolis 500 Rev A
- Changed romsets to match MAME as much as possible.


v0.8a
- Fixed missing trigger buttons in gun games
- Fixed desert tank locked into test mode
- Improved main cpu/sound cpu sync in Model2 Original games.

v0.8

- Rewritten the MultiPCM sound chip emulation. It fixes Original Model2 games sounds and music.
- Fixed eye paremeters being read as unsigned by the display list parser, causing bad geometry
in daytona 4 players attract and sega rally 2 players attract.
- Fixed network board detection for sgt24h and overrev. Now you don't need to enable network to
have them boot.
- Adjusted daytona steering limits to the real machine limits (according to the service manual). It should
have a more accurate handling now.
- Added force feedback for car driving games. You need to enable it in the .ini using the 
option EnableFF=1 in the Input section. You can tweak more force parameters in that section. Also some
games only enable the force feedback if the cabinet type is set to Deluxe in the test mode.
- Added XInput support. You can enable XInput support in the .ini in the Input section. XInput allows direct
access to XBox360 compatible controllers for vibration (they don't support vibration through DirectInput).
Keep in mind that the windows XInput libraries only support vibration force feedback so an XBox360 driving
controller won't have working force effects.
- Added optional meshed polygons for translucency (like the hardware does). Enable it with
MeshTransparency=1 in the ini. This option requires a Pixel Shader 3 capable videocard.
- Fixed HOTD rom loading that caused missing tilemap graphics (how to play, map on gameover).
- Added preliminary savestates support. The sound engine state is not being saved yet. I've added this so I can
ask for states to try to fix the invisible walls problem in daytona.


v0.7a

Fixed network code not fully working (I accidentally left a part disabled in the last build).
Improved daytona video & sound sync

v0.7

More accurate emulation of some TGP by using the data tables from the mainboard. You'll need these
table roms in Model2.zip or inside the game zip. Thanks to Peabo for the donation of a Daytona board
that helped to understand how they worked. This has fixed most of the bugs in daytona usa (reverse and most
invisble wall hits) and sega rally (automatic transmission).
Improved color table decoding that gives more bright colors for some games.
Improved SCSP timing. It should be more accurate and musics should not sound out of sync anymore. As a 
bonus feature I've left in a debug sound player that allows you to load a SSF (Saturn Sound Format) file
for playing. To use it, load a game using SCSP (model 2a,b or c) and enter test mode (so it doesn't send
sound commands) then press LeftControl+F5 and choose the ssf file to play.
Improved clipping. By moving to vertex/pixel shaders I've got rid of all the clipping issues that happened
with ATI video cards and recent NVIDIA ones. Remember to remove set SoftwareVertexProcessing to 0. You'll need
a pixel shader 1.1 and vertex shader 1.1 capable card. It's the lowest shader version so any video should work. As
a side effect of this change, there is only a geometrizer now, so the Geometrizer opion in the ini file is not used.
Fixed problems with textures ending in the lowest line of the texture sheet not being uploaded to direct3d (sega
rally black background in 2nd stage and topskater missing floors).
Added Wave Runner (Model 2C)
Added support for direct3d automimpap generation (see emulator.ini AutoMip option)
Added network emulation (see NETWORK section below)


v0.6
So many changes that I can't remember...Lighting fixes, control fixes, sound fixes...
ManxTT is working, but sound is broken.
Merged some features from the cps3 emu (vsync, custom fullscreen res,...)


v0.5a

This is a small bugfix release:
Fixed (hopefully at last) the analog wraparound bug.
Fixed wrong colour table translation in vcop madium and expert levels.

Added a couple of useful features:
Launch game from commandline (just add the driver name. ex: Emulator.exe stcc)
Auto-switch to fullscreen after game loading (the option is in the Video menu)


v0.5

This release fixes several playability bugs in Daytona USA (analog controls
wraparound and windows disappearing when going to fullscreen) and adds a new
playable game: Motor Raid.

It also contains a modified color lookup table processing that improves the
colors in the original model 2 games (daytona, vcop and dtank).

The emulator now includes a nice icon and background image, thanks to jordigahan
and Peabo for them.

v0.4 Daytonaaaaa

This version includes the (still preliminary) emulation of the Fujitsu MB86234 DSP
present in the original Model 2 and Model 2 A-CRX boards. This means that some of
the games running in these boards are playable now.
The emulation is still preliminary because it has been done by reverse engineering
the complete instruction set of the DSP and there are still bugs. This has been 
possible thanks to the help of Olivier Galibert (that helped me starting writting the
DSP disassembler some years ago) and Ernesto Corvi (that analyzed my disassemblies and
compared against other games and the model1 HLE in mame).
I'll list now the known problems and gliches in the games:

Daytona USA games: when stopping the car, or starting a course from a stop (advanced and
expert) the screen says REVERSE.
Sega Rally: Automatic transmission doesn't work, only manual.
Original Model 2 games have wrong colours in the 3D textures and wrong lighting.

To play Daytona USA, when the network check screen appears, press F2 to enter test mode
and in Game Settings set the game mode to Standalone.

This package includes the single threaded and the multithreaded version. Use the
multithreaded version in systems with more than a cpu, dual core, core duo, etc...
There are several fixes in the syncronization code that should reduce the crashes
in the emulator.

v0.3 MultiCPU Experimental build

This version contains an experimental multithreaded emulation code that will make
different parts of the emulation run in a separate thread (Currently separates CPU,
GPU and Sound emulation). This will allow multi-core CPUs (Dual core and Core Duo) 
to take advantage of both processors and boost the emulator performance a lot 
(all games are 60fps now in my Athlon 3800+ X2).
It is only recommended for multi-core cpu users, as single core processor might have
slower performance than the single threaded build.
As a bonus, this version includes a preliminary recompiler SCSP DSP emulation. The recompiler
is very fast and shouldn't affect the performance. The DSP effects still aren't 100% correct, but
it sounds quite right.

v0.3 (well, there was an unreleased 0.2 somewhere in my HD so this is 0.3)

I've rewritten part of the emulator for increased speed.
The SHARC core has also been speedup by removing unused SHARC features that weren't used by model2.
Added frameskip and autoframeskip (with + and - in the keypad).
Added Ski Super G and OverRev.
Fixed topskater and virtualon control maps.
This is probably the last version of the emulator, unless some Fujitsu TGP MB86234 docs appear
to finish the emulation of the 2 and 2A cores. Sorry, I know I still have to do the digital
sound board emulation for STCC and TopSkater but I have no free time.


v0.1 Alpha

This is a major rewrite of the Model 2 core from Nebula M2.
Basically it supports the same games than Nebula M2, except the music in
games using the Digital Sound Board.
It uses a new (lighter) framework that requires DirectX 9.0.


--- USAGE ---

Usage is easy, just load emulator, select rom and play :).
Missing rom files will be reported in a console window.


PLEASE, READ EMULATOR.INI TO CHANGE OPTIONS AND KNOW HOW TO CONFIGURE YOUR ROM DIRECTORIES


Fixed Keys:

	PAUSE	- Pauses the emulator
		while paused:
		ENTER	- Single step
		SPACE	- Unpause while held

	SCROLL LOCK - Toggle framelimit
	ALT-ENTER - Toggle Fullscreen (sometimes the emulator doesn't return from fullscreen.
		    press ALT-F4 to close it and windows will return to the original resolution)
	F9	- Show speed (Frames per second and frame time)
	CTRL-F9 - Show more stats
	F8	- Even more
	F7	- Toggle tilemap rendering (big speedup)
	Keypad+ - Increase Frameskip
	Keypad- - Decrease Frameskip

For the rest of the keys, check the input config screen after a game has been loaded (Game->Config Controls...).

NETWORK

Model 2 network is designed as a ring linking all games together. In order to use it, you must properly emulate
the ring with your machines running the emulator. The original games are designed to run in a high speed, low latency,
no packet drop, optic fiber network, so it's very likely it won't work over internet. It works fine on LAN.
To configure the network, create a m2network.ini file like this in the same directory where emulator.ini is:


[Network]
RxPort=1978
NextIP=xxx.xxx.xxx.xxx
NextPort=1978


where:
RxPort is the port where your machine is listening for packets
NextIP is the IP of the next machine in the ring
NextPort is the port where the next machine is listening for packets

Remember to setup them so they make a ring. For example, for 3 computers connected

Computer1 (192.168.1.1): RxPort=1978	NextIP=192.168.1.2 	NextPort=1978
Computer2 (192.168.1.2): RxPort=1978	NextIP=192.168.1.3	NextPort=1978
Computer3 (192.168.1.3): RxPort=1978	NextIP=192.168.1.1	NextPort=1978

If you want to run several emulator instances in the same machine, you must use different
RxPorts for each instance.

Once the network is setup, enter test mode in each emulator and set one as master and the rest as
slaves (some games also allow you to select Relay mode that is like a live tv show of the race :) )

When running with network enabled, it's very likely that Windows or your firewall will warn about
the emulator trying to access the network. You must allow it (or open these ports in your firewalls) or
the network won't run.


KNOWN ISSUES

General
There are no options, so don't hammer the "Options..." menu :)
Sometimes emulator doesn't return from fullscreen (Solution: kill with ALT-F4)
Mipmaps give too blurry textures (bad mipmap level selection). When mipmap is enabled, you might
see bad colors in the border of transparent textures (blending of "transparent" color with
actual color).

SGT 24h
Enter test mode and set control type to A or you'll get reversed pedal control

HOTD, GUNBLADE NY and BEL require that you calibrate the gun before playing!!!!

SKI Super G
After the letters appear, the screen is full white (the logo should show), insert a coin or wait.

OverRev
The cars in the demo mode drive quite strange.
