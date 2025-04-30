/datum/antagonist/thief
	name = "Thief"
	roundend_category = "Thieves"
	antagpanel_category = "Thief"

	confess_lines = list(
		"I betrayed the lord and stole his crown!",
		"These valuables? I... found them!",
		"I was just going to return it, I swear!",
	)
	rogue_enabled = TRUE
	thief_enabled = TRUE // This will make it visible in villain selection

/datum/antagonist/thief/on_gain()
	. = ..()
	owner.special_role = name
	equip_thief()
	greet()
	add_objectives()
	finalize_thief()

	return ..()

/datum/antagonist/thief/proc/finalize_thief()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/thief.ogg', 60, FALSE, pressure_affected = FALSE)
	var/mob/living/carbon/human/H = owner.current
	ADD_TRAIT(H, TRAIT_GENERIC, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC) // Knowledge of the manor layout
	to_chat(H, span_alertsyndie("I am a THIEF!"))
	to_chat(H, span_boldwarning("I've worked in the manor for years, always overlooked, always underappreciated. I know every corner, every secret passage. Now it's time to take what I deserve - the Lord's Crown. My insider knowledge gives me an advantage, but betrayal is punished harshly in these lands."))

/datum/antagonist/thief/greet()
	owner.announce_objectives()

/datum/antagonist/thief/proc/equip_thief()
	var/mob/living/carbon/human/H = owner.current
	
	// Improve stealth-related skills
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	
	// Servant-specific skills
	H.mind.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
	
	// Slight stat adjustments
	H.change_stat("dexterity", 3)
	H.change_stat("intelligence", 2)
	H.change_stat("perception", 3)
	H.change_stat("speed", 1)

/datum/antagonist/thief/proc/add_objectives()
	var/datum/objective/steal/steal_obj = new
	steal_obj.owner = owner
	
	// Make sure GLOB.possible_items is populated
	if(!GLOB.possible_items.len)
		for(var/I in subtypesof(/datum/objective_item/steal/rogue))
			new I
	
	// Find the target item in GLOB.possible_items instead of directly setting steal_target
	for(var/datum/objective_item/possible_item in GLOB.possible_items)
		if(istype(possible_item, /datum/objective_item/steal/rogue/crown))
			steal_obj.targetinfo = possible_item
			steal_obj.steal_target = possible_item.targetitem
			steal_obj.explanation_text = "Steal the Lord's Crown."
			break
	
	objectives += steal_obj
	
	var/datum/objective/survive/survive_obj = new
	survive_obj.owner = owner
	objectives += survive_obj

