// execute maneuver node
set nd to nextnode.

print "T+" + round(missiontime) + " Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

set maxa to maxthrust/mass.
set dob to nd:deltav:mag/maxa.
print "T+" + round(missiontime) + " Max acc: " + round(maxa) + "m/s^2, Burn duration: " + round(dob) + "s".
run warpfor(nd:eta - dob/2 - 60).

// turn does not work during warp - so do now
print "T+" + round(missiontime) + " Turning ship to burn direction.".
sas off.
//rcs off.

set np to lookdirup(nd:deltav, ship:facing:topvector). //points to node, keeping roll the same.
lock steering to np.

//np is a Vector and Facing is a direction.
wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.
run warpfor(nd:eta - dob/2).

print "T+" + round(missiontime) + " Orbital burn start " + round(nd:eta) + "s before apoapsis.".

set tset to 0.
lock throttle to tset.
// keep ship oriented to burn direction even with small dv where node:prograde wanders off 
set np to lookdirup(nd:deltav, ship:facing:topvector).//points to node, keeping roll the same.

lock steering to np.
set done to False.
set once to True.
set dv0 to nd:deltav.
until done {
    set maxa to maxthrust/mass.
    set tset to min(nd:deltav:mag/maxa, 1).
    if once and tset < 1 {
        print "T+" + round(missiontime) + " Throttling down, remain dv " + round(nd:deltav:mag) + "m/s, fuel:" + round(stage:liquidfuel).
        set once to False.
    }
    if vdot(dv0, nd:deltav) < 0 {
        print "T+" + round(missiontime) + " End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        lock throttle to 0.
        break.
    }
    if nd:deltav:mag < 0.1 {
        print "T+" + round(missiontime) + " Finalizing, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        wait until vdot(dv0, nd:deltav) < 0.5.
        lock throttle to 0.
        print "T+" + round(missiontime) + " End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set done to True.
    }
}
unlock steering.
print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000,2) + "km, periapsis: " + round(periapsis/1000,2) + "km".
print "T+" + round(missiontime) + " Fuel after burn: " + round(stage:liquidfuel).
wait 1.
remove nd.

//set throttle to 0 just in case.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
