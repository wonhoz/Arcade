require("model2");	-- Import model2 machine globals

function Init()
	
end

function Frame()
	local gameState = I960_ReadByte(0x5010A4)

	if   gameState==0x16	-- Ingame
	  or gameState==0x03	-- Attract ini
	  or gameState==0x04	-- Attract Higscore ini
	  or gameState==0x05	-- Attract Highscore
	  or gameState==0x06	-- Attract VR Ini
	  or gameState==0x07	-- Attract VR
	then
	 	Model2_SetStretchBLow(1)	-- Stretch the bg tilemap (sky & clouds) when widescreen
		Model2_SetWideScreen(1)
	else					-- No widescreen on the rest of the screens
	 	Model2_SetStretchBLow(0)
		Model2_SetWideScreen(0)
	end

end

--Some sample code follows to show how to draw strings and setup options/cheats
--
--function PostDraw()
--	Video_DrawText(20,10,HEX32(I960_GetRamPtr(RAMBASE)),0xFFFFFF);
--	Video_DrawText(20,10,HEX32(I960_ReadWord(RAMBASE+0x10D0)),0xFFFFFF);
--	Video_DrawText(20,20,HEX32(RAMBASE),0xFFFFFF);
--	Video_DrawText(20,30,Options.cheat1.value,0xFFFFFF);
--	Video_DrawText(20,40,Input_IsKeyPressed(0x1E),0xFFFFFF);
--end
--
--function cheat1func(value)
--	
--end
--
--function cheat1change(value)
--
--end
--
--

function timecheatfunc(value)
	I960_WriteWord(RAMBASE+0x10D0,50*64);	--50 seconds always
end

Options =
{
--	cheat1={name="Cheat 1",values={"Off","On"},runfunc=cheat1func,changefunc=cheat1change},
	timecheat={name="Infinite Time",values={"Off","On"},runfunc=timecheatfunc}
}
