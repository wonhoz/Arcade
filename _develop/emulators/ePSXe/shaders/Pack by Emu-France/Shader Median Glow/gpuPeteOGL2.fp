!!ARBfp1.0

# pseudo-median filter

# variable we'll need

TEMP	color0, color1, color2, color3;
TEMP	colora, colorb, colorc;

# and contants for determining effects
# toGlow can be altered to different sensitivities
# for example, to increase only the blue's brightness
# you might use { 0.1, 0.8, 0.1 };
# and to supersaturate (HDL effect), use values that add to more than 1.0
# PETE added: I like a decent glowing... something like "toGlow = { 0.05, 0.05, 0.05, 0.0 };" :)  

PARAM	toGlow = { 0.5, 0.5, 0.5, 0.0 };
PARAM	toFlat = { 0.6, 0.6, 0.6, 0.0 };
PARAM	toGray = { 0.4, 0.2, 0.4, 0.0 };

TEX	color0, fragment.texcoord[ 0 ], texture[ 0 ], 2D;
TEX	color1, fragment.texcoord[ 1 ], texture[ 0 ], 2D;
TEX	color2, fragment.texcoord[ 2 ], texture[ 0 ], 2D;
TEX	color3, fragment.texcoord[ 3 ], texture[ 0 ], 2D;

# find the maximum

MAX	colora, color0, color1;
MAX	colorb, color2, color3;
MAX	colora, colora, colorb;

# find the minimum

MIN	colorb, color0, color1;
MIN	colorc, color2, color3;
MIN	colorb, colorb, colorc;

# add the minimum and maximum

ADD	colorb, colora, colorb;

# add all the colors together

ADD	color0, color0, color1;
ADD	color2, color2, color3;
ADD	color0, color0, color2;

# take off the minimum and maximum
# and average the result
# blend in the average luma for a
# subtle 2x2 glow effect

DP3	colora, colora, toGray;
MUL	colora, colora, colora;
MUL	colora, colora, toGlow;
ADD	color0, color0, -colorb;
MUL	color0, color0, toFlat;
ADD	result.color, color0, colora;

END
