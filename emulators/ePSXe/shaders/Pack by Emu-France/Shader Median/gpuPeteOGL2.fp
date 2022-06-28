!!ARBfp1.0

# pseudo-median filter

TEMP	color0, color1, color2, color3;
TEMP	colora, colorb, colorc;
PARAM	toFlat = { 0.5, 0.5, 0.5, 0.0 };

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

# add the colors together

ADD	color0, color0, color1;
ADD	color2, color2, color3;
ADD	color0, color0, color2;

# take off the minimum and maximum
# and average the result

ADD	color0, color0, -colorb;
MUL	result.color, color0, toFlat;

END
