//Contains the target item datums for Steal objectives.

/datum/objective_item
	var/name = "A silly bike horn! Honk!"
	var/targetitem = /obj/item/paper	//typepath of the objective item
	var/difficulty = 9001							//vaguely how hard it is to do this objective
	var/list/excludefromjob = list()				//If you don't want a job to get a certain objective (no captain stealing his own medal, etcetc)
	var/list/altitems = list()				//Items which can serve as an alternative to the objective (darn you blueprints)
	var/list/special_equipment = list()

/datum/objective_item/proc/check_special_completion() //for objectives with special checks (is that slime extract unused? does that intellicard have an ai in it? etcetc)
	return 1

/datum/objective_item/proc/TargetExists()
	return TRUE

/datum/objective_item/steal/New()
	..()
	if(TargetExists())
		GLOB.possible_items += src
	else
		qdel(src)

/datum/objective_item/steal/Destroy()
	GLOB.possible_items -= src
	return ..()

/datum/objective_item/steal/rogue/treasure
	name = "one of the Lord's treasures."
	targetitem = null // Will be set during New()
	difficulty = 1
	var/static/list/possible_treasures

/datum/objective_item/steal/rogue/treasure/New()
	// Initialize the list of possible treasures if needed
	if(!possible_treasures)
		possible_treasures = list()
		
		// Add subtypes of /obj/item/treasure
		var/list/treasure_types = subtypesof(/obj/item/treasure)
		treasure_types -= /obj/item/treasure // Remove the base type
		possible_treasures += treasure_types
	
	// Select a random treasure subtype
	if(length(possible_treasures))
		var/treasure_type = pick(possible_treasures)
		targetitem = treasure_type
		var/obj/item/T = treasure_type
		name = "the [initial(T.name)]"
	else
		// Fallback in case no treasures are found
		targetitem = /obj/item/treasure/brooch
		name = "the Countess Elira's Brooch"
	
	..() // Call parent New()

/datum/objective_item/steal/rogue/treasure/check_special_completion(obj/item/I)
	// Check if the item is a subtype of /obj/item/treasure
	if(istype(I, /obj/item/treasure))
		return TRUE
	
	return FALSE
