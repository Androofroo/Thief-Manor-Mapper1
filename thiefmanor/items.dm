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

/obj/item/treasure/bond
	name = "Crown's Bond"
	desc = "A pledged promise from the Crown, promising a small fortune of gold to the bearer."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "confession"
	difficulty = 1

/obj/item/treasure/kassidy
	name = "Kassidy's Leotard"
	desc = "A leotard worn by the infamous Kassidy, rumored to have been used in a daring escape from the prison of the Countess."
	icon = 'icons/roguetown/items/misc.dmi'
	icon_state = "leotard"
	difficulty = 9

/obj/item/treasure/kassidy/proc/find_random_indoor_turf()
	var/list/valid_turfs = list()
	for(var/turf/open/floor/T in world)
		if(!T.is_blocked_turf(TRUE)) // Only check if the turf isn't blocked
			var/area/A = get_area(T)
			if(A && !A.outdoors) // Only check if the area is not outdoors
				// Skip centcom map (Z-level 2 is typically centcom)
				if(T.z == 2)
					continue
				valid_turfs += T
	
	if(valid_turfs.len)
		return pick(valid_turfs)
	return null

/obj/item/treasure/kassidy/Initialize(mapload)
	. = ..()
	if(!mapload)
		// Skip if we're on centcom (Z-level 2)
		if(src.z == 2)
			log_game("Kassidy's Leotard creation skipped on centcom map")
			return
		
		// If created during gameplay (not from map loading), place it in a random location
		var/turf/T = find_random_indoor_turf()
		if(T)
			forceMove(T)
			log_game("Kassidy's Leotard spawned at [AREACOORD(T)]")
		else
			// Fallback location - try to find a closet
			var/list/possible_closets = list()
			for(var/obj/structure/closet/C in world)
				// Skip closets on centcom
				if(C.z == 2)
					continue
				possible_closets += C
			
			if(length(possible_closets))
				var/obj/structure/closet/C = pick(possible_closets)
				forceMove(C)
				log_game("Kassidy's Leotard spawned in a closet at [AREACOORD(C)]")
			else
				log_game("ERROR: Failed to place Kassidy's Leotard anywhere on the map")

/obj/item/treasure/lens_of_truth
	name = "Mirror of Truth"
	desc = "A mysterious mirror that reveals hidden truths. When used on someone, it reveals their hidden past."
	icon = 'icons/roguetown/items/ore.dmi'
	icon_state = "ingotglass"
	w_class = WEIGHT_CLASS_TINY
	difficulty = 3
	var/next_use = 0
	var/cooldown_time = 300 // 30 seconds cooldown

