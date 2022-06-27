!!ARBfp1.0

#   Hyllian's 5xBR v3.5a Shader
#   
#   Copyright (C) 2011 Hyllian/Jararaca - sergiogdb@gmail.com
#
#   This program is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

PARAM c[7] = {{ 1024.0, 512.0, 0, 0 },
		{ 1, 0, 2, 4 },
		{ 14.359375, 28.171875, 5.4726563 },
		{ 1.5, 0.5, -0.5 },
		{ 1, -1, -0.5, 0 },
		{ 0.5, 2, -0.5, -2 },
		{ 2, 0, -1, 0.5 } };
TEMP R0;
TEMP R1;
TEMP R2;
TEMP R3;
TEMP R4;
TEMP R5;
TEMP R6;
TEMP R7;
TEMP R8;
TEMP R9;
TEMP R10;
TEMP R11;
TEMP R12;
TEMP R13;
TEMP R14;
TEMP R15;
TEMP R16;
TEMP R17;
TEMP R18;
TEMP R19;
TEMP R20;
TEMP R21;
TEMP R22;
MOV R2, fragment.texcoord[1];
ADD R12.zw, fragment.texcoord[0].xyxy, -R2.xyxy;
ADD R0.xy, fragment.texcoord[0], R2.zwzw;
ADD R12.xy, fragment.texcoord[0], R2;
TEX R1.xyz, R0, texture[0], 2D;
TEX R0.xyz, R12, texture[0], 2D;
ADD R2.zw, fragment.texcoord[0].xyxy, -R2;
DP3 R1.w, R1, c[2];
ABS R10, R1.w;
TEX R2.xyz, R2.zwzw, texture[0], 2D;
DP3 R0.w, R0, c[2];
ABS R11, R0.w;
MOV R5.y, R11;
TEX R3.xyz, R12.zwzw, texture[0], 2D;
DP3 R1.w, R2, c[2];
ABS R14, R1.w;
MOV R4.w, R11;
DP3 R0.w, R3, c[2];
ABS R15, R0.w;
ADD R6.xy, -fragment.texcoord[1].zwzw, R12.zwzw;
TEX R6.xyz, R6, texture[0], 2D;
DP3 R0.w, R6, c[2];
ABS R18.xyz, R0.w;
ADD R6.xy, fragment.texcoord[1].zwzw, R12.zwzw;
ADD R4.xy, -fragment.texcoord[1].zwzw, R12;
TEX R4.xyz, R4, texture[0], 2D;
DP3 R1.w, R4, c[2];
ABS R16.xyz, R1.w;
ADD R4.xy, fragment.texcoord[1].zwzw, R12;
TEX R4.xyz, R4, texture[0], 2D;
DP3 R0.w, R4, c[2];
ABS R20.xyz, R0.w;
TEX R6.xyz, R6, texture[0], 2D;
DP3 R1.w, R6, c[2];
ABS R19.xyz, R1.w;
TEX R7.xyz, fragment.texcoord[0], texture[0], 2D;
DP3 R0.w, R7, c[2];
MOV R5.x, R10;
MOV R5.z, R14;
MOV R5.w, R15;
ABS R0.w, R0;
MOV R8.x, R16;
MOV R8.y, R18.x;
MOV R8.z, R19.y;
MOV R8.w, R20.z;
ADD R6, R5, -R8;
ABS R17, R6;
MOV R6.x, R11;
ADD R9, R0.w, -R8;
MOV R6.y, R14;
MOV R6.z, R15;
MOV R6.w, R10;
MOV R4.x, R14;
MOV R4.y, R15;
MOV R4.z, R10;
ADD R13, -R8, R4;
ABS R8, R13;
ABS R9, R9;
CMP R13, -R9, c[1].x, c[1].y;
CMP R8, -R8, c[1].x, c[1].y;
MUL R8, R13, R8;
MOV R13.z, R16;
MUL R16.zw, fragment.texcoord[0].xyxy, c[0].xyxy;
FRC R16.zw, R16;
MOV R13.x, R19;
MOV R13.w, R18.z;
MOV R13.y, R20;
ADD R21, R6, -R13;
MOV R11.x, R15;
MOV R11.y, R10;
MOV R11.w, R14;
ADD R14, -R13, R11;
ADD R13, R0.w, -R13;
ABS R13, R13;
ADD R11, R5, -R11;
ABS R14, R14;
ADD R9, R9, R13;
CMP R15, -R13, c[1].x, c[1].y;
CMP R14, -R14, c[1].x, c[1].y;
MUL R14, R15, R14;
MUL R15, R16.z, c[5].yxwz;
MUL R22, R17, c[1].z;
ABS R21, R21;
SGE R22, R21, R22;
MUL R21, R21, c[1].z;
SGE R10, R17, R21;
MUL R14, R10, R14;
MAD R10, R16.w, c[4].xyyx, R15;
MUL R15.xy, R16.z, c[4];
MUL R17, R16.z, c[5];
MAD R15, R16.w, c[4].xyyx, R15.xxyy;
MAD R17, R16.w, c[4].xyyx, R17;
SLT R10, c[6], R10;
SLT R17, c[4].xxzw, R17;
SLT R15, c[3].xyzy, R15;
MAD_SAT R14, R14, R17, R15;
MUL R15.xy, fragment.texcoord[1].zwzw, c[1].z;
ADD R15.zw, fragment.texcoord[0].xyxy, R15.xyxy;
TEX R17.xyz, R15.zwzw, texture[0], 2D;
DP3 R2.w, R17, c[2];
MUL R8, R22, R8;
MAD_SAT R8, R8, R10, R14;
MUL R14.zw, fragment.texcoord[1].xyxy, c[1].z;
ADD R14.xy, fragment.texcoord[0], R14.zwzw;
MOV R10.y, R16;
TEX R16.xyz, R14, texture[0], 2D;
DP3 R1.w, R16, c[2];
ABS R15.zw, R2.w;
ADD R14.zw, fragment.texcoord[0].xyxy, -R14;
ABS R19.xy, R1.w;
TEX R17.xyz, R14.zwzw, texture[0], 2D;
DP3 R1.w, R17, c[2];
MOV R10.z, R18.y;
ADD R16.zw, fragment.texcoord[0].xyxy, -R15.xyxy;
TEX R18.xyz, R16.zwzw, texture[0], 2D;
ABS R17.xy, R1.w;
DP3 R2.w, R18, c[2];
ABS R17.zw, R2.w;
MOV R10.x, R20;
MOV R10.w, R19.z;
MOV R16.x, R15.z;
MOV R16.w, R17.y;
MOV R16.y, R19;
MOV R16.z, R17.w;
ADD R16, R10, -R16;
ABS R13, R16;
MOV R16.w, R15;
ADD R13, R9, R13;
ADD R9, R5, -R6;
ADD R15.zw, R12, -R15.xyxy;
MOV R16.y, R17.z;
MOV R16.z, R17.x;
MOV R16.x, R19;
ADD R16, R10, -R16;
ABS R16, R16;
ADD R13, R13, R16;
TEX R16.xyz, R15.zwzw, texture[0], 2D;
ADD R15.zw, -fragment.texcoord[1], R14.xyxy;
DP3 R1.w, R16, c[2];
ADD R16.xy, fragment.texcoord[1].zwzw, R14.zwzw;
ADD R10, R0.w, -R10;
ABS R9, R9;
MAD R9, R9, c[1].w, R13;
ADD R13.xy, R12, R15;
TEX R13.xyz, R13, texture[0], 2D;
DP3 R2.w, R13, c[2];
ADD R12.xy, R12, -R15;
ADD R15.xy, R12.zwzw, R15;
TEX R17.xyz, R15.zwzw, texture[0], 2D;
ABS R13.x, R2.w;
DP3 R2.w, R17, c[2];
TEX R12.xyz, R12, texture[0], 2D;
ABS R13.y, R2.w;
DP3 R2.w, R12, c[2];
TEX R15.xyz, R15, texture[0], 2D;
ABS R13.z, R1.w;
TEX R16.xyz, R16, texture[0], 2D;
DP3 R1.w, R16, c[2];
ABS R13.w, R1;
DP3 R1.w, R15, c[2];
ADD R13, R5, -R13;
ADD R15.xy, -fragment.texcoord[1].zwzw, R14.zwzw;
ADD R14.xy, fragment.texcoord[1].zwzw, R14;
ABS R13, R13;
ABS R11, R11;
ADD R11, R11, R13;
ABS R12.y, R2.w;
TEX R14.xyz, R14, texture[0], 2D;
DP3 R2.w, R14, c[2];
ABS R12.w, R1;
TEX R15.xyz, R15, texture[0], 2D;
DP3 R1.w, R15, c[2];
ABS R12.x, R2.w;
ABS R12.z, R1.w;
ADD R12, R6, -R12;
ABS R13, R12;
ADD R12, R6, -R4;
ADD R4, R11, R13;
ABS R11, R12;
ADD R4, R4, R11;
ABS R10, R10;
MAD R10, R10, c[1].w, R4;
ADD R4, -R5, R0.w;
ADD R5, -R6, R0.w;
ABS R5, R5;
ABS R4, R4;
CMP R6, -R4, c[1].x, c[1].y;
CMP R11, -R5, c[1].x, c[1].y;
SGE R4, R4, R5;
MUL R6, R11, R6;
SLT R9, R9, R10;
MUL R6, R9, R6;
MUL R6, R6, R8;
ABS R0.w, R6.x;
ABS R1.w, R6.y;
CMP R0.w, -R0, c[1].y, c[1].x;
CMP R1.w, -R1, c[1].y, c[1].x;
MUL R5.w, R0, R1;
ABS R1.w, R4.z;
MUL R2.w, R6.z, R5;
CMP R1.w, -R1, c[1].y, c[1].x;
MUL R1.w, R2, R1;
CMP R5.xyz, -R1.w, R2, R3;
ABS R3.w, R6.z;
CMP R2.w, -R3, c[1].y, c[1].x;
MUL R4.z, R5.w, R2.w;
ABS R1.w, R4;
MUL R2.w, R6, R4.z;
CMP R1.w, -R1, c[1].y, c[1].x;
MUL R1.w, R2, R1;
ABS R3.w, R6;
CMP R2.w, -R3, c[1].y, c[1].x;
CMP R3.xyz, -R1.w, R3, R1;
MUL R1.w, R4.z, R2;
CMP R3.xyz, -R1.w, R7, R3;
ABS R2.w, R4.y;
ABS R1.w, R4.x;
CMP R1.w, -R1, c[1].y, c[1].x;
CMP R3.xyz, -R4.z, R3, R5;
MUL R3.w, R6.y, R0;
CMP R2.w, -R2, c[1].y, c[1].x;
MUL R2.w, R3, R2;
CMP R2.xyz, -R2.w, R0, R2;
MUL R1.w, R6.x, R1;
CMP R0.xyz, -R1.w, R1, R0;
CMP R1.xyz, -R5.w, R3, R2;
CMP result.color.xyz, -R0.w, R1, R0;
MOV result.color.w, c[1].x;
END
# 228 instructions, 23 R-regs
