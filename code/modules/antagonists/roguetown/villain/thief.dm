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

	return ..()

/datum/antagonist/thief/greet()
	to_chat(owner.current, span_userdanger("You've worked in the manor for years, always overlooked, always underappreciated."))
	to_chat(owner.current, span_danger("You know every corner, every secret passage in the manor. Now it's time to take what you deserve - the Lord's crown."))
	to_chat(owner.current, span_danger("Your insider knowledge gives you an advantage. Be careful, betrayal is punished harshly in these lands."))
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
	
	// Add thief traits
	ADD_TRAIT(H, TRAIT_GENERIC, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC) // Knowledge of the manor layout

/datum/antagonist/thief/proc/add_objectives()
	var/datum/objective/steal/steal_obj = new
	steal_obj.owner = owner
	steal_obj.set_target(locate(/obj/item/clothing/head/roguetown/crown/serpcrown) in world)
	steal_obj.explanation_text = "Steal the Lord's Crown."
	objectives += steal_obj
	
	var/datum/objective/survive/survive_obj = new
	survive_obj.owner = owner
	objectives += survive_obj

