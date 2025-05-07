#define TRAIT_ALWAYS_SILENT_STEP "always_silent_step"

/obj/item/treasure/silent_steps
	name = "Ring of Silent Steps"
	desc = "A mysterious ring that absorbs all sound from the wearer's movements. Perfect for those who prefer to remain unheard."
	w_class = WEIGHT_CLASS_TINY
	icon_state = "silentstep"
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

// Global list to track all treasures
GLOBAL_LIST_EMPTY(all_treasures)

/obj/item/treasure
	name = "Treasure"
	desc = "How are you seeing this?"
	w_class = WEIGHT_CLASS_TINY
	icon = 'thiefmanor/icons/treasures.dmi'
	icon_state = "treasure"
	var/difficulty = 0
	var/can_be_objective = TRUE

/obj/item/treasure/Initialize()
	. = ..()
	// Add this treasure to the global list when created
	GLOB.all_treasures += src

/obj/item/treasure/Destroy()
	// Remove this treasure from the global list when destroyed
	GLOB.all_treasures -= src
	return ..()



/obj/item/treasure/marriagecontract
	name = "Forged Marriage Contract"
	desc = "A forged marriage contract that may erupt scandal in the noble realm.."
	icon_state = "marriagecontract"
	difficulty = 1
	drop_sound = 'sound/foley/dropsound/paper_drop.ogg'

/obj/item/treasure/ledger
	name = "Manor Ledger"
	desc = "A ledger that contains the records of the manor. Who knows what blackmail material is hidden within?"
	icon_state = "ledger"
	difficulty = 1
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'

/obj/item/treasure/brooch
	name = "Countess Elira's Brooch"
	desc = "A golden heirloom set with a rare violet gem. Missing for years… or was it just hidden?"
	icon_state = "brooch"
	dropshrink = 0.5
	difficulty = 5
	drop_sound = 'sound/items/gem.ogg'

/obj/item/treasure/wine
	name = "Vintage Wine"
	desc = "A bottle of luxurious wine aged since year 401. It's said to have a unique flavor that can only be found in the finest vintages. Far too valuable to drink."
	icon_state = "wine"
	drop_sound = 'sound/foley/dropsound/glass_drop.ogg'
	difficulty = 1

/obj/item/treasure/gemerald
	name = "Massive Gemerald"
	desc = "An absurdly large green gemstone—gaudy, cut, and almost too heavy to wear—rumored to have been pried from the eye socket of a fallen statue in an ancient ruin. Its true value is debated, but its sheer size makes it irresistible to thieves and impossible to hide discreetly."
	icon_state = "emerald_cut"
	difficulty = 4
	drop_sound = 'sound/items/gem.ogg'

/obj/item/treasure/blackmail
	name = "Perfumed Letters"
	desc = "Delicate, romantic, and politically dangerous if discovered."
	icon_state = "blackmail"
	difficulty = 2
	drop_sound = 'sound/foley/dropsound/paper_drop.ogg'

/obj/item/treasure/bond
	name = "Crown's Bond"
	desc = "A pledged promise from the Crown, promising a small fortune of gold to the bearer."
	icon_state = "bond"
	difficulty = 2
	drop_sound = 'sound/foley/dropsound/paper_drop.ogg'

/obj/item/treasure/kassidy
	name = "Kassidy Doll"
	desc = "A strange plush doll that resembles Kassidy the Red."
	icon_state = "kass"
	difficulty = 10

/obj/item/treasure/morgan
	name = "Morgan Doll"
	desc = "A strange plush doll that resembles Morgan Cross."
	icon_state = "morgan"
	difficulty = 15

/obj/item/treasure/morgan/proc/find_random_indoor_turf()
	var/list/valid_turfs = list()
	for(var/turf/open/floor/T in world)
		if(!T.is_blocked_turf(TRUE)) // Only check if the turf isn't blocked
			var/area/A = get_area(T)
			// Only check if the area is of type /area/rogue/indoors/town
			if(A && istype(A, /area/rogue/indoors/town))
				valid_turfs += T
	
	if(valid_turfs.len)
		return pick(valid_turfs)
	return null

/obj/item/treasure/morgan/Initialize(mapload)
	. = ..()
	
	// If created during gameplay (not from map loading), place it in a random location
	var/turf/T = find_random_indoor_turf()
	if(T)
		forceMove(T)
		message_admins("Morgan doll spawned at [ADMIN_VERBOSEJMP(T)]")
	else
		// Fallback location - try to find a closet in the town area
		var/list/possible_closets = list()
		for(var/obj/structure/closet/C in world)
			// Only consider closets in the town
			var/area/A = get_area(C)
			if(A && istype(A, /area/rogue/indoors/town))
				possible_closets += C
		
		if(length(possible_closets))
			var/obj/structure/closet/C = pick(possible_closets)
			forceMove(C)
			message_admins("Morgan doll spawned in a closet at [ADMIN_VERBOSEJMP(C)]")
		else
			message_admins("ERROR: Failed to place Morgan doll in town area - no valid locations found")
			qdel(src) // Delete the item if we can't find a valid location

/obj/item/treasure/snake
	name = "Emerald Idol of Ithulu"
	desc = "A six-inch tall statue of a forgotten serpent god, carved from raw emerald. Recovered from an expedition to the jungle of the cursed island of Ithulu."
	icon_state = "snake"
	difficulty = 3
	drop_sound = 'sound/items/gem.ogg'

/obj/item/treasure/kassidy/proc/find_random_indoor_turf()
	var/list/valid_turfs = list()
	for(var/turf/open/floor/T in world)
		if(!T.is_blocked_turf(TRUE)) // Only check if the turf isn't blocked
			var/area/A = get_area(T)
			// Only check if the area is of type /area/rogue/indoors/town
			if(A && istype(A, /area/rogue/indoors/town))
				valid_turfs += T
	
	if(valid_turfs.len)
		return pick(valid_turfs)
	return null

/obj/item/treasure/kassidy/Initialize(mapload)
	. = ..()
	
	// If created during gameplay (not from map loading), place it in a random location
	var/turf/T = find_random_indoor_turf()
	if(T)
		forceMove(T)
		message_admins("Kassidy doll spawned at [ADMIN_VERBOSEJMP(T)]")
	else
		// Fallback location - try to find a closet in the town area
		var/list/possible_closets = list()
		for(var/obj/structure/closet/C in world)
			// Only consider closets in the town
			var/area/A = get_area(C)
			if(A && istype(A, /area/rogue/indoors/town))
				possible_closets += C
		
		if(length(possible_closets))
			var/obj/structure/closet/C = pick(possible_closets)
			forceMove(C)
			message_admins("Kassidy doll spawned in a closet at [ADMIN_VERBOSEJMP(C)]")
		else
			message_admins("ERROR: Failed to place Kassidy doll in town area - no valid locations found")
			qdel(src) // Delete the item if we can't find a valid location

/obj/item/treasure/lens_of_truth
	name = "Mirror of Truth"
	desc = "A mysterious mirror that reveals hidden truths. When used on someone, it reveals their hidden past."
	icon_state = "mirror"
	drop_sound = 'sound/foley/dropsound/glass_drop.ogg'
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
	
	// Check for speech logs from the target
	var/message = find_speech_log(L)
	
	if(!message)
		to_chat(user, span_warning("The mirror reveals nothing from [L]'s past words."))
		return
	
	to_chat(user, span_notice("The mirror shimmers, and you hear a whisper: \"[message]\""))
	playsound(get_turf(user), 'sound/foley/glassbreak.ogg', 25, TRUE)
	
	next_use = world.time + cooldown_time
	
	// Visual effect
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(L))
	shimmer.color = "#c0ffff"

