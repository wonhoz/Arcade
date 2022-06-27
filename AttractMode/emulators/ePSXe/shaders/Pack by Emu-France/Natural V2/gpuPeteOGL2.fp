!!ARBfp1.0

TEMP c0, c1, c2, c3;
TEMP r1, r2, r3, r4, r5;

TEX c0, fragment.texcoord[0].xwzw, texture[0], 2D;
TEX c1, fragment.texcoord[0].zyzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[0], texture[0], 2D;
MAD c0, c1, 2.25, c0;

TEX c1, fragment.texcoord[1].xwzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[1].zyzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[1], texture[0], 2D;
MAD c0, c1, 2.25, c0;

TEX c1, fragment.texcoord[2].xwzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[2].zyzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[2], texture[0], 2D;
MAD c0, c1, 2.25, c0;

TEX c1, fragment.texcoord[3].xwzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[3].zyzw, texture[0], 2D;
ADD c0, c1, c0;
TEX c1, fragment.texcoord[3], texture[0], 2D;
MAD c0, c1, 2.25, c0;

MUL c0, c0, 0.18479956785822313167427314019291;

COS c0.x, c0.x;
COS c0.y, c0.y;
COS c0.z, c0.z;

MAD result.color,-0.5, c0, 0.5;

END
