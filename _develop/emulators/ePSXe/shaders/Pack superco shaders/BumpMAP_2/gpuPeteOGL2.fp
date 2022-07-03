!!ARBfp1.0

PARAM exp  = 10;
PARAM spc  = { 0.5, 0.5, 0.5, 0 };
PARAM lVec = { 0, 0, 1, 0 };
PARAM eVec = { 0.35777, 0.2683, 0.8944, 0};
PARAM gray = { 0.299, 0.587, 0.114, 0 };

TEMP r1, r2, r3, r4, r5, r6;                     

TEX  r1, fragment.texcoord[0], texture[0], 2D;       
DP3  r3.y, r1, gray;

TEX  r2, fragment.texcoord[1], texture[0], 2D;     
DP3  r4.y, r2, gray;

SUB  r3.z, r3.y, r4.y;
MUL  r3.z, r3.z, 4.0;

TEX  r1, fragment.texcoord[2], texture[0], 2D;    
DP3  r3.y, r1, gray;

TEX  r2, fragment.texcoord[3], texture[0], 2D;     
DP3  r4.y, r2, gray;

SUB  r4.z, r3.y, r4.y;
MUL  r4.z, r4.z, 4.0;

MOV  r3.xy, { 1, 0, 0, 0 };
MOV  r4.xy, { 0, 1, 0, 0 };
XPD  r2, r3, r4;

DP3  r3, r2, r2;                      
RSQ  r3, r3.w;                        
MUL  r2, r2, r3;

DP3  r3, r2, lVec;
MUL  r3, r3, 2;
MAD  r3, r3, r2,-lVec;       

DP3_SAT  r2, eVec, r3;  
POW  r2, r2.w, exp.x;
SUB  r2, r2, 0.30;

TEX  r4, fragment.texcoord[4], texture[0], 2D; 

MAD  result.color, spc, r2, r4;

END