// Find speech in logs
/obj/item/treasure/lens_of_truth/proc/find_speech_log(mob/living/L)
	if(!L)
		return null
		
	var/list/say_log_messages = list()
	
	// Check for logs using different possible formats
	var/list/log_keys = list("2", "1") // LOG_SAY is sometimes 2, sometimes 1
	
	// Check mob logs
	if(L.logging)
		for(var/key in log_keys)
			if(L.logging[key])
				for(var/entry in L.logging[key])
					extract_speech(L.logging[key][entry], say_log_messages)
	
	// Check client logs
	if(L.client?.player_details?.logging)
		for(var/key in log_keys)
			if(L.client.player_details.logging[key])
				for(var/entry in L.client.player_details.logging[key])
					extract_speech(L.client.player_details.logging[key][entry], say_log_messages)
	
	if(length(say_log_messages))
		return pick(say_log_messages)
	
	return null

// Extract speech from log entries
/obj/item/treasure/lens_of_truth/proc/extract_speech(log_entry, list/output_list)
	if(!istext(log_entry) || !islist(output_list))
		return
	
	// Try to find quoted text first
	var/quote_start = findtext(log_entry, "\"")
	if(quote_start)
		var/quote_end = findtext(log_entry, "\"", quote_start + 1)
		if(quote_end)
			var/spoken_text = copytext(log_entry, quote_start + 1, quote_end)
			if(spoken_text && length(spoken_text) > 0)
				output_list |= spoken_text
				return
	
	// Try to find text after "says, "
	var/says_pos = findtext(log_entry, "says, ")
	if(says_pos)
		var/message_part = copytext(log_entry, says_pos + 6)
		if(message_part && length(message_part) > 0)
			output_list |= message_part
			return

/obj/effect/temp_visual/lens_shimmer
	name = "lens shimmer"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	duration = 5

/obj/item/treasure/silverstake
	name = "Silver Stake"
	desc = "A blessed silver stake rumored to have been used by the famed Monster Hunter, Lord Dokato."
	possible_item_intents = list(/datum/intent/stab, /datum/intent/pick)
	force = 10
	throwforce = 5
	is_silver = TRUE
	icon_state = "silverstake"
	difficulty = 4
	max_integrity = 200
	resistance_flags = FIRE_PROOF
	experimental_inhand = TRUE
	anvilrepair = /datum/skill/craft/blacksmithing

/obj/item/treasure/silverstake/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = -6,"nx" = 11,"ny" = -6,"wx" = -4,"wy" = -3,"ex" = 2,"ey" = -3,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/clothing/suit/roguetown/armor/plate/kassarmor
	name = "Kassidy's Armor"
	desc = "A suit of armor worn by Kassidy the Red. Red chainmail reinforced with dyed steel plates."
	icon = 'thiefmanor/icons/treasures.dmi'
	icon_state = "rmerc"
	body_parts_covered = CHEST|GROIN|ARMS|LEGS|NECK|VITALS
	armor = list("blunt" = 100, "slash" = 100, "stab" = 100, "fire" = 100, "acid" = 100)
	prevent_crits = list(BCLASS_CUT, BCLASS_STAB, BCLASS_CHOP, BCLASS_BLUNT, BCLASS_TWIST)
	resistance_flags = FIRE_PROOF
	experimental_inhand = TRUE
	anvilrepair = /datum/skill/craft/armorsmithing
	slot_flags = ITEM_SLOT_ARMOR
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/armor.dmi'
	sleeved = 'icons/roguetown/clothing/onmob/helpers/sleeves_armor.dmi'
	sleevetype = "rmerc"
	armor_class = ARMOR_CLASS_HEAVY
	nodismemsleeves = TRUE
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	allowed_race = NON_DWARVEN_RACE_TYPES
	r_sleeve_status = SLEEVE_NORMAL
	l_sleeve_status = SLEEVE_NORMAL

/obj/item/treasure/quiet_blade
	name = "The Quiet Blade"
	desc = "A perfectly balanced dagger of mysterious origin. Its edge is impossibly sharp and never seems to dull. Legend says it never misses its mark."
	icon_state = "quietblade"
	associated_skill = /datum/skill/combat/knives
	w_class = WEIGHT_CLASS_TINY
	force = 20
	throwforce = 15
	difficulty = 7
	resistance_flags = FIRE_PROOF | ACID_PROOF
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_HIP
	possible_item_intents = list(/datum/intent/dagger/ghost_strike)
	experimental_inhand = TRUE

/obj/item/treasure/quiet_blade/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = 0,"nx" = 11,"ny" = 0,"wx" = -4,"wy" = 0,"ex" = 2,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/treasure/quiet_blade/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 30, 100, 0, null, TRUE)

// This item never takes damage
/obj/item/treasure/quiet_blade/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	return 0


/datum/intent/dagger/ghost_strike
	name = "ghost strike"
	icon_state = "instab"
	attack_verb = list("silently pierces", "quietly slices through", "imperceptibly cuts")
	animname = "stab"
	blade_class = BCLASS_STAB
	hitsound = list('sound/combat/hits/bladed/genstab (1).ogg')
	penfactor = 100
	chargetime = 0
	clickcd = 8
	item_d_type = "stab"
	candodge = FALSE
	canparry = FALSE 
	damfactor = 1.5 

/obj/item/treasure/obsidian_comb
	name = "The Obsidian Comb"
	desc = "A sleek black comb with intricate carvings along its spine. It's said to grant irresistible beauty to anyone who uses it, but at a price: once its magic fades, one is left longing for the beauty they briefly possessed."
	icon_state = "comb"
	w_class = WEIGHT_CLASS_TINY
	difficulty = 1
	resistance_flags = FIRE_PROOF
	experimental_inhand = TRUE
	slot_flags = ITEM_SLOT_BELT
	var/cooldown_time = 10 MINUTES
	var/next_use = 0

/obj/item/treasure/obsidian_comb/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || !ishuman(user))
		return
	
	var/mob/living/carbon/human/H = target
	
	if(world.time < next_use)
		to_chat(user, span_warning("The Obsidian Comb's magic hasn't recharged yet. You'll need to wait [round((next_use - world.time)/600, 0.1)] more minutes."))
		return
	
	if(H.has_status_effect(/datum/status_effect/obsidian_beauty))
		to_chat(user, span_notice("[H] is already under the comb's enchantment."))
		return
	
	if(user != target)
		user.visible_message(span_notice("[user] gently runs The Obsidian Comb through [H]'s hair."), 
			span_notice("You gently run the comb through [H]'s hair."))
	else
		user.visible_message(span_notice("[user] runs The Obsidian Comb through [user.p_their()] hair."), 
			span_notice("As you run the comb through your hair, you feel a tingling sensation spreading throughout your body."))
	
	if(!do_after(user, 10, target = H))
		to_chat(user, span_warning("You need to hold the comb steady!"))
		return
	
	// Visual message for successful use
	if(user != target)
		to_chat(user, span_notice("You see [H]'s appearance subtly change, becoming more radiant and attractive."))
		to_chat(H, span_notice("You feel a tingling sensation spreading throughout your body. You feel more beautiful and confident."))
	else
		to_chat(user, span_notice("You feel more beautiful and confident."))
	
	playsound(get_turf(H), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Create visual effect
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(H))
	shimmer.color = "#8c00ff" // Purple shimmer
	
	// Apply status effect which will handle the traits
	H.apply_status_effect(/datum/status_effect/obsidian_beauty)
	
	next_use = world.time + cooldown_time

// Status effect for the Obsidian Comb
/datum/status_effect/obsidian_beauty
	id = "obsidian_beauty"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 10 MINUTES
	alert_type = /atom/movable/screen/alert/status_effect/obsidian_beauty
	var/had_beautiful_trait = FALSE
	var/had_goodlover_trait = FALSE
	var/heart_timer_id

