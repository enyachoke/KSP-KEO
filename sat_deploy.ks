//adjust this file for your vessel

print "Trying to deploy sattelite".

set deployDocks to ship:partstagged("SatDeployDock").

for d in deployDocks
{
	set d1 to d:getmodule("ModuleDockingNode").
	if d1:allevents[0] = "(callable) decouple node, is KSPEvent"
	{
		d1:doevent("decouple node").
		print "Decoupling Sat".
		break.
	}
}

