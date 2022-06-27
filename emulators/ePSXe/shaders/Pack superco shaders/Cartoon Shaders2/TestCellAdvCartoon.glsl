
/*
   Copyright (C) 2006 guest(r) - guest.r@gmail.com
*/

/*
[configuration]

[OptionBool]
GUIName = Cartoon
OptionName = cartoon
DefaultValue = true

[OptionRangeFloat]
GUIName = Sensitivity (0.1)
OptionName = sense
MinValue = 0.0
MaxValue = 0.5
StepAmount = 0.01
DefaultValue = 0.1
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Strength (0.37)
OptionName = str
MinValue = 0.10
MaxValue = 2.0
StepAmount = 0.10
DefaultValue = 0.37
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Blackening (1.5)
OptionName = black
MinValue = .25
MaxValue = 2.0
StepAmount = 0.10
DefaultValue = 1.5
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Brightness (0.25)
OptionName = bright
MinValue = 0
MaxValue = 3
StepAmount = 0.1
DefaultValue = 0.25
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Washout (2)
OptionName = wash
MinValue = 0
MaxValue = 4
StepAmount = 0.1
DefaultValue = 2.0
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Color Average (0)
OptionName = averg
MinValue = 0
MaxValue = 1
StepAmount = 1
DefaultValue = 0
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Colors (4)
OptionName = colors
MinValue = 2.75
MaxValue = 3.25
StepAmount = 0.01
DefaultValue = 4.0
DependantOption = cartoon

[/configuration]
*/

float th = GetOption(sense);      // outlines sensitivity, recommended from 0.00...0.50
float bb = GetOption(str);      // outlines strength,    recommended from 0.10...2.00
float pp = GetOption(black);      // outlines blackening,  recommended from 0.25...2.00
const float3 dt = float3(1.0,1.0,1.0); 
float x = GetInvResolution().x; //(OGL2Size.x/2048.0)*OGL2Param.x;
float y = GetInvResolution().y; //(OGL2Size.y/1024.0)*OGL2Param.y;
#define sp(a, b, c) float3 a = SampleLocation(GetCoordinates()+GetInvResolution()*float2(b, c)).xyz;

void main() {
	float4 color = Sample();
	if OptionEnabled(cartoon) {
	
	sp(c00, -1, -1) 	sp(c11,0,0)   sp(c22, 1, 1)
	sp(c10, 0, -1) sp(c20, 1, -1) 
	sp(c01, -1, 0) sp(c02, -1, 1)
    sp(c12,0,1) sp(c21,1,0)

	float d1=dot(abs(c00-c22),dt);
	float d2=dot(abs(c20-c02),dt);
	float hl=dot(abs(c01-c21),dt);
	float vl=dot(abs(c10-c12),dt);
	if (GetOption(averg) == 1) { c11 = (c11+ 0.5*(c01+c10+c21+c12)+ 0.25*(c00+c22+c20+c02))/4.0;}
	float d = bb*pow(max(d1+d2+hl+vl-th,0.0),pp)/(dot(c11,dt)+0.25);

	float lc = 4.0*length(c11); 
	lc = 0.2*(floor(lc) + pow(fract(lc),GetOption(wash)));
	c11 = GetOption(colors)*normalize(c11); 
	float3 frct = fract(c11); frct*=frct;
	c11 = floor(c11) + frct*frct;
	c11 = (GetOption(bright)/GetOption(colors))*(c11)*lc; lc*=0.577;
	c11 = mix(c11,lc*dt,lc);
	color.xyz = (1.1-d)*c11;
	}
    SetOutput(color);
}