/atom/movable/screen/alert/status_effect/obsidian_beauty
	name = "Magical Beauty"
	desc = "The Obsidian Comb's enchantment makes you irresistibly beautiful."
	icon_state = "buff"

/datum/status_effect/obsidian_beauty/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		
		// Store if the user already had these traits
		had_beautiful_trait = HAS_TRAIT(H, TRAIT_BEAUTIFUL)
		had_goodlover_trait = HAS_TRAIT(H, TRAIT_GOODLOVER)
		
		// Apply the traits
		ADD_TRAIT(H, TRAIT_BEAUTIFUL, "obsidian_comb")
		ADD_TRAIT(H, TRAIT_GOODLOVER, "obsidian_comb")
		
		// Start the heart emission process
		heart_timer_id = addtimer(CALLBACK(src, PROC_REF(emit_heart)), rand(50, 100), TIMER_STOPPABLE)
	
	return TRUE

/datum/status_effect/obsidian_beauty/proc/emit_heart()
	if(!owner || QDELETED(owner))
		return
	
	// Only continue if owner is a human
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		
		// Check if the person is visible (not invisible)
		if(H.alpha <= 10)
			return
		
		// 50% chance to emit a heart on each timer call
		if(prob(50))
			// Create a love heart at the user's location
			var/obj/effect/temp_visual/love_heart/heart = new(get_turf(H))
			// Make it pink
			heart.color = "#ff69b4"
			
			// Position the heart visually above the player but at a lower layer
			heart.pixel_y = 22  // Higher position to appear above the character
			heart.layer = BELOW_MOB_LAYER  // Set layer below mob for proper rendering
			
			// Add a little randomness to the position
			heart.pixel_x = rand(-8, 8)
			
			// Make the heart rise higher
			animate(heart, pixel_y = heart.pixel_y + 32, alpha = 0, time = heart.duration)
	
	// Next heart will be in 5-10 seconds
	var/next_time = rand(50, 100)
	heart_timer_id = addtimer(CALLBACK(src, PROC_REF(emit_heart)), next_time, TIMER_STOPPABLE)

/datum/status_effect/obsidian_beauty/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		
		// Remove the traits if the user didn't already have them
		if(!had_beautiful_trait)
			REMOVE_TRAIT(H, TRAIT_BEAUTIFUL, "obsidian_comb")
		if(!had_goodlover_trait)
			REMOVE_TRAIT(H, TRAIT_GOODLOVER, "obsidian_comb")
		
		// Add the depression stress effect
		H.add_stress(/datum/stressevent/comb_depression)
		
		// Visual effect for end of enchantment
		H.visible_message(span_notice("[H]'s appearance seems to dim slightly."), 
			span_warning("As the comb's magic fades, you feel a profound emptiness. The world seems less vibrant now."))
		
		var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(H))
		shimmer.color = "#505050" // Gray shimmer
		
		playsound(get_turf(H), 'sound/magic/churn.ogg', 30, TRUE) // Sadder sound
		
		// Clean up the heart timer
		if(heart_timer_id)
			deltimer(heart_timer_id)
			heart_timer_id = null
	
	return ..()

// Depression stress effect for when the comb's effect wears off
/datum/stressevent/comb_depression
	stressadd = 5
	desc = span_danger("I miss the beauty I once had... I need to use the comb again.")
	timer = 20 MINUTES // Depression lasts longer than the comb effect

/obj/item/treasure/gossamer_bell
	name = "The Gossamer Bell"
	desc = "A delicate silver bell with intricate engravings of flowing mist. It's said to ring on its own when spirits are near."
	is_silver = TRUE
	icon_state = "bell"
	w_class = WEIGHT_CLASS_TINY
	difficulty = 3
	resistance_flags = FIRE_PROOF
	experimental_inhand = TRUE
	slot_flags = ITEM_SLOT_BELT
	var/next_check = 0
	var/check_interval = 10 SECONDS
	var/detection_range = 5
	var/next_ring = 0
	var/ring_timer_id
	var/last_manual_ring = 0

/obj/item/treasure/gossamer_bell/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/treasure/gossamer_bell/Destroy()
	STOP_PROCESSING(SSobj, src)
	if(ring_timer_id)
		deltimer(ring_timer_id)
		ring_timer_id = null
	return ..()

/obj/item/treasure/gossamer_bell/dropped()
	. = ..()
	update_icon()

/obj/item/treasure/gossamer_bell/equipped()
	. = ..()
	update_icon()

/obj/item/treasure/gossamer_bell/process()
	if(world.time < next_check)
		return
	
	next_check = world.time + check_interval
	
	// Don't check if we're already planning to ring soon
	if(ring_timer_id || world.time < next_ring)
		return
	
	var/turf/T = get_turf(src)
	if(!T)
		return
	
	// Check for ghosts nearby
	var/ghost_nearby = FALSE
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(!G.client) // Only count ghosts with clients
			continue
			
		if(get_dist(G, src) <= detection_range)
			ghost_nearby = TRUE
			break
	
	// If there's a ghost nearby, schedule a ring
	if(ghost_nearby)
		// Schedule the bell to ring in 10-20 seconds
		var/ring_delay = rand(10 SECONDS, 20 SECONDS)
		ring_timer_id = addtimer(CALLBACK(src, PROC_REF(ring_bell), T), ring_delay, TIMER_STOPPABLE)

/obj/item/treasure/gossamer_bell/proc/ring_bell(turf/source_turf)
	ring_timer_id = null
	
	if(!source_turf)
		source_turf = get_turf(src)
		
	if(!source_turf)
		return
	
	// Play the sound effect
	playsound(source_turf, 'sound/misc/bell.ogg', 40, TRUE, -1)
	
	// Visual feedback for those who can see the bell
	var/list/viewers = viewers(7, source_turf)
	for(var/mob/M in viewers)
		to_chat(M, span_notice("[src] rings softly by itself..."))
	
	// Set the next time we can ring
	next_ring = world.time + rand(10 SECONDS, 20 SECONDS)

