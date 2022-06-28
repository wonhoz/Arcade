
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
MinValue = 0.50
MaxValue = 4.0
StepAmount = 0.10
DefaultValue = 2.00
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
	
	sp(rx, -1, -1) 	sp(ct,0,0)
	sp(uy, 0, -1) 
    sp(dy,0,1) sp(lx,1,0)

 float d1 = 2.5*dot(abs(lx-rx),dt)/(dot(lx+rx,dt)+0.50);
 float d2 = 2.5*dot(abs(uy-dy),dt)/(dot(uy+dy,dt)+0.50);
 float d  = d1 + d2;

color.xyz = (1.15-bb*pow(max(d-th,0.0),pp))*ct;
	}
    SetOutput(color);
}