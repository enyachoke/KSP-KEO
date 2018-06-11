// monitoring options: partcount? name change ? rootpart change?
//for now stick with name change, it happens when subassembly with the core is detached
//requires at least one RT antenna to be tagged as Omni

print "Hibernating until wake-up protocol initiated.".

set wakeup to false.
set oldName to ship:name.
until wakeup
{
	wait 0.5.
	if ship:name <> oldName
	{
		set wakeup to true.
	}
}

wait 0.5.

//at this point we assume control only of commsat, not the mothership
print "Running wake-up routines".

list engines in engList.

for e in engList
{
	e:activate().
}
wait 0.5.

if engList:length >0 
{
	print "Engines activated!".
	print "Getting away from mothership".

	//TODO: consider equiping sats with multidirectional RCS and modify script to steer away from Mothership using Vector opposite of Mothership:position
	//This is needed in case of attachment of sats in tri-coupler
	//this also means that waiting 3 seconds should be replaces with proper wait until distance > some_threshold
	set ship:control:mainthrottle to 0.2.
	wait 0.2.
	set ship:control:mainthrottle to 0.
	wait 3.
}
else
{
	print "Using RCS to get away from mothership".
	rcs on.
	set ship:control:fore to 1.
	wait 0.5.
	set ship:control:fore to 0.
	rcs off.
	wait 3.

}

print "Extending panels, antennas".
panels on.
set antenna to ship:partstagged("Omni")[0]:getmodule("ModuleRTAntenna").
antenna:doevent("activate").

print "Renaming vessel".

set newVesselName to "SAT - " + body:name + " " + round(ship:apoapsis/100000)*100 + "km CommSat ".

//find all sats in constellation
list targets in allShips.
set totalSats to 1.
set constellationSats to List().
for s in allShips
{
	if s:name = newVesselName + totalSats
	{
		set totalSats to totalSats + 1.
		constellationSats:Add(s).
	}
}
if totalSats > 1
{
	print "Found existing CommSat constellation around " + round(ship:apoapsis/100000)*100 + "km orbit.".
}

//TODO: tag probeCore with option to either auto adjust orbital period to match constellation or wait for user to adjust orbit.
if totalSats > 1
{
	print "Adjusting orbital period to match that of vessel " + newVesselName + 1.
	print "Target threshold is 0.3 sec.".
	switch to 1.
	run match_OP(constellationSats[0]:obt:period, 0.5).
}

set newVesselName to newVesselName + totalSats.
print "Renaming vessel to " + newVesselName.
set ship:name to newVesselName.

//clean the bootloader script name to avoid weird behaviour.
DELETEPATH("1:/boot.ks"). 

print "Wake-up routines complete, awaiting further commands.".
print "Don't forget to target dish antennas.".
print "Turning on SAS.".
sas on.