/obj/item/treasure/gossamer_bell/attack_self(mob/user)
	if(world.time < last_manual_ring + 3 SECONDS)
		return FALSE
		
	last_manual_ring = world.time
	
	playsound(src, 'sound/misc/bell.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] rings [src]."), span_notice("You ring [src]. It makes a clear, sweet sound."))
	return TRUE

/obj/item/treasure/marvelous_compass
	name = "Marvelous Compass"
	desc = "An ornate brass compass with intricate engravings. Instead of cardinal directions, it has symbols of precious items around its face. The needle seems to point toward valuable treasures."
	icon_state = "compass"
	difficulty = 4
	resistance_flags = FIRE_PROOF
	var/next_scan = 0
	var/scan_interval = 5 SECONDS
	var/passive_scan_interval = 10 SECONDS // Slower interval for passive scanning
	var/active = FALSE
	var/atom/target_treasure = null
	var/max_scan_range = 100 // Maximum range to consider treasures, in tiles
	var/last_pos_x = 0 // For caching position
	var/last_pos_y = 0
	var/last_pos_z = 0
	var/toggle_cooldown = 0
	var/toggle_cooldown_time = 10 SECONDS

/obj/item/treasure/marvelous_compass/Initialize()
	. = ..()
	update_icon()
	last_pos_x = 0 
	last_pos_y = 0
	last_pos_z = 0

/obj/item/treasure/marvelous_compass/update_icon()
	. = ..()
	cut_overlays()
	if(active)
		var/image/overlay = image(icon, src, "compassneedle")
		if(target_treasure)
			var/direction = get_dir(get_turf(src), get_turf(target_treasure))
			// Convert direction to degrees for the compass needle
			var/angle = dir2angle(direction)
			var/matrix/M = matrix()
			M.Turn(angle)
			overlay.transform = M
		else
			// Spin randomly if no target
			var/matrix/M = matrix()
			M.Turn(rand(0, 360))
			overlay.transform = M
		add_overlay(overlay)

/obj/item/treasure/marvelous_compass/attack_self(mob/user)
	// Check cooldown
	if(world.time < toggle_cooldown)
		to_chat(user, span_warning("The compass mechanics are still settling. You'll need to wait [round((toggle_cooldown - world.time)/10)] more seconds."))
		return FALSE
		
	active = !active
	if(active)
		to_chat(user, span_notice("You activate [src]. The needle starts moving..."))
		START_PROCESSING(SSobj, src)
		// Immediate scan and update position cache
		var/turf/T = get_turf(src)
		if(T)
			last_pos_x = T.x
			last_pos_y = T.y
			last_pos_z = T.z
		scan_for_treasure(user, TRUE) // Force scan on activation
	else
		to_chat(user, span_notice("You deactivate [src]. The needle stops moving."))
		STOP_PROCESSING(SSobj, src)
		target_treasure = null
	
	// Set cooldown
	toggle_cooldown = world.time + toggle_cooldown_time
	
	update_icon()
	return TRUE

/obj/item/treasure/marvelous_compass/process()
	if(!active || world.time < next_scan)
		return
	
	// Determine if we're being held or not
	var/being_held = ismob(loc)
	
	// Set next scan time based on whether being held (more frequent) or not
	next_scan = world.time + (being_held ? scan_interval : passive_scan_interval)
	
	// Check if we've moved significantly before performing a new scan
	var/turf/T = get_turf(src)
	if(!T)
		return
		
	// Only scan if our position has changed or we don't have a target
	var/position_changed = (T.x != last_pos_x || T.y != last_pos_y || T.z != last_pos_z)
	if(position_changed || !target_treasure)
		// Update position cache
		last_pos_x = T.x
		last_pos_y = T.y
		last_pos_z = T.z
		
		// Only do visuals for held compass
		if(being_held)
			var/mob/M = loc
			scan_for_treasure(M, FALSE)
		else
			scan_for_treasure(null, FALSE)

/obj/item/treasure/marvelous_compass/proc/scan_for_treasure(mob/user, force_visuals = FALSE)
	var/list/possible_treasures = list()
	var/list/objective_treasures = list()
	var/turf/our_turf = get_turf(src)
	
	if(!our_turf)
		return
	
	// Filter treasures by distance first
	for(var/obj/item/treasure/T in GLOB.all_treasures)
		if(T == src) // Don't point to ourselves
			continue
		
		// Ignore treasures that can't be objectives
		if(!T.can_be_objective)
			continue
			
		// Ignore treasures carried by the user
		if(user && (T.loc == user || recursive_loc_check(T, user)))
			continue
			
		var/turf/T_turf = get_turf(T)
		if(!T_turf)
			continue
			
		// Check if the treasure is in range
		if(get_dist_euclidian(our_turf, T_turf) <= max_scan_range)
			possible_treasures += T
	
	// If we have a user with a thief antagonist, check for objective items
	if(user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.mind && H.mind.has_antag_datum(/datum/antagonist/thief))
			var/datum/antagonist/thief/thief_antag = H.mind.has_antag_datum(/datum/antagonist/thief)
			
			// Pre-filter the thief's objectives to avoid nested loops
			var/list/target_types = list()
			for(var/datum/objective/steal/O in thief_antag.objectives)
				if(istype(O) && O.steal_target)
					target_types += O.steal_target
			
			// Now check each possible treasure against the filtered objectives
			for(var/obj/item/treasure/T in possible_treasures)
				for(var/obj_type in target_types)
					if(istype(T, obj_type))
						objective_treasures += T
						break
	
	// Determine target based on what we found
	var/old_target = target_treasure // Store old target to check if it changed
	
	if(length(objective_treasures) > 0)
		// Randomly pick one of the objective treasures
		target_treasure = pick(objective_treasures)
		if(user && (force_visuals || old_target != target_treasure))
			to_chat(user, span_notice("The compass needle spins rapidly before settling on a direction. The ornate symbol of [get_treasure_symbol(target_treasure)] glows faintly. It seems to be pointing toward something you seek."))
	else if(length(possible_treasures) > 0)
		// Find the closest treasure
		var/obj/item/treasure/closest = null
		var/closest_dist = INFINITY
		
		for(var/obj/item/treasure/T in possible_treasures)
			var/turf/T_turf = get_turf(T)
			if(!T_turf)
				continue
				
			var/dist = get_dist_euclidian(our_turf, T_turf)
			if(dist < closest_dist)
				closest_dist = dist
				closest = T
		
		target_treasure = closest
		if(user && (force_visuals || old_target != target_treasure))
			to_chat(user, span_notice("The compass needle points toward the nearest treasure. The symbol of [get_treasure_symbol(target_treasure)] on the compass face shimmers."))
	else
		// No treasures found
		target_treasure = null
		if(user && (force_visuals || old_target != null))
			to_chat(user, span_warning("The compass needle spins aimlessly, unable to detect any treasures. All symbols on the face remain dim."))
	
	// Create a direction arrow and tell the user which direction only if target changed or forced
	if(target_treasure && user && (force_visuals || old_target != target_treasure))
		show_direction_to_user(user)
	
	update_icon()

/obj/item/treasure/marvelous_compass/proc/get_dist_euclidian(turf/T1, turf/T2)
	if(!T1 || !T2 || T1.z != T2.z)
		return INFINITY
	return sqrt((T2.x - T1.x) * (T2.x - T1.x) + (T2.y - T1.y) * (T2.y - T1.y))

/obj/item/treasure/marvelous_compass/proc/show_direction_to_user(mob/user)
	if(!target_treasure || !user)
		return
		
	var/turf/T = get_turf(src)
	var/turf/target_turf = get_turf(target_treasure)
	
	if(!T || !target_turf)
		return
		
	// Get the direction to the target
	var/direction = get_dir(T, target_turf)
	
	// Tell the user which direction in chat
	var/dir_text = dir2text(direction)
	var/dist = get_dist(T, target_turf)
	
	// Check if the target is on a different z-level
	var/vertical_direction = ""
	if(T.z > target_turf.z)
		vertical_direction = "below you"
	else if(T.z < target_turf.z)
		vertical_direction = "above you"
	
	// Customize the message based on whether the target is on the same z-level or not
	if(vertical_direction != "")
		to_chat(user, span_notice("The compass needle quivers and points <b>[dir_text]</b> and <b>[vertical_direction]</b>. The [get_treasure_symbol(target_treasure)] symbol glows. The treasure is ([dist] steps away) on another level."))
	else
		to_chat(user, span_notice("The treasure is <b>[dir_text]</b> from here ([dist] steps away). The [get_treasure_symbol(target_treasure)] symbol pulses with a soft light."))
	
	// Create a visible arrow icon for the user
	var/obj/effect/temp_visual/dir_setting/compass_arrow/arrow
	
	// Always point in the cardinal direction, but set z-direction if needed
	arrow = new(T, direction)
	
	// If on different z-level, add an indicator for that too
	if(vertical_direction == "above you")
		arrow.z_direction = "up"
	else if(vertical_direction == "below you")
		arrow.z_direction = "down"
	
	// Make the arrow only visible to the user
	var/image/I = image(arrow)
	I.override = TRUE
	
	// Only show it to the user
	user.client?.images += I
	
	// Add a second arrow for z-level if needed
	if(vertical_direction != "")
		var/obj/effect/temp_visual/dir_setting/compass_arrow/z_arrow
		
		if(vertical_direction == "above you")
			z_arrow = new(T, NORTH)
			z_arrow.z_level_indicator = TRUE
			z_arrow.pixel_x = 16 // Offset to the right
		else
			z_arrow = new(T, SOUTH)
			z_arrow.z_level_indicator = TRUE
			z_arrow.pixel_x = 16 // Offset to the right
		
		// Make the z-arrow only visible to the user
		var/image/I2 = image(z_arrow)
		I2.override = TRUE
		
		// Only show it to the user
		user.client?.images += I2
		
		// Remove the image after a short delay
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_client), I2, user.client), 3 SECONDS)
	
	// Remove the image after a short delay
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_client), I, user.client), 3 SECONDS)

