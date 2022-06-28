!!ARBfp1.0

# simple adds values from texture unit 0 (psx display) and texture unit 1 (custom texture)
# how to set up the texture units 1-7? by placing "gpuPeteOGL2_t??.tga" files in the shader folder!
# look in my "broken glass" shader for details.

TEMP	color0, color1;

TEX	color0, fragment.texcoord[ 0 ], texture[ 0 ], 2D;
TEX	color1, fragment.texcoord[ 1 ], texture[ 1 ], 2D;

ADD	result.color, color0, color1;

END
