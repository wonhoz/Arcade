!ARBfp1.0

TEMP color0, color1, color2, color3, color4, color5, color6;

PARAM toGray = { 0.3, 0.59, 0.11, 0.0 };
PARAM divtwo = { 0.5, 0.5, 0.5, 0.0 };

# c = texture2DProj(OGL2Texture, gl_TexCoord[0]); //center
# l = texture2DProj(OGL2Texture, gl_TexCoord[1]); //left
# tl = texture2DProj(OGL2Texture, gl_TexCoord[2]); //top-left
# t = texture2DProj(OGL2Texture, gl_TexCoord[3]); //top
# r = texture2DProj(OGL2Texture, gl_TexCoord[4]); //right
# br = texture2DProj(OGL2Texture, gl_TexCoord[5]); //bottom-right
# b = texture2DProj(OGL2Texture, gl_TexCoord[6]); //bottom

TEX color0, fragment.texcoord[ 0 ], texture[ 0 ], 2D;
TEX color1, fragment.texcoord[ 1 ], texture[ 0 ], 2D;
TEX color2, fragment.texcoord[ 2 ], texture[ 0 ], 2D;
TEX color3, fragment.texcoord[ 3 ], texture[ 0 ], 2D;
TEX color4, fragment.texcoord[ 4 ], texture[ 0 ], 2D;
TEX color5, fragment.texcoord[ 5 ], texture[ 0 ], 2D;
TEX color6, fragment.texcoord[ 6 ], texture[ 0 ], 2D;

# calculate emboss

# 0.5 * (r + b) + -0.5 * (l + t) + (br - tl);

ADD color4, color4, color6;
ADD color1, color1, color3;
ADD color5, color5,-color2;
MUL color4, color4, divtwo;
MUL color1, color1, divtwo;
ADD color1,-color1, color4;
ADD color1, color1, color5;
DP3 color1, color1, toGray;

# add emboss to color0

ADD result.color, color0, color1;

END