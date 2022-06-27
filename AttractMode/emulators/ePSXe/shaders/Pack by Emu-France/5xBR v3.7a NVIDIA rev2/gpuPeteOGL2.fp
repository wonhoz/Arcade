!!ARBfp1.0
OPTION NV_fragment_program2;
OPTION ARB_precision_hint_fastest;
#
#  Hyllian's 5xBR v3.7a Shader
#  
#  Copyright (C) 2011 Hyllian/Jararaca - sergiogdb@gmail.com
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
PARAM c[6] = { { 1024, 512, 1, -1 },
		{ 0.5, 2, -0.5, -2 },
		{ 2, 0, -1, 0.5 },
		{ 3, 4, 2 },
		{ 1, -0.5, 0 },
		{ 1.5, 0.5, -0.5 } };
SHORT TEMP H0;
SHORT TEMP H1;
SHORT TEMP H2;
SHORT TEMP H3;
SHORT TEMP H4;
SHORT TEMP H5;
SHORT TEMP H6;
SHORT TEMP H7;
SHORT TEMP H8;
SHORT TEMP H9;
SHORT TEMP H10;
SHORT TEMP H11;
SHORT TEMP H12;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   H7.xyz, fragment.texcoord[2].ywzw, texture[0], 2D;
TEX   H1.xyz, fragment.texcoord[3].zwzw, texture[0], 2D;
TEX   H8.xyz, fragment.texcoord[2].zwzw, texture[0], 2D;
DP3H  H1.w, H1, c[3];
TEX   H0.xyz, fragment.texcoord[3].xwzw, texture[0], 2D;
DP3H  H1.z, H0, c[3];
TEX   H0.xyz, fragment.texcoord[1].zwzw, texture[0], 2D;
TEX   H2.xyz, fragment.texcoord[1].xwzw, texture[0], 2D;
DP3H  H1.x, H0, c[3];
TEX   H9.xyz, fragment.texcoord[3].ywzw, texture[0], 2D;
TEX   H11.xyz, fragment.texcoord[1].ywzw, texture[0], 2D;
TEX   H10.xyz, fragment.texcoord[2].xwzw, texture[0], 2D;
DP3H  H0.w, H8, c[3];
DP3H  H0.z, H9, c[3];
DP3H  H0.x, H11, c[3];
DP3H  H0.y, H10, c[3];
DP3H  H1.y, H2, c[3];
ADDH  H3, -H1, H0.zwxy;
ADDH  H2, -H1.zwxy, H0.wxyz;
MULH  H4, H3, H3;
MULH  H5, H2, H2;
MULH  H2, H4, c[1].y;
SGEH  H6, H5, H2;
DP3H  H7.w, H7, c[3];
MULH  H5, H5, c[1].y;
SLEH  H5, H5, H4;
SNEH  H4, H0.yzwx, H1.zwxy;
MOVH  oCol.xyz, H7;
SNEH  H3, H0, H1;
SNEH  H2, H7.w, H1;
MULX  H3, H2, H3;
MULX  H3, H3, H6;
MULX  H2, H2.zwxy, H4;
MULH  H6.xy, fragment.texcoord[2].ywzw, c[0];
FRCH  H6.zw, H6.xyxy;
MULH  H6.xy, H6.w, c[0].zwzw;
MULX  H4, H2, H5;
MADH  H5, H6.z, c[0].zzww, H6.xyyx;
MADH  H2, H6.z, c[1], H6.xyyx;
SGTH  H5, H5, c[5].xyzy;
SGTH  H2, H2, c[4].xxyz;
MADX_SAT H4, H2, H4, H5;
MADH  H2, H6.z, c[1].yxwz, H6.xyyx;
ADDH  H5, H7.w, -H1.zwxy;
MULH  H6, H5, H5;
SGTH  H2, H2, c[2];
MADX_SAT H2, H2, H3, H4;
TEX   H3.xyz, fragment.texcoord[0].ywzw, texture[0], 2D;
TEX   H4.xyz, fragment.texcoord[5].xzzw, texture[0], 2D;
DP3H  H3.w, H4, c[3];
DP3H  H3.z, H3, c[3];
TEX   H4.xyz, fragment.texcoord[6].xzzw, texture[0], 2D;
TEX   H12.xyz, fragment.texcoord[4].ywzw, texture[0], 2D;
DP3H  H3.y, H4, c[3];
DP3H  H3.x, H12, c[3];
ADDH  H4, H1.wxyz, -H3;
MADH  H5, H5.zwxy, H5.zwxy, H6;
MADH  H4, H4, H4, H5;
ADDH  H1, H1.wxyz, -H3.yzwx;
MADH  H3, H1, H1, H4;
ADDH  H1, H0.zwxy, -H0.yzwx;
MADH  H3, -H1, H1, H3;
TEX   H1.xyz, fragment.texcoord[0].xwzw, texture[0], 2D;
TEX   H4.xyz, fragment.texcoord[5].xwzw, texture[0], 2D;
DP3H  H1.w, H4, c[3];
DP3H  H1.z, H1, c[3];
TEX   H5.xyz, fragment.texcoord[4].zwzw, texture[0], 2D;
TEX   H4.xyz, fragment.texcoord[6], texture[0], 2D;
DP3H  H1.x, H5, c[3];
DP3H  H1.y, H4, c[3];
ADDH  H1, H0.zwxy, -H1;
MADH  H4, -H1, H1, H3;
TEX   H1.xyz, fragment.texcoord[5], texture[0], 2D;
TEX   H3.xyz, fragment.texcoord[4].xwzw, texture[0], 2D;
DP3H  H1.w, H3, c[3];
DP3H  H1.z, H1, c[3];
TEX   H3.xyz, fragment.texcoord[0].zwzw, texture[0], 2D;
TEX   H5.xyz, fragment.texcoord[6].xwzw, texture[0], 2D;
DP3H  H1.y, H3, c[3];
DP3H  H1.x, H5, c[3];
ADDH  H3, H0.wxyz, -H1;
MADH  H3, -H3, H3, H4;
ADDH  H1, H0.wxyz, -H0;
MADH  H4, H1.wxyz, H1.wxyz, -H6.yzwx;
MADH  H1, -H1, H1, H3;
MULH  H3, H4, c[3].y;
ADDH  H4, H7.w, -H0.wxyz;
SLTH  H1, H1, -H3;
MULH  H3, H4, H4;
SNEH  H0, H7.w, H0.wxyz;
MULX  H0, H0, H0.wxyz;
MULX  H0, H0, H1;
SLEH  H3, H3, H3.wxyz;
MULX  H0, H2, H0;
SEQX  H1, H3.yzwx, c[2].y;
MULX  H1, H0.yzwx, H1;
MADX_SAT H0, H0, H3, H1;
MOVXC RC.x, H0;
SEQX  H1.xyz, H0, c[2].y;
MOVH  oCol.xyz(NE.x), H8;
MULXC HC.x, H1, H0.y;
MOVH  oCol.xyz(NE.x), H11;
MULX  H0.x, H1, H1.y;
MULXC HC.x, H0, H0.z;
MOVH  oCol.xyz(NE.x), H10;
MULX  H0.x, H0, H1.z;
MULXC HC.x, H0, H0.w;
MOVH  oCol.xyz(NE.x), H9;
END
# 108 instructions, 0 R-regs, 13 H-regs
# 1 mov, 21 tex, 0 complex, 86 math
# Opcode counts:
#     ???:     1 (  0.9%)
#     ???:     1 (  0.9%)
#     ???:     1 (  0.9%)
#     ???:    10 (  9.3%)
#     ???:    21 ( 19.4%)
#     ???:    22 ( 20.4%)
#     ???:     2 (  1.9%)
#     ???:     1 (  0.9%)
#     ???:     3 (  2.8%)
#     ???:     2 (  1.9%)
#     ???:     1 (  0.9%)
#     ???:     4 (  3.7%)
#     ???:     4 (  3.7%)
#     ???:    14 ( 13.0%)
#     ???:    21 ( 19.4%)
# Total      108 (100.0%)
# Parameter counts:
#                 tot size samp sclr    1    2    3    4  3x3  4x4  NxM    ?
#   Uniform in:    10   33    1    0    0    0    3    6    0    0    0    0
#   Varying in:     8   32    0    0    0    0    0    8    0    0    0    0
#  Varying out:     1    4    0    0    0    0    0    1    0    0    0    0
#                 tot   1D   2D   3D CUBE RECT 2DSH    ?
#     Samplers:     1    0    1    0    0    0    0    0
