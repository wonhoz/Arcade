/*===============================================================================*\
|########################   [GLSL PSXFX SHADER V1.0]    #########################|
|########################	   [BY ASMODEAN@PCSX2]	     #########################|
||																				 ||
||			  		   ,---.  .---..-.   .-.  ,---..-.   .-.					 ||
||					   | .-.\( .-._)) \_/ /   | .-' ) \_/ / 					 ||
||					   | |-' )) \  (_)   /    | `-.(_)   /  					 ||
||					   | |--'_ \ \   / _ \    | .-'  / _ \  					 ||
||					   | | ( `-'  ) / / ) \   | |   / / ) \ 					 ||
||					   /(   `----' `-' (_)-'  )\|  `-' (_)-'					 ||
||					  (__)                   (__)           					 ||
||																				 ||
||		  This program is free software; you can redistribute it and/or			 ||
||		  modify it under the terms of the GNU General Public License			 ||
||		  as published by the Free Software Foundation; either version 2		 ||
||		  of the License, or (at your option) any later version.				 ||
||																				 ||
||		  This program is distributed in the hope that it will be useful,		 ||
||		  but WITHOUT ANY WARRANTY; without even the implied warranty of		 ||
||		  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the			 ||
||		  GNU General Public License for more details.							 ||
||						     [Inspired by SweetFX]								 ||
|#################################################################################|
\*===============================================================================*/

[Release Notes #1 18/03/2013]
*Fixed(hopefully) clamping issues with the luma/color correction. (black negative values for certain luma colors) - status: Fixed
Added Point Light Attenuation, light map (testing)
Amended the Dithering color bit values, should now have better coverage.

[Installation]
Simply extract or copy the PsxFX folder (except userDefineLang.xml) into either, -  
	
	[For edgbla's gpuBladeSoft]: Extract the PsxFX folder to the shader directory 'shaders' of your PSX emu (I personally use PCSXR, but it works just as well on ePSXe), and to use, select PsxFX shader effect in the plugin options.
	[For Pete's OGL2]: Extract the PsxFX folder to the shader directory 'shaders' of your PSX emu, and to use, copy from the PsxFX folder, into the root of the shaders folder.
	[For Aali's Custom Graphics Driver] Rename 'gpuPeteOGL2.slf' to 'gpuPeteOGL2.post', or '"whatever".post', and 'gpuPeteOGL2.slv' to 'main.vert', then enable in Aali's config file in the shaders section, swap out the names.
	
[Optional]
If you use Notepad++ [http://notepad-plus-plus.org/] (I recommend it for editing options etc) I've included my own user defined HLSL/GLSL language, syntax highlighter, for much greater readability.
	
	[To Use]: User defined Notepad++ languages are generally stored in: C:\Users\"username"\AppData\Roaming\Notepad++.(it will have other .xml docs there) Extract/copy userDefineLang.xml to this location. 
	Once userDefineLang.xml is copied to that location, open up the shader with Notepad++ and click Language (top menu) and scroll to the end and select the user defined one, and you should be good to go.

	
[Tweaking Options]
	Open up the shader (preferably with the above method) and each section is labeled. In the [DEFINITIONS & ON/OFF OPTIONS] you can turn each desired shader effects on, or off. 
	Most are enabled as default, but each can be enabled, or disabled independantly of each other.
	
	Each of the enabled options can also be tuned to the user's preferences, by using the SHADER FX CONFIG OPTIONS section, feel free to experiment. Notice that some options what I thought were pretty self explanatory were not commented on, as of yet.
	

Please remember that, this was originally done for personal use, as I personally wasn't content with using the current shaders for Psx emulation, and this has had no external testing up to this point, I'm not even certain yet if this will work on AMD cards, as I've not had access to one at the moment, yet.

I appreciate constructive, helpful feedback & testing from users of this.

Regards,
Kieran Hanrahan ( Asmodean )