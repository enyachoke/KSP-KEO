//matches orbital period to target orbital period with given threshold using either prograde or retrograde burns executed immidiately
declare parameter tgtOP.
declare parameter threshold.

rcs off.
sas off.

set OP to ship:obt:period.

set done to false.

if tgtOP > OP 
{
	lock steering to prograde.
	wait until abs(prograde:pitch - facing:pitch) < 0.14 and abs(prograde:yaw - facing:yaw) < 0.14.
	set dir to 1.
	print "Burning prograde to adjust orbital period to " + round(tgtOP,2) + "s".
}
else
{
	lock steering to retrograde.
	wait until abs(retrograde:pitch - facing:pitch) < 0.15 and abs(retrograde:yaw - facing:yaw) < 0.15.
	set dir to -1.
	print "Burning retrograde to adjust orbital period to " + round(tgtOP,2) + "s".
}

list engines in e.

if e:length = 0 
{
	set done to true.
	//probe doesn't have engines - proceed to rcs only adjustment
}

if abs(tgtOP - OP) <= 10
{
	//orbital periods are close enough, proceed to RCS fine tuning
	set done to true.
}

set tset to 0.
lock throttle to tset.
until done
{
	set OP to ship:obt:period.
	//full throttle until difference is less than 100 seconds, then gradually less to a minimum
	set tset to min(0.01 + abs(tgtOP - OP)/100,1).

	if dir=1 and OP >= tgtOP+1
	{
		//we slightly overshot the tgtOP, will fine tune later with retrograde RCS burns
		set tset to 0.
		set done to true.
	}

	if dir=-1 and OP <= tgtOP-1
	{
		//we slightly undershot the tgtOP,  will fine tune later with retrograde RCS burns
		set tset to 0.
		set done to true.
	}

	wait 0.005.
}

//at this point we are quite close to target OP, need to fine tune with RCS
//assumes controlfrom part is aligned properly with ship.
set done to false.

//assumes we only have RCS thrusters on top of the sat
//can be simplified 
if tgtOP < OP 
{
	lock steering to prograde.
	wait until abs(prograde:pitch - facing:pitch) < 0.16 and abs(prograde:yaw - facing:yaw) < 0.16.
	set dir to 1.
}
else
{
	lock steering to retrograde.
	wait until abs(retrograde:pitch - facing:pitch) < 0.145 and abs(retrograde:yaw - facing:yaw) < 0.145.
	set dir to -1.
}

rcs on.
set startingT to time:seconds.
print "Fine tuning with threshold of " + round(threshold,2) + "s with RCS".
until done
{
	set OP to ship:obt:period.
	if abs (OP- tgtOP) <= threshold
	{
		set ship:control:fore to 0.
		set done to true.
	}
	else
	{
		//small retrograde RCS impulses
		set ship:control:fore to (-1) * (0.01 + abs(tgtOP - OP)/10).
	}

	if time:seconds - startingT > 10
	{
		//something is wrong, abort fine tuning
		set ship:control:fore to 0.
		set done to true.
	}

	wait 0.001.
}

rcs off.
