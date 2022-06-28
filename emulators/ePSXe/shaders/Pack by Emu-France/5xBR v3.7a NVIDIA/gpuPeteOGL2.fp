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
PARAM c[6] = { { 1024, 512, 4, 2 },
		{ 14, 28, 5, 0 },
		{ 1, -1, -0.5, 0 },
		{ 1.5, 0.5, -0.5 },
		{ 0.5, 2, -0.5, -2 },
		{ 2, 0, -1, 0.5 } };
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
SHORT TEMP H13;
SHORT TEMP H14;
SHORT TEMP H15;
SHORT TEMP H16;
SHORT TEMP H17;
SHORT TEMP H18;
SHORT TEMP H19;
TEMP RC;
TEMP HC;
OUTPUT oCol = result.color;
TEX   H14.xyz, fragment.texcoord[2].zwzw, texture[0], 2D;
DP3H  H2.x, H14, c[1];
TEX   H11.xyz, fragment.texcoord[1].ywzw, texture[0], 2D;
DP3H  H18.x, H11, c[1];
TEX   H12.xyz, fragment.texcoord[2].xwzw, texture[0], 2D;
DP3H  H17.x, H12, c[1];
TEX   H15.xyz, fragment.texcoord[3].ywzw, texture[0], 2D;
DP3H  H0.x, H15, c[1];
TEX   H1.xyz, fragment.texcoord[3].xwzw, texture[0], 2D;
TEX   H3.xyz, fragment.texcoord[3].zwzw, texture[0], 2D;
DP3H  H16.x, H3, c[1];
DP3H  H1.x, H1, c[1];
TEX   H3.xyz, fragment.texcoord[1].zwzw, texture[0], 2D;
DP3H  H3.x, H3, c[1];
TEX   H4.xyz, fragment.texcoord[1].xwzw, texture[0], 2D;
DP3H  H12.w, H4, c[1];
TEX   H13.xyz, fragment.texcoord[2].ywzw, texture[0], 2D;
MULH  H9.xy, fragment.texcoord[2].ywzw, c[0];
FRCH  H16.zw, H9.xyxy;
MULH  H9, H16.z, c[4];
MADH  H10, H16.w, c[2].xyyx, H9;
MADH  H9, H16.w, c[2].xyyx, H9.yxwz;
DP3H  H11.w, H13, c[1];
MOVH  H2.w, H0.x;
MOVH  H0.y, H2.x;
MOVH  H2.y, H18.x;
MOVH  H2.z, H17.x;
MOVH  H0.z, H18.x;
MOVH  H0.w, H17.x;
SGTH  H9, H9, c[5];
MOVH  H1.z, H3.x;
MOVH  H3.z, H1.x;
MOVH  H16.y, H3.x;
MOVH  H1.y, H16.x;
MOVH  H1.w, H12;
ADDH  H5, H2, -H1;
MOVH  H3.y, H12.w;
MOVH  H3.w, H16.x;
ADDH  H4, H0, -H3;
SNEH  H7, H11.w, H3;
MULH  H6, H5, H5;
MULH  H4, H4, H4;
MULH  H5, H4, c[0].w;
SGEH  H8, H6, H5;
SNEH  H5, H11.w, H0;
MULX  H7, H5, H7;
MULX  H7, H7, H8;
MULH  H6, H6, c[0].w;
SLEH  H8, H6, H4;
SNEH  H4, H11.w, H2;
SNEH  H6, H11.w, H1;
MULX  H6, H4, H6;
MULX  H6, H6, H8;
MULH  H8.xy, H16.z, c[2];
MADH  H8, H16.w, c[2].xyyx, H8.xxyy;
SGTH  H8, H8, c[3].xyzy;
SGTH  H10, H10, c[2].xxzw;
MADX_SAT H6, H6, H10, H8;
MADX_SAT H6, H7, H9, H6;
TEX   H8.xyz, fragment.texcoord[4].zwzw, texture[0], 2D;
TEX   H10.xyz, fragment.texcoord[6], texture[0], 2D;
DP3H  H16.zw, H10, c[1];
DP3H  H8.x, H8, c[1];
MOVH  H8.y, H16.w;
MOVH  H16.w, H1.x;
TEX   H10.xyz, fragment.texcoord[0].xwzw, texture[0], 2D;
DP3H  H8.z, H10, c[1];
TEX   H19.xyz, fragment.texcoord[5].xwzw, texture[0], 2D;
DP3H  H8.w, H19, c[1];
ADDH  H8, H0, -H8;
ADDH  H1, H11.w, -H1;
MULH  H1, H1, H1;
ADDH  H3, H11.w, -H3;
MADH  H3, H3, H3, H1;
TEX   H1.xyz, fragment.texcoord[6].xzzw, texture[0], 2D;
MULH  H7, H8, H8;
DP3H  H1.x, H1, c[1];
MOVH  H17.y, H0.x;
MOVH  H17.z, H2.x;
MOVH  H17.w, H18.x;
ADDH  H8, H0, -H17;
MADH  H8, H8, H8, H7;
TEX   H9.xyz, fragment.texcoord[0].zwzw, texture[0], 2D;
MOVH  H7.x, H16.z;
DP3H  H7.y, H9, c[1];
TEX   H9.xyz, fragment.texcoord[5], texture[0], 2D;
DP3H  H7.z, H9, c[1];
TEX   H10.xyz, fragment.texcoord[4].xwzw, texture[0], 2D;
DP3H  H7.w, H10, c[1];
ADDH  H7, H2, -H7;
TEX   H10.xyz, fragment.texcoord[5].xzzw, texture[0], 2D;
DP3H  H1.z, H10, c[1];
MADH  H7, H7, H7, H8;
MOVH  H16.z, H12.w;
MOVH  H18.w, H2.x;
MOVH  H18.z, H0.x;
MOVH  H18.y, H17.x;
ADDH  H8, H2, -H18;
MADH  H8, H8, H8, H7;
ADDH  H7, H11.w, -H16;
MULH  H7, H7, H7;
MADH  H7, H7, c[0].z, H8;
TEX   H8.xyz, fragment.texcoord[4].ywzw, texture[0], 2D;
DP3H  H9.x, H8, c[1];
TEX   H8.xyz, fragment.texcoord[0].ywzw, texture[0], 2D;
DP3H  H1.y, H8, c[1];
MOVH  H9.y, H1.x;
MOVH  H9.w, H1.z;
MOVH  H9.z, H1.y;
ADDH  H8, H16, -H9;
MADH  H8, H8, H8, H3;
ADDH  H3, -H2, H0;
MOVH  H1.w, H9.x;
ADDH  H1, H16, -H1;
ADDH  H0, H11.w, -H0;
ADDH  H2, H11.w, -H2;
MULH  H3, H3, H3;
MADH  H1, H1, H1, H8;
MADH  H1, H3, c[0].z, H1;
MULX  H3, H4, H5;
SLTH  H1, H1, H7;
MULX  H1, H3, H1;
MULX  H1, H1, H6;
SEQX  H3, H1, c[1].w;
MULX  H3.y, H3.x, H3;
MULX  H3.z, H3.y, H3;
MOVH  H4.xyz, H12;
MULH  H2, H2, H2;
MULH  H0, H0, H0;
SLEH  H0, H2, H0;
SEQX  H0, H0.xwzy, c[1].w;
MULX  H1.w, H1, H3.z;
MULXC HC.x, H1.w, H0.y;
MOVH  H2.xyz, H15;
MOVH  H2.xyz(NE.x), H12;
MULXC HC.x, H3.w, H3.z;
MOVH  H2.xyz(NE.x), H13;
MULX  H0.y, H1.z, H3;
MULXC HC.x, H0.y, H0.z;
MOVH  H4.xyz(NE.x), H11;
MOVXC RC.x, H3.z;
MOVH  H4.xyz(NE.x), H2;
MULX  H0.y, H1, H3.x;
MOVH  H2.xyz, H11;
MULXC HC.x, H0.y, H0.w;
MOVH  H2.xyz(NE.x), H14;
MOVXC RC.x, H3.y;
MOVH  H2.xyz(NE.x), H4;
MOVH  oCol.xyz, H14;
MULXC HC.x, H1, H0;
MOVH  oCol.xyz(NE.x), H15;
MOVXC RC.x, H1;
MOVH  oCol.xyz(EQ.x), H2;
MOVH  oCol.w, c[2].x;
END