/obj/effect/temp_visual/dir_setting/compass_arrow
	name = "compass arrow"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrowcompass"
	duration = 3 SECONDS
	color = "#FFD700" // Gold color
	layer = ABOVE_MOB_LAYER
	pixel_y = 16 // Position it above the player's head (reduced from 32)
	var/z_direction = null // Indicates if the arrow points up or down
	var/z_level_indicator = FALSE // Is this arrow showing z-level difference?

/obj/effect/temp_visual/dir_setting/compass_arrow/Initialize(mapload, set_dir)
	. = ..()
	
	// Store original transform to apply with any animation later
	var/matrix/original_transform = transform
	
	// Handle all directions by using transform matrix rotation
	// BYOND sprites typically only come in 4 directions, but we can rotate to get all 8
	var/angle_offset = 0
	
	switch(dir)
		// Cardinal directions
		if(NORTH)
			angle_offset = 0   // No rotation needed
		if(EAST)
			angle_offset = 90  // Rotate 90 degrees clockwise from north
		if(SOUTH) 
			angle_offset = 180 // Rotate 180 degrees from north
		if(WEST)
			angle_offset = 270 // Rotate 270 degrees clockwise from north (or 90 counterclockwise)
		
		// Diagonal directions
		if(NORTHEAST)
			angle_offset = 45  // Between north and east
		if(SOUTHEAST)
			angle_offset = 135 // Between east and south
		if(SOUTHWEST)
			angle_offset = 225 // Between south and west
		if(NORTHWEST)
			angle_offset = 315 // Between west and north
	
	// Always use the NORTH-facing sprite as base and rotate it
	dir = NORTH
	
	// Apply rotation transform
	var/matrix/M = matrix()
	M.Turn(angle_offset)
	transform = M
	
	// Different animation for z-level indicators
	if(z_level_indicator)
		// Smaller for secondary indicator
		transform = transform.Scale(0.7)
		// Different color for z-level
		color = "#36C5F0" // Light blue 
		
		// Pulsing animation for z-level
		animate(src, alpha = 150, time = 10, loop = 3)
		animate(alpha = 255, time = 10)
	else
		// Regular animation for main direction
		animate(src, pixel_y = pixel_y + 4, time = 5, loop = 6, flags = ANIMATION_RELATIVE)
		animate(pixel_y = pixel_y - 4, time = 5)
	
	// Handle different directions for z-levels - only apply if this is a z-level indicator
	if(z_level_indicator)
		if(z_direction == "up")
			// Reset transform and use up direction
			transform = original_transform
			
			// Scale down if needed
			if(z_level_indicator)
				transform = transform.Scale(0.7)
				
			// No rotation - up is the default
		else if(z_direction == "down")
			// Reset transform and use down direction (180 degrees rotation)
			transform = original_transform
			
			// Scale down if needed
			if(z_level_indicator) 
				transform = transform.Scale(0.7)
				
			// Rotate to point down
			var/matrix/M2 = transform
			M2.Turn(180)
			transform = M2

// Global proc to remove images from clients after delay
/proc/remove_image_from_client(image/I, client/C)
	if(I && C)
		C.images -= I

/obj/item/treasure/marvelous_compass/Destroy()
	STOP_PROCESSING(SSobj, src)
	target_treasure = null
	return ..()
	
/obj/item/treasure/marvelous_compass/dropped()
	. = ..()
	update_icon()
	
/obj/item/treasure/marvelous_compass/equipped()
	. = ..()
	update_icon()

/obj/item/treasure/pathmakers_parchment
	name = "Pathmaker's Parchment"
	desc = "An ancient, crackling parchment with a map that seems to shift and change as you look at it. Strange symbols glow along its weathered edges."
	icon_state = "map"
	drop_sound = 'sound/foley/dropsound/paper_drop.ogg'
	difficulty = 4
	resistance_flags = FIRE_PROOF
	var/treasures_collected = 0
	var/target_max = 5
	var/next_use = 0
	var/use_cooldown = 10 SECONDS
	var/obj/item/treasure/current_target = null
	var/list/collected_treasures = list()
	var/max_scan_range = 100 // Maximum range to consider treasures, in tiles

/obj/item/treasure/pathmakers_parchment/Initialize()
	. = ..()
	find_new_target()

/obj/item/treasure/pathmakers_parchment/examine(mob/user)
	. = ..()
	if(treasures_collected < target_max)
		. += span_notice("The parchment shows [treasures_collected]/[target_max] treasures collected.")
	else
		. += span_warning("The parchment's magic has been exhausted.")
		
	if(world.time < next_use)
		var/time_left = round((next_use - world.time)/10)
		. += span_warning("The ink seems to be settling. It will be usable again in [time_left] seconds.")

/obj/item/treasure/pathmakers_parchment/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/treasure))
		var/obj/item/treasure/T = I
		
		// Check if this is our current target
		if(T == current_target)
			// Success! Treasure found
			to_chat(user, span_notice("You place [T] on the parchment. The map glows brightly as it recognizes the treasure!"))
			playsound(get_turf(src), 'sound/magic/swap.ogg', 50, TRUE)
			
			// Create visual effects
			var/turf/turf_loc = get_turf(src)
			var/number_of_sparkles = 5
			for(var/i in 1 to number_of_sparkles)
				var/obj/effect/temp_visual/parchment_reveal/spark = new(turf_loc)
				spark.pixel_x = rand(-16, 16)
				spark.pixel_y = rand(-16, 16)
				spark.color = pick("#ffd700", "#c0c0c0", "#b87333") // Gold, silver, bronze colors
			
			// Add to our collection
			treasures_collected++
			collected_treasures += T.type
			
			// Check if we're done
			if(treasures_collected >= target_max)
				to_chat(user, span_warning("The parchment begins to tremble with power as the final treasure completes its collection!"))
				transform_to_key(user)
				return
			
			// Find a new target
			find_new_target()
			to_chat(user, span_notice("The parchment's map shifts and changes, now pointing to a different treasure."))
			return TRUE
		else
			to_chat(user, span_warning("You place [T] on the parchment, but it doesn't react. This isn't the treasure it's seeking."))
			return FALSE
	
	return ..()

/obj/item/treasure/pathmakers_parchment/proc/find_new_target()
	var/list/potential_treasures = list()
	
	for(var/obj/item/treasure/T in GLOB.all_treasures)
		// Don't target ourselves
		if(T == src)
			continue
			
		// Don't target treasures that can't be objectives
		if(!T.can_be_objective)
			continue
			
		// Don't select treasures we've already collected
		if(T.type in collected_treasures)
			continue
			
		var/turf/T_turf = get_turf(T)
		if(!T_turf)
			continue
			
		// Don't select treasures that are being held by mobs
		if(ismob(T.loc))
			continue
			
		// Add to potential targets
		potential_treasures += T
	
	// If we have potential targets, select one randomly
	if(length(potential_treasures) > 0)
		current_target = pick(potential_treasures)
	else
		// If no targets available, set to null
		current_target = null