/obj/item/treasure/lens_of_truth/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ismob(target) || !isliving(target))
		return
		
	var/mob/living/L = target
	
	if(world.time < next_use)
		to_chat(user, span_warning("The mirror needs [round((next_use - world.time)/10)] more seconds to recharge!"))
		return
	
	user.visible_message(span_notice("[user] holds up the [src] to [L]."), span_notice("You hold the [src] up to [L]."))
	
	if(!do_after(user, 30, target = L))
		to_chat(user, span_warning("You need to hold the mirror steady!"))
		return
	
	// Get say logs from the target's logging list
	var/list/say_log_messages = list()
	
	// Check EVERY POSSIBLE FORMAT we've found in the codebase
	// First, check standard LOG_SAY (1<<1 = 2)
	if(L.logging && L.logging["2"])
		for(var/entry in L.logging["2"])
			var/msg = L.logging["2"][entry]
			extract_speech(msg, say_log_messages)
	
	// Second variation, number as text "1" even though code defines LOG_SAY as 2
	if(L.logging && L.logging["1"]) 
		for(var/entry in L.logging["1"])
			var/msg = L.logging["1"][entry]
			extract_speech(msg, say_log_messages)
	
	// Check client logs if available
	if(L.client && L.client.player_details && L.client.player_details.logging)
		// Check both "2" and "1" for client logs
		if(L.client.player_details.logging["2"])
			for(var/entry in L.client.player_details.logging["2"])
				var/msg = L.client.player_details.logging["2"][entry]
				extract_speech(msg, say_log_messages)
		
		if(L.client.player_details.logging["1"]) 
			for(var/entry in L.client.player_details.logging["1"])
				var/msg = L.client.player_details.logging["1"][entry]
				extract_speech(msg, say_log_messages)
	
	// This is a custom fallback that will listen to the say logs in real-time
	// We should be able to capture at least one line this way
	if(!length(say_log_messages) && ishuman(L))
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			to_chat(human_user, span_warning("The mirror can't reveal anything... Try asking them to speak while you hold it up."))
			// Start monitoring their next speech
			addtimer(CALLBACK(src, PROC_REF(listen_for_speech), user, L), 5)
			return
	
	if(!length(say_log_messages))
		to_chat(user, span_warning("The mirror reveals nothing from [L]'s past words."))
		return
	
	// Get a random message from their speech logs
	var/message = pick(say_log_messages)
	
	to_chat(user, span_notice("The mirror shimmers, and you hear a whisper: \"[message]\""))
	playsound(get_turf(user), 'sound/foley/glassbreak.ogg', 25, TRUE)
	
	next_use = world.time + cooldown_time
	
	// Visual effect
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(L))
	shimmer.color = "#c0ffff"

// Helper proc to extract speech from log entries
/obj/item/treasure/lens_of_truth/proc/extract_speech(log_entry, list/output_list)
	if(!istext(log_entry) || !islist(output_list))
		return
	
	// First pattern: standard log format with quotes
	var/quote_start = findtext(log_entry, "\"")
	if(quote_start)
		var/quote_end = findtext(log_entry, "\"", quote_start + 1)
		if(quote_end)
			var/spoken_text = copytext(log_entry, quote_start + 1, quote_end)
			if(spoken_text && length(spoken_text) > 0)
				output_list |= spoken_text
				return
	
	// Second pattern: possible alternate format without quotes
	var/says_pos = findtext(log_entry, "says, ")
	if(says_pos)
		var/message_part = copytext(log_entry, says_pos + 6)
		if(message_part && length(message_part) > 0)
			output_list |= message_part
			return

// Sets up a listening callback for the target's next speech
/obj/item/treasure/lens_of_truth/proc/listen_for_speech(mob/user, mob/living/target)
	if(!user || !target || QDELETED(src) || QDELETED(user) || QDELETED(target))
		return
		
	var/datum/callback/speech_callback = CALLBACK(src, PROC_REF(capture_speech), user, target)
	RegisterSignal(target, COMSIG_MOB_SAY, speech_callback)
	addtimer(CALLBACK(src, PROC_REF(clear_speech_listener), target, speech_callback), 300) // 30 seconds max wait

// Captures speech when the target speaks
/obj/item/treasure/lens_of_truth/proc/capture_speech(mob/user, mob/living/target, message)
	SIGNAL_HANDLER
	
	if(!user || !target || QDELETED(src) || QDELETED(user) || QDELETED(target))
		return
	
	UnregisterSignal(target, COMSIG_MOB_SAY)
	
	to_chat(user, span_notice("The mirror shimmers, and captures the words: \"[message]\""))
	playsound(get_turf(user), 'sound/foley/glassbreak.ogg', 25, TRUE)
	
	next_use = world.time + cooldown_time
	
	// Visual effect
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(target))
	shimmer.color = "#c0ffff"

// Cleans up the signal registration if no speech was captured
/obj/item/treasure/lens_of_truth/proc/clear_speech_listener(mob/living/target, datum/callback/callback)
	if(!target || QDELETED(src) || QDELETED(target))
		return
		
	UnregisterSignal(target, COMSIG_MOB_SAY)

/obj/effect/temp_visual/lens_shimmer
	name = "lens shimmer"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 5


