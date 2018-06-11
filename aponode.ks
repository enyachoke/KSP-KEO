declare parameter alt.
// create maneuver node at apoapsis which sets the orbit to alt.
set vom to velocity:orbit:mag.  					// actual velocity
set r to body:radius + ship:altitude. 				// actual distance to body
set ra to body:radius + ship:obt:apoapsis.			// radius in apoapsis
set va to sqrt( vom^2 + 2*body:mu*(1/ra - 1/r) ). 	// velocity in apoapsis
set a to ship:obt:semimajoraxis. 					// semi major axis present orbit
// future orbit properties
set r2 to body:radius + ship:obt:apoapsis.				// distance after burn at apoapsis
set a2 to (alt + 2*body:radius + ship:obt:apoapsis)/2.	// semi major axis target orbit
set v2 to sqrt( vom^2 + (body:mu * (2/r2 - 2/r + 1/a - 1/a2 ) ) ).
// setup node 
set deltav to v2 - va.

set nd to node(time:seconds + eta:apoapsis, 0, 0, deltav).
add nd.


