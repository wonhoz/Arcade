!!ARBfp1.0

PARAM exp  = 40;
PARAM spc  = { 0.75, 0.75, 0.75, 0 };
PARAM lVec = { 0, 0, 1, 0 };
PARAM eVec = { 0.35777, 0.2683, 0.8944, 0};
PARAM gray = { 0.299, 0.587, 0.114, 0 };

TEMP r1, r2, r3, r4;                     

# sample and filter height-map
                        
TEX  r1, fragment.texcoord[0], texture[0], 2D;       
DP3  r3.y, r1, gray;

TEX  r2, fragment.texcoord[1], texture[0], 2D;     
DP3  r4.y, r2, gray;

SUB  r3.z, r3.y, r4.y;

TEX  r1, fragment.texcoord[2], texture[0], 2D;    
DP3  r3.y, r1, gray;

TEX  r2, fragment.texcoord[3], texture[0], 2D;     
DP3  r4.y, r2, gray;

SUB  r4.z, r3.y, r4.y;

# compute normal

MOV  r3.xy, { 1, 0, 0, 0 };
MOV  r4.xy, { 0, 1, 0, 0 };
XPD  r2, r3, r4;

# normalize normal

DP3  r3, r2, r2;                      
RSQ  r3, r3.w;                        
MUL  r2, r2, r3;                   

# compute reflection vector

DP3  r3, r2, lVec;
MUL  r3, r3, 2;
MAD  r3, r3, r2,-lVec;       

# compute specular

DP3_SAT  r2, eVec, r3;  
POW  r2, r2.w, exp.x;

# sample texture

TEX  r4, fragment.texcoord[4], texture[0], 2D; 

# do (pseudo) bump-map 

MAD  result.color, spc, r2, r4;

END
