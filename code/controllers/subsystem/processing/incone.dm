// Smooth HUD updates, but low priority
SUBSYSTEM_DEF(incone)
	name = "incone"
	wait = 1
	flags = SS_NO_INIT
	priority = FIRE_PRIORITY_INCONE
	var/list/processing = list()
	var/list/currentrun = list()
	processing_flag = PROCESSING_INCONE

/datum/controller/subsystem/incone/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while (currentrun.len)
		var/client/thing = currentrun[currentrun.len]
		currentrun.len--
		if (!thing || QDELETED(thing))
			processing -= thing
			if (MC_TICK_CHECK)
				return
			continue
		
		// Only update if the client still exists and has a mob
		if(thing && thing.mob)
			thing.update_cone()
			
		if (MC_TICK_CHECK)
			return
