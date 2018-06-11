
set stagemaxthrust to ship:maxthrust.
when status <> "PRELAUNCH" and (ship:maxthrust<stagemaxthrust or ship:maxthrust<1) then {
    print "Stage!".
    stage.
    set stagemaxthrust to ship:maxthrust.
    preserve.
}