/obj/item/treasure/pathmakers_parchment/attack_self(mob/user)
	if(treasures_collected >= target_max)
		to_chat(user, span_warning("The parchment's magic has been exhausted. It's just an old piece of paper now."))
		return
		
	if(world.time < next_use)
		var/time_left = round((next_use - world.time)/10)
		to_chat(user, span_warning("The ink on the parchment is still settling. You'll need to wait [time_left] more seconds before using it again."))
		return
	
	if(!current_target)
		to_chat(user, span_warning("The parchment's surface ripples, but no treasures are revealed. Perhaps there are none nearby."))
		// Find a new target anyway, in case something became available
		find_new_target()
		next_use = world.time + use_cooldown
		return
	
	// Show the user the location of the current target
	show_treasure_location(user)
	
	// Set cooldown
	next_use = world.time + use_cooldown
	

	playsound(get_turf(src), 'sound/magic/churn.ogg', 50, TRUE)
	
	// Visual effects
	var/turf/T = get_turf(src)
	var/number_of_sparkles = 3
	for(var/i in 1 to number_of_sparkles)
		var/obj/effect/temp_visual/parchment_reveal/spark = new(T)
		spark.pixel_x = rand(-16, 16)
		spark.pixel_y = rand(-16, 16)
		spark.color = pick("#ffd700", "#c0c0c0", "#b87333") // Gold, silver, bronze colors

/obj/item/treasure/pathmakers_parchment/proc/show_treasure_location(mob/user)
	if(!current_target || !user)
		return
		
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(current_target)
	
	if(!user_turf || !target_turf)
		return
		
	// Get the direction to the target
	var/direction = get_dir(user_turf, target_turf)
	
	// Create a description of the location
	var/location_desc = get_location_description(user, current_target)
	
	// Tell the user the details
	to_chat(user, span_notice("The parchment trembles in your hands as arcane energies ripple across its surface."))
	to_chat(user, span_notice("You see a symbol of a [get_treasure_symbol(current_target)] on the map. [location_desc]"))
	
	// Direction hint
	var/dir_text = dir2text(direction)
	var/dist = get_dist(user_turf, target_turf)
	
	// Simple z-level hint
	var/level_hint = ""
	if(user_turf.z < target_turf.z)
		level_hint = " above you"
	else if(user_turf.z > target_turf.z)
		level_hint = " below you"
		
	to_chat(user, span_notice("You sense the treasure lies <b>[dir_text]</b> from here ([dist] paces away)[level_hint]."))
	
	// Create a temporary visual arrow that's only visible to the user who activated the map
	var/obj/effect/temp_visual/dir_setting/parchment_indicator/arrow = new(user_turf, direction)
	
	// Make the arrow only visible to the user who activated the map
	// We don't use VIS_HIDE_ALL since it might not be defined, instead we use images
	
	// Create an image of the arrow that only the user can see
	var/image/I = image(arrow)
	I.override = TRUE
	user.client?.images += I
	
	// Remove the image from the user's client after the effect duration
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_client), I, user.client), arrow.duration)
	
	// Z-level indicator if needed
	if(user_turf.z != target_turf.z)
		var/z_dir = (user_turf.z < target_turf.z) ? "up" : "down"
		var/obj/effect/temp_visual/dir_setting/parchment_indicator/z_arrow = new(user_turf, NORTH)
		
		// Different color for z-level indicator
		z_arrow.color = "#36C5F0" // Light blue
		
		// Create unique transform for z direction
		var/matrix/Z = matrix()
		if(z_dir == "down")
			Z.Turn(180) // Point downward
		z_arrow.transform = Z.Scale(0.7) // Slightly smaller
		
		// Offset slightly so both arrows are visible
		z_arrow.pixel_x = 16
		
		// Create an image only the user can see
		var/image/Z_image = image(z_arrow)
		Z_image.override = TRUE
		user.client?.images += Z_image
		
		// Remove the image from the user's client after the effect duration
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(remove_image_from_client), Z_image, user.client), z_arrow.duration)

/obj/item/treasure/pathmakers_parchment/proc/get_location_description(mob/user, obj/item/treasure/target)
	if(!user || !target)
		return "The parchment reveals a mysterious location, but it's too vague to determine."
		
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return "The parchment's image fades before you can make out where it points."
	
	// Get area information
	var/area/target_area = get_area(target_turf)
	var/area_name = "an unknown location"
	if(target_area)
		area_name = target_area.name
	
	// Get floor/level information
	var/turf/user_turf = get_turf(user)
	var/level_desc = ""
	if(user_turf)
		if(user_turf.z == target_turf.z)
			level_desc = "on this floor"
		else if(user_turf.z < target_turf.z)
			var/levels_up = target_turf.z - user_turf.z
			level_desc = levels_up == 1 ? "one floor above you" : "[levels_up] floors above you"
		else
			var/levels_down = user_turf.z - target_turf.z
			level_desc = levels_down == 1 ? "one floor below you" : "[levels_down] floors below you"
	else
		level_desc = "on floor [target_turf.z]"
	
	// Determine room type or specific location
	var/room_desc = get_room_description(target_area, target_turf)
	
	// Build the full description
	var/treasure_symbol = get_treasure_symbol(target)
	var/treasure_hint = get_treasure_type_hint(target)
	
	var/full_desc = "The parchment reveals a [treasure_symbol] located in [area_name], [level_desc]."
	
	if(room_desc)
		full_desc += " It appears to be in [room_desc]."
	
	if(treasure_hint)
		full_desc += " [treasure_hint]."
	
	return full_desc

/obj/item/treasure/pathmakers_parchment/proc/get_room_description(area/target_area, turf/target_turf)
	if(!target_area || !target_turf)
		return null
		
	// Check for specific room features nearby
	var/list/nearby_objects = list()
	for(var/obj/structure/S in range(2, target_turf))
		if(istype(S, /obj/structure/bed))
			nearby_objects += "a bedroom"
		else if(istype(S, /obj/structure/table))
			nearby_objects += "a room with tables"
		else if(istype(S, /obj/structure/bookcase))
			nearby_objects += "a library or study"
		else if(istype(S, /obj/structure/closet))
			nearby_objects += "a room with storage"
		else if(istype(S, /obj/structure/chair))
			nearby_objects += "a sitting area"
		// Use string matching instead of direct type checking for types that may not exist
		else if(findtext("[S]", "fireplace"))
			nearby_objects += "a room with a fireplace"
		else if(findtext("[S]", "window"))
			nearby_objects += "a room with windows to the outside"
	
	// If we found distinctive features
	if(length(nearby_objects) > 0)
		return pick(nearby_objects)
	
	// Fallback based on area type
	var/area_type = target_area.type
	if(findtext("[area_type]", "kitchen"))
		return "a kitchen area"
	else if(findtext("[area_type]", "garden"))
		return "a garden"
	else if(findtext("[area_type]", "bed"))
		return "a bedroom"
	else if(findtext("[area_type]", "bath"))
		return "a bathroom"
	else if(findtext("[area_type]", "hall"))
		return "a hallway"
	else if(findtext("[area_type]", "stairs"))
		return "a stairwell"
	else if(findtext("[area_type]", "storage"))
		return "a storage area"
	else if(findtext("[area_type]", "library"))
		return "a library"
	
	// Generic fallback
	return "some kind of room"

