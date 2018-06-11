// launch to polar orbit 
declare parameter orbitAlt.     //desired alt
declare parameter gt0.          //gravity turn start altitude
declare parameter gt1.          //gravity turn end altitude
declare parameter pitch0.       //initial pitch to start gravity turn
declare parameter maxq.         //desired maxq
declare parameter optimalTWR.   //desired starting twr

//set defaults in case zero parameters passed
if orbitAlt = 0 { set orbitAlt to 80000. }
if gt0 = 0 { set gt0 to 150. }
if gt1 = 0 { set gt1 to 50000.}
if pitch0 = 0 { set pitch0 to 1.1.}
if maxq = 0 { set maxq to 7000. }
if optimalTWR = 0 { set optimalTWR to 1.4. }

run db.

set tset to 1.

lock heregrav to body:mu/((altitude+body:radius)^2).
lock twr to ship:control:mainthrottle*maxthrust/(heregrav*mass).
lock maxtwr to maxthrust/(heregrav*mass).

lock throttle to tset. 
lock steering to lookdirup(up:vector, ship:facing:topvector).

wait 1.

clearscreen.

print "T+" + round(missiontime) + " Ignition.".
stage.

//set up staging
run staging.

if maxtwr > 0 
{
	print "T+" + round(missiontime) + " Max TWR: " + round(maxtwr,2).
	print "T+" + round(missiontime) + " Locking throttle to " + round(optimalTWR/maxtwr*100,0) + "%".  
	
	set tset to min(optimalTWR/maxtwr,1).
}

set optimalThrottle to tset.

// control speed and attitude
set pitch to 0.

until altitude > ha or apoapsis > orbitAlt {
    set ar to alt:radar.
    // control attitude
	
	if ar < gt0 {
        set arr to ar / gt0.
        set pda to (cos(arr * 180) + 1) / 2.
        set pitch to pitch0 * ( pda - 1 ).
        set pitchvector to heading(160,90-pitch).
        lock steering to lookdirup(pitchvector:vector, ship:facing:topvector).
    }
	
    if ar > gt0 and ar < gt1 {
        //keep the ship's roll always top
		set pitchvector to heading(180,90-pitch).
		
        lock steering to lookdirup(srfprograde:vector, ship:facing:topvector).
    }
    if ar > gt1 {
        //we can turn orbital prograde now
        lock steering to lookdirup(prograde:vector, ship:facing:topvector).
    }

    // dynamic pressure q
    set vsm to velocity:surface:mag.
    set exp to -altitude/sh.
    set ad to ad0 * euler^exp.    // atmospheric density
    set q to 0.5 * ad * vsm^2.

    print "q: " + round(q)  + "  " at (20,14).
    // calculate target velocity
    set vl to maxq*0.9.
    set vh to maxq*1.1.

	//keep throttle at optimal levels until gravity turn
	if ar < gt0 and maxtwr > 0 {
		set tset to optimalThrottle.
	}
	else {
		if q < vl { set tset to 1. }
		if q > vl and q < vh { set tset to (vh-q)/(vh-vl). }
		if q > vh { set tset to 0. }
	}
    print "alt:radar: " + round(ar) + "  " at (0,13). 
	print "srf:pitch: " + round(90-srfprograde:pitch,2) + "  " at (20,13). 
    print "throttle: " + round(tset,2) + "   " at (0,14).
    print "apoapis: " + round(apoapsis/1000) at (0,15).
    print "periapis: " + round(periapsis/1000) at (20,15).
    wait 0.1.
}
set tset to 0.
print "                   " at (0,13).
print "                   " at (20,13).
print "                   " at (20,14).
if altitude < ha {
    print "T+" + round(missiontime) + " Waiting to leave atmosphere".
	
    lock steering to lookdirup(prograde:vector, ship:facing:topvector).
    // thrust to compensate atmospheric drag losses
    until altitude > ha {
        // calculate target velocity
        if apoapsis >= orbitAlt { set tset to 0. }
        if apoapsis < orbitAlt { set tset to (orbitAlt - apoapsis)/(orbitAlt*0.01). }
        print "throttle: " + round(tset,2) + "    " at (0,14).
        print "apoapis: " + round(apoapsis/1000,2) at (0,15).
        print "periapis: " + round(periapsis/1000,2) at (20,15).
        wait 0.1.
    }
}
print "                                        " at (0,13).
print "                                        " at (0,14).
print "                                        " at (0,15).
lock throttle to 0.
// aponode works only in vacuum as it uses ship v to calc apoapsis velocity
run aponode(orbitAlt).
run exenode.
