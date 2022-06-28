local flx = fe.layout.width;
local fly = fe.layout.height;
local flw = fe.layout.width;
local flh = fe.layout.height;


function reload(str) { if ( str == "custom2" ) fe.signal("reload") }
fe.add_signal_handler(this, "reload")