/obj/item/treasure/pathmakers_parchment/proc/get_treasure_type_hint(obj/item/treasure/T)
	if(!T)
		return null
		
	// Return a hint about what type of treasure it is
	if(istype(T, /obj/item/treasure/brooch) || istype(T, /obj/item/treasure/gemerald))
		return "A shimmer of wealth catches your eye"
		
	else if(istype(T, /obj/item/treasure/marriagecontract) || istype(T, /obj/item/treasure/ledger) || istype(T, /obj/item/treasure/blackmail) || istype(T, /obj/item/treasure/bond))
		return "The parchment shows written documents of importance"
		
	else if(istype(T, /obj/item/treasure/kassidy) || istype(T, /obj/item/treasure/morgan))
		return "A curious figurine awaits discovery"
		
	else if(istype(T, /obj/item/treasure/wine))
		return "Something aged and valuable is hidden there"
		
	else if(istype(T, /obj/item/treasure/lens_of_truth) || istype(T, /obj/item/treasure/obsidian_comb) || istype(T, /obj/item/treasure/gossamer_bell) || istype(T, /obj/item/treasure/marvelous_compass))
		return "A magical tool of strange power calls to you"
		
	else if(istype(T, /obj/item/treasure/silverstake) || istype(T, /obj/item/treasure/quiet_blade))
		return "A weapon of unique craftsmanship awaits"
		
	else if(istype(T, /obj/item/treasure/silent_steps))
		return "Something to aid in stealth lies in wait"
	
	else if(istype(T, /obj/item/treasure/witch_doll))
		return "An uncanny figurine that sees into souls"
	
	return "The treasure's nature remains mysterious"

/obj/item/treasure/pathmakers_parchment/proc/transform_to_key(mob/user)
	// Dramatic transformation
	visible_message(span_warning("[src] trembles and shines with golden light, its form twisting and reshaping!"))
	
	if(user)
		to_chat(user, span_notice("The parchment's magic has been fully utilized, revealing its true purpose - a key to hidden secrets within the manor!"))
	
	// Visual effects - use known existing sound from our search
	playsound(get_turf(src), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Create visual effects for the transformation
	var/turf/T = get_turf(src)
	var/number_of_sparkles = 5
	for(var/i in 1 to number_of_sparkles)
		var/obj/effect/temp_visual/parchment_reveal/spark = new(T)
		spark.pixel_x = rand(-16, 16)
		spark.pixel_y = rand(-16, 16)
		spark.color = pick("#ffd700", "#c0c0c0", "#b87333") // Gold, silver, bronze colors
	
	// Create the key
	var/obj/item/treasure/key/K = new(T)
	
	// Transfer any important properties
	K.name = "Ornate Manor Key"
	K.desc = "An ancient, intricate key formed from the magic of the Pathmaker's Parchment. It radiates with power and purpose, clearly meant to unlock a hidden place within the manor."
	
	// Delete the parchment
	qdel(src)

// Visual effect for parchment activation
/obj/effect/temp_visual/parchment_reveal
	name = "arcane energy"
	icon = 'icons/effects/effects.dmi'
	icon_state = "quantum_sparks"
	duration = 10

/obj/item/treasure/pathmakers_parchment/proc/recursive_loc_check(obj/item/target, mob/user)
	if(!target || !user)
		return FALSE
		
	var/atom/current_loc = target.loc
	
	// Check up to 5 levels deep to avoid infinite recursion
	for(var/i in 1 to 5)
		if(!current_loc)
			return FALSE
			
		if(current_loc == user)
			return TRUE
			
		// Check if we're inside a storage item
		if(istype(current_loc, /obj/item/storage))
			current_loc = current_loc.loc
		else
			// Not in a storage item and not on user
			return FALSE
	
	return FALSE

// Global proc for get_treasure_symbol that all types can use
/proc/get_treasure_symbol(obj/item/treasure/T)
	if(!T)
		return "mysterious item"
		
	// Return a thematic symbol based on treasure type
	if(istype(T, /obj/item/treasure/brooch))
		return "glittering gemstone"
	else if(istype(T, /obj/item/treasure/marriagecontract))
		return "sealed document"
	else if(istype(T, /obj/item/treasure/ledger))
		return "ominous book"
	else if(istype(T, /obj/item/treasure/wine))
		return "ornate bottle"
	else if(istype(T, /obj/item/treasure/gemerald))
		return "emerald stone"
	else if(istype(T, /obj/item/treasure/blackmail))
		return "sealed envelope"
	else if(istype(T, /obj/item/treasure/bond))
		return "royal certificate"
	else if(istype(T, /obj/item/treasure/kassidy))
		return "mysterious figure"
	else if(istype(T, /obj/item/treasure/morgan))
		return "beloved figure"
	else if(istype(T, /obj/item/treasure/snake))
		return "coiled serpent"
	else if(istype(T, /obj/item/treasure/lens_of_truth))
		return "reflective surface"
	else if(istype(T, /obj/item/treasure/silverstake))
		return "silver weapon"
	else if(istype(T, /obj/item/treasure/quiet_blade))
		return "curved dagger"
	else if(istype(T, /obj/item/treasure/obsidian_comb))
		return "dark comb"
	else if(istype(T, /obj/item/treasure/gossamer_bell))
		return "small bell"
	else if(istype(T, /obj/item/treasure/silent_steps))
		return "circular band"
	else if(istype(T, /obj/item/treasure/pathmakers_parchment))
		return "magical map"
	else if(istype(T, /obj/item/treasure/key))
		return "ornate key"
	
	// Generic fallback based on name
	var/name_parts = splittext(T.name, " ")
	if(length(name_parts) > 0)
		return "mysterious [lowertext(name_parts[length(name_parts)])]"
	
	return "mysterious object"

/obj/item/treasure/key
	name = "Ornate Manor Key"
	desc = "An ancient, intricate key that seems to radiate with hidden power. It bears the insignia of the manor's original founder."
	icon_state = "ornatekey"
	w_class = WEIGHT_CLASS_TINY
	difficulty = 8
	resistance_flags = FIRE_PROOF | ACID_PROOF
	experimental_inhand = TRUE
	can_be_objective = FALSE

/obj/item/treasure/key/getonmobprop(tag)
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.4,"sx" = -10,"sy" = 0,"nx" = 11,"ny" = 0,"wx" = -4,"wy" = 0,"ex" = 2,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)

/obj/item/treasure/witch_doll
	name = "Witch Doll"
	desc = "Sewn by a forgotten highlands witch as a ward against betrayal, this doll was meant to protect a child from liars and spirits. Instead, it learned to listen... and remember. Passed down in secret, it now resides in the manor—quietly watching."
	icon_state = "azusa"
	w_class = WEIGHT_CLASS_TINY
	difficulty = 3
	resistance_flags = FIRE_PROOF
	var/last_use = 0
	var/cooldown_time = 10 SECONDS

/obj/item/treasure/witch_doll/attack_self(mob/user)
	if(world.time < last_use + cooldown_time)
		to_chat(user, span_warning("The doll's eyes seem dull. It needs time to regain its power."))
		return
		
	last_use = world.time
	
	to_chat(user, span_notice("You squeeze the doll and feel a subtle chill..."))
	
	// Find nearby people
	var/found_anyone = FALSE
	for(var/mob/living/carbon/human/H in view(7, user))
		if(H == user)
			continue
			
		found_anyone = TRUE
		
		// Get stress level
		var/stress_amount = H.get_stress_amount()
		var/stress_desc = get_stress_description(stress_amount)
		
		// Get intent information
		var/intent_name = "unknown"
		if(H.used_intent)
			intent_name = H.used_intent.name
		
		// Display information to the user - only the user can see this
		to_chat(user, "<span class='notice' style='color:#9932CC'><b>[H]</b> - Stress: [stress_desc], Intent: [intent_name]</span>")
	
	if(!found_anyone)
		to_chat(user, "<span class='notice' style='color:#9932CC'>The doll whispers to your mind: no one is nearby.</span>")
	
	return TRUE

/obj/item/treasure/witch_doll/proc/get_stress_description(stress_amount)
	switch(stress_amount)
		if(0)
			return span_green("perfectly calm")
		if(1 to 2)
			return span_green("relaxed")
		if(3 to 5)
			return span_info("neutral")
		if(6 to 10)
			return span_warning("anxious")
		if(11 to 20)
			return span_red("stressed")
		if(21 to INFINITY)
			return span_boldred("panicking")
	return "unknown"

