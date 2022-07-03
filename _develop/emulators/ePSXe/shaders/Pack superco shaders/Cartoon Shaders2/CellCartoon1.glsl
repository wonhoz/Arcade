
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
GUIName = Strength (0.50)
OptionName = str
MinValue = 0.10
MaxValue = 2.0
StepAmount = 0.10
DefaultValue = 0.50
DependantOption = cartoon

[OptionRangeFloat]
GUIName = Blackening (1.5)
OptionName = black
MinValue = .25
MaxValue = 2.0
StepAmount = 0.10
DefaultValue = 1.5
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
	
	float d=bb*pow(max(d1+d2+hl+vl-th,0.0),pp)/(dot(c11,dt)+0.5);

	color.xyz = (1.1-d)*c11;
	}
    SetOutput(color);
}