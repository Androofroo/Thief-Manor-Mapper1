#define TRAIT_ALWAYS_SILENT_STEP "always_silent_step"

/obj/item/treasure/silent_steps
	name = "Ring of Silent Steps"
	desc = "A mysterious ring that absorbs all sound from the wearer's movements. Perfect for those who prefer to remain unheard."
	icon_state = "dragonring" // Using existing icon temporarily
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/roguetown/clothing/rings.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/rings.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/rings.dmi'
	sleevetype = "shirt"
	icon_state = "dragonring"
	slot_flags = ITEM_SLOT_RING
	resistance_flags = FIRE_PROOF | ACID_PROOF
	anvilrepair = /datum/skill/craft/armorsmithing
	experimental_inhand = FALSE
	drop_sound = 'sound/foley/coinphy (1).ogg'

	var/active_item = FALSE
	var/silent_footstep_type

/obj/item/treasure/silent_steps/equipped(mob/living/user, slot)
	. = ..()
	if(active_item)
		return
	else if(slot == SLOT_RING)
		active_item = TRUE
		to_chat(user, span_notice("Your footsteps fade to nothing as you slip on the ring."))
		ADD_TRAIT(user, TRAIT_LIGHT_STEP, "silent_steps_ring")
		ADD_TRAIT(user, TRAIT_ALWAYS_SILENT_STEP, "silent_steps_ring")
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(suppress_rustle))
		// Replace the standard footstep component
		for(var/datum/component/footstep/F in user.GetComponents(/datum/component/footstep))
			silent_footstep_type = F.footstep_type
			F.RemoveComponent()
		
		// Add our special silent footstep component
		user.AddComponent(/datum/component/silent_footstep, silent_footstep_type)
	return

/obj/item/treasure/silent_steps/dropped(mob/living/user)
	..()
	if(active_item)
		to_chat(user, span_notice("Your footsteps return as you remove the ring."))
		REMOVE_TRAIT(user, TRAIT_LIGHT_STEP, "silent_steps_ring")
		REMOVE_TRAIT(user, TRAIT_ALWAYS_SILENT_STEP, "silent_steps_ring")
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
		
		// Remove silent footstep component and restore normal one
		for(var/datum/component/silent_footstep/F in user.GetComponents(/datum/component/silent_footstep))
			var/footstep_type = F.footstep_type
			F.RemoveComponent()
			user.AddComponent(/datum/component/footstep, footstep_type)
		
		active_item = FALSE
	return

/obj/item/treasure/silent_steps/proc/suppress_rustle(mob/living/user)
	SIGNAL_HANDLER
	// Prevent rustle sounds from playing by resetting move counters on equipped items
	for(var/obj/item/clothing/gear in user.get_equipped_items())
		for(var/datum/component/item_equipped_movement_rustle/R in gear.GetComponents(/datum/component/item_equipped_movement_rustle))
			R.move_counter = 0
	return

// Custom silent footstep component
/datum/component/silent_footstep
	var/footstep_type
	var/steps = 0
	
/datum/component/silent_footstep/Initialize(footstep_type_)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	footstep_type = footstep_type_
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(silent_step))

/datum/component/silent_footstep/proc/silent_step()
	SIGNAL_HANDLER
	// This component does nothing - it just prevents normal footstep sounds
	return

/obj/item/treasure
	name = "Treasure"
	desc = "How are you seeing this?"
	icon_state = "treasure"
	var/difficulty = 0

/obj/item/treasure/marriagecontract
	name = "Forged Marriage Contract"
	desc = "A forged marriage contract that may erupt scandal in the noble realm.."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "contractsigned"
	difficulty = 1

/obj/item/treasure/ledger
	name = "Manor Ledger"
	desc = "A ledger that contains the records of the manor. Who knows what blackmail material is hidden within?"
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "spellbookyellow_0"
	difficulty = 1

/obj/item/treasure/brooch
	name = "Countess Elira's Brooch"
	desc = "A golden heirloom set with a rare violet gem. Missing for years… or was it just hidden?"
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "ring_onyx"
	difficulty = 5

/obj/item/treasure/wine
	name = "Vintage Wine"
	desc = "A bottle of luxurious wine aged since year 401. It's said to have a unique flavor that can only be found in the finest vintages. Far too valuable to drink."
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "lovebottle"
	difficulty = 1

/obj/item/treasure/gemerald
	name = "Massive Gemerald"
	desc = "An absurdly large green gemstone—gaudy, cut, and almost too heavy to wear—rumored to have been pried from the eye socket of a fallen statue in an ancient ruin. Its true value is debated, but its sheer size makes it irresistible to thieves and impossible to hide discreetly."
	icon = 'icons/roguetown/items/gems.dmi'
	icon_state = "emerald_cut"
	difficulty = 1

/obj/item/treasure/blackmail
	name = "Perfumed Letters"
	desc = "Delicate, romantic, and politically dangerous if discovered."
	icon = 'icons/roguetown/items/cooking.dmi'
	icon_state = "bottle_message"
	difficulty = 1


