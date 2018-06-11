// set celestial body properties
// ease future parametrisation
set b to body:name.
set mu to 0.

set mu to body:mu.
set rb to body:radius.

if body:atm:exists
{
	set sh to 5000.
	set ha to body:atm:height.
	set ad0 to 1.2230948554874 * body:atm:sealevelpressure. // atmospheric density at msl [kg/m^3]
}
else
{
	set sh to 0.
	set ha to 0.
	set ad0 to 0.
}

if b = "Kerbin" {
    set soi to 84159286.        // sphere of influence [m]
    set lorb to 80000.          // low orbit altitude [m]
}
if b = "Mun" {
    set soi to 2429559.
    set lorb to 14000. 
}
if b = "Minmus" {
    set soi to 2247428.
    set lorb to 10000. 
}
if mu = 0 {
    print "T+" + round(missiontime) + " WARNING: no body properties for " + b + "!".
}
if mu > 0 {
    print "T+" + round(missiontime) + " Loaded body properties for " + b.
}
set euler to constant():e.
set pi to constant():pi.
// fix NaN and Infinity push on stack errors, https://github.com/KSP-KOS/KOS/issues/152
set config:safe to False.