/obj/effect/temp_visual/dir_setting/parchment_indicator
	name = "magical indicator"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrowcompass" 
	duration = 3 SECONDS
	color = "#8A2BE2" // Purple color
	layer = ABOVE_MOB_LAYER
	pixel_y = 16

/obj/effect/temp_visual/dir_setting/parchment_indicator/Initialize(mapload, set_dir)
	. = ..()
	
	// Handle all directions by using transform matrix rotation
	var/angle_offset = 0
	
	switch(dir)
		// Cardinal directions
		if(NORTH)
			angle_offset = 0   
		if(EAST)
			angle_offset = 90  
		if(SOUTH) 
			angle_offset = 180 
		if(WEST)
			angle_offset = 270 
		
		// Diagonal directions
		if(NORTHEAST)
			angle_offset = 45  
		if(SOUTHEAST)
			angle_offset = 135 
		if(SOUTHWEST)
			angle_offset = 225 
		if(NORTHWEST)
			angle_offset = 315 
	
	// Apply rotation transform
	var/matrix/M = matrix()
	M.Turn(angle_offset)
	transform = M
	
	// Animation
	animate(src, pixel_y = pixel_y + 4, time = 5, loop = 6, flags = ANIMATION_RELATIVE)
	animate(pixel_y = pixel_y - 4, time = 5)

/obj/item/clothing/neck/antimagic_collar
	name = "Antimagic Collar"
	desc = "A heavy collar made of special alloy that disrupts magical energies. It has a small keyhole and appears to be locked."
	icon = 'icons/roguetown/clothing/neck.dmi'
	icon_state = "cursed_collar"
	item_state = "cursed_collar"
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/neck.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/locked = 1
	
/obj/item/clothing/neck/antimagic_collar/examine(mob/user)
	. = ..()
	if(locked)
		. += span_warning("The collar is locked and requires a specific key to unlock.")
	else
		. += span_notice("The collar is unlocked and can be removed.")

// Helper proc to handle locking/unlocking of the collar
/obj/item/clothing/neck/antimagic_collar/proc/toggle_lock(mob/user, obj/item/key_item)
	if(!ismob(loc))
		to_chat(user, span_warning("The collar must be worn to be locked or unlocked."))
		return FALSE
		
	var/mob/M = loc
	if(M.get_item_by_slot(SLOT_NECK) != src)
		to_chat(user, span_warning("The collar must be worn around the neck to be locked or unlocked."))
		return FALSE
		
	if(locked)
		locked = 0
		playsound(src, 'sound/misc/click.ogg', 25, TRUE)
		to_chat(user, span_notice("You unlock [src] with [key_item]."))
		REMOVE_TRAIT(src, TRAIT_NODROP, "antimagic_lock")
		to_chat(M, span_notice("The collar can now be removed."))
		return TRUE
	else
		locked = 1
		playsound(src, 'sound/misc/click.ogg', 25, TRUE)
		to_chat(user, span_notice("You lock [src] with [key_item]."))
		ADD_TRAIT(src, TRAIT_NODROP, "antimagic_lock")
		to_chat(M, span_warning("The collar locks around your neck."))
		return TRUE

/obj/item/clothing/neck/antimagic_collar/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/roguekey/garrison) || istype(W, /obj/item/roguekey/lord))
		return toggle_lock(user, W)
	else if(istype(W, /obj/item/storage/keyring))
		var/obj/item/storage/keyring/keyring = W
		var/has_valid_key = FALSE
		
		// Check if keyring contains a valid key
		for(var/obj/item/I in keyring.contents)
			if(istype(I, /obj/item/roguekey/garrison) || istype(I, /obj/item/roguekey/lord))
				has_valid_key = TRUE
				break
				
		if(has_valid_key)
			return toggle_lock(user, keyring)
	return ..()

/obj/item/clothing/neck/antimagic_collar/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot == SLOT_NECK)
		ADD_TRAIT(user, TRAIT_SPELLCOCKBLOCK, "antimagic_collar")
		to_chat(user, span_warning("You feel magic energies being disrupted around you as the collar settles on your neck."))
		if(locked)
			ADD_TRAIT(src, TRAIT_NODROP, "antimagic_lock")
			to_chat(user, span_danger("The collar clicks shut around your neck. You can't remove it while it's locked!"))

/obj/item/clothing/neck/antimagic_collar/dropped(mob/living/carbon/human/user)
	if(user && istype(user) && user.get_item_by_slot(SLOT_NECK) == src)
		REMOVE_TRAIT(user, TRAIT_SPELLCOCKBLOCK, "antimagic_collar")
		to_chat(user, span_notice("You feel magical energies flow around you once more as the collar is removed."))
	return ..()

// Helper proc to handle unlocking/locking a collar on someone's neck
/proc/toggle_collar_on_target(obj/item/clothing/neck/antimagic_collar/collar, mob/user, obj/item/key_item, mob/living/carbon/human/target)
	if(target.get_item_by_slot(SLOT_NECK) != collar)
		to_chat(user, span_warning("The collar must be worn around the neck to be locked or unlocked."))
		return FALSE
		
	if(collar.locked)
		collar.locked = 0
		playsound(collar, 'sound/misc/click.ogg', 25, TRUE)
		to_chat(user, span_notice("You unlock [collar] on [target]'s neck with [key_item]."))
		REMOVE_TRAIT(collar, TRAIT_NODROP, "antimagic_lock")
		to_chat(target, span_notice("The collar around your neck can now be removed."))
		return TRUE
	else
		collar.locked = 1
		playsound(collar, 'sound/misc/click.ogg', 25, TRUE)
		to_chat(user, span_notice("You lock [collar] on [target]'s neck with [key_item]."))
		ADD_TRAIT(collar, TRAIT_NODROP, "antimagic_lock")
		to_chat(target, span_warning("The collar locks around your neck."))
		return TRUE

// Add afterattack to the garrison key to unlock collars on neck slots
/obj/item/roguekey/garrison/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
		
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user.zone_selected == BODY_ZONE_PRECISE_NECK)
			var/obj/item/clothing/neck/antimagic_collar/collar = H.get_item_by_slot(SLOT_NECK)
			if(istype(collar))
				return toggle_collar_on_target(collar, user, src, H)
	return ..()

// Add afterattack to the lord key to unlock collars on neck slots
/obj/item/roguekey/lord/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
		
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user.zone_selected == BODY_ZONE_PRECISE_NECK)
			var/obj/item/clothing/neck/antimagic_collar/collar = H.get_item_by_slot(SLOT_NECK)
			if(istype(collar))
				return toggle_collar_on_target(collar, user, src, H)
	return ..()

// Add afterattack to the keyring to unlock collars on neck slots using a valid key
/obj/item/storage/keyring/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
		
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(user.zone_selected == BODY_ZONE_PRECISE_NECK)
			var/obj/item/clothing/neck/antimagic_collar/collar = H.get_item_by_slot(SLOT_NECK)
			if(istype(collar))
				// Check if keyring contains a valid key
				var/has_valid_key = FALSE
				for(var/obj/item/I in contents)
					if(istype(I, /obj/item/roguekey/garrison) || istype(I, /obj/item/roguekey/lord))
						has_valid_key = TRUE
						break
						
				if(has_valid_key)
					return toggle_collar_on_target(collar, user, src, H)
	else if(istype(target, /obj/item/clothing/neck/antimagic_collar))
		var/obj/item/clothing/neck/antimagic_collar/collar = target
		// Check if keyring contains a valid key
		var/has_valid_key = FALSE
		for(var/obj/item/I in contents)
			if(istype(I, /obj/item/roguekey/garrison) || istype(I, /obj/item/roguekey/lord))
				has_valid_key = TRUE
				break
				
		if(has_valid_key)
			return collar.toggle_lock(user, src)
	return ..()
