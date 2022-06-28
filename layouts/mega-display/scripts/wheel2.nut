class UserConfig {
 </ label="Select spinwheel art", help="The artwork to spin", options="marquee, wheel", order=3 /> orbit_art="wheel";
   
</ label="Select vertart instead of wheel", help="Select vertical or wheel art", options="Yes,No", order=4 /> enable_VertArt="No";
   
</ label="Transition Time", help="Time in milliseconds for wheel spin.", order=10 /> transition_ms="25";
}

local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;
local my_config = fe.get_config();

//This enables vertical art instead of default wheel
if ( my_config["enable_VertArt"] == "Yes") 
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.010, flx*0.050, flx*0.075 , flx*0.040, flx*0.033, flx*0.011, flx*0.005, flx*0.009, flx*0.005, flx*0.045, flx*0.050, flx*0.008, ]; 
local wheel_y = [ -fly*0.220, -fly*0.105, -fly*0.010, fly*0.080, fly*0.200, fly*0.300, fly*0.436, fly*0.610, fly*0.720 fly*0.830, fly*0.935, fly*0.990, ];
local wheel_w = [ flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, ];
local wheel_a = [  80,  80,  40,  70,  120,  180, 255,  180,  180,  120,  30,  80, ];
local wheel_h = [  flh*0.110,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130, flh*0.168,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130, ];
local wheel_r = [  0, 0, 22, 16, 13, 10, 0, -10, -12, -17, -22, -10, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
	base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}
 else
{
fe.load_module( "conveyor" );
local wheel_x = [ flx*0.010, flx*0.050, flx*0.075 , flx*0.040, flx*0.033, flx*0.011, flx*0.005, flx*0.009, flx*0.005, flx*0.045, flx*0.050, flx*0.008, ]; 
local wheel_y = [ -fly*0.220, -fly*0.105, -fly*0.010, fly*0.080, fly*0.200, fly*0.300, fly*0.436, fly*0.610, fly*0.720 fly*0.830, fly*0.935, fly*0.990, ];
local wheel_w = [ flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, flw*0.190, ];
local wheel_a = [  80,  80,  40,  70,  120,  180, 255,  180,  180,  120,  30,  80, ];
local wheel_h = [  flh*0.110,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130, flh*0.168,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130,  flh*0.130, ];
local wheel_r = [  0, 0, 22, 16, 13, 10, 0, -10, -12, -17, -22, -10, ];
local num_arts = 8;

class WheelEntry extends ConveyorSlot
{
	constructor()
	{
		base.constructor( ::fe.add_artwork( my_config["orbit_art"] ) );
	}

	function on_progress( progress, var )
	{
		local p = progress / 0.1;
		local slot = p.tointeger();
		p -= slot;
		
		slot++;

		if ( slot < 0 ) slot=0;
		if ( slot >=10 ) slot=10;

		m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
		m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
		m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
		m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
		m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
		m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
	}
};

local wheel_entries = [];
for ( local i=0; i<num_arts/2; i++ )
	wheel_entries.push( WheelEntry() );

local remaining = num_arts - wheel_entries.len();

// we do it this way so that the last wheelentry created is the middle one showing the current
// selection (putting it at the top of the draw order)
for ( local i=0; i<remaining; i++ )
wheel_entries.insert( num_arts/2, WheelEntry() );

local conveyor = Conveyor();
conveyor.set_slots( wheel_entries );
conveyor.transition_ms = 50;
try { conveyor.transition_ms = my_config["transition_ms"].tointeger(); } catch ( e ) { }
}


