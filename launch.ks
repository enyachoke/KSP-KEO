//Automation script for CommSat deployment

//declare parameter initialOrbit.
//declare parameter satOrbit.
//declare parameter orbitType.

// copy exenode to 1.
// copy aponode to 1.
// copy sat_deploy to 1.
// copy match_OP to 1.
// copy warpfor to 1.
sas on .
rcs on .
set initialOrbit to 80000.
set satOrbit to 777000.
set orbitType to "E".

if orbitType = "P"
{
	run ascend_p(initialOrbit, 400, 50000, 1.1, 8000, 1.4).
}
else
{
	run ascend(initialOrbit, 500, 50000, 2, 8000, 1.4).
}
switch to 1.
//decouple mothership from delivery stage
// stage.
//activate antenna
// print "Activating mothership antenna".
set antenna to ship:partstagged("MSOmni")[0]:getmodule("ModuleRTAntenna").
antenna:doevent("activate").

print "Activating solar panels".
set ms_panels to ship:partstagged("MSPanel").
for ms_panel in ms_panels
{
	set ms_panel_module to ms_panel:getmodule("ModuleDeployableSolarPanel").
	ms_panel_module:doevent("extend solar panel").
}

//assumes that all further orbital maneuvers can be made on single stage
print "Circularizing at " + satOrbit + " m orbit".

wait 2.
//circulirize at satOrbit
run aponode(satOrbit).
run exenode.
run aponode(satOrbit).
run exenode.

print "Waiting until 60 seconds to apoapsis".

run warpfor(eta:apoapsis - 60).
run sat_deploy.

wait 25.

print "Relocating to a resonant orbit.".

set resonantOP to ship:obt:period * 0.666667.

print "Resonant orbit period: " + round(resonantOP,2).

run match_OP(resonantOP, 1).

run aponode(satOrbit).
run exenode.

run warpfor(eta:apoapsis - 60).
run sat_deploy.
//wait for sat to adjust it's orbital period.
wait 25.

print "Relocating back to a resonant orbit.".
run match_OP(resonantOP, 1).

run aponode(satOrbit).
run exenode.

run warpfor(eta:apoapsis - 60).
run sat_deploy.

print "3 sats deployed, de-orbiting in 25 seconds".
wait 25.

//assumes there is enough fuel left to de-orbit properly.
lock steering to retrograde.
wait until abs(retrograde:pitch - facing:pitch) < 0.148 and abs(retrograde:yaw - facing:yaw) < 0.148.

lock throttle to 1.
wait until (ship:obt:periapsis <0 or ship:maxthrust = 0).

print "Mothership is set for sub-orbital trajectory or ran out of fuel trying".
