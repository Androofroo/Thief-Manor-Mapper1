/datum/antagonist/thief
	name = "Thief"
	roundend_category = "Thieves"
	antagpanel_category = "Thief"

	confess_lines = list(
		"I betrayed the lord!",
		"These valuables? I... found them!",
		"I was just going to return it, I swear!",
	)
	rogue_enabled = TRUE
	thief_enabled = TRUE // This will make it visible in villain selection
	var/lockpick_given = FALSE

/datum/antagonist/thief/on_gain()
	owner.special_role = name
	add_objectives()
	equip_thief()
	finalize_thief()
	greet()
	return ..()

/datum/antagonist/thief/proc/finalize_thief()
	var/mob/living/carbon/human/H = owner.current
	
	// If advsetup is already 0, give the lockpick immediately
	if(!H.advsetup)
		give_lockpick(H)

/datum/antagonist/thief/on_life(mob/living/carbon/human/H)
	// Check if the lockpick needs to be given and advsetup is complete
	if(!lockpick_given && !H.advsetup)
		give_lockpick(H)
	
	. = ..()

/datum/antagonist/thief/proc/equip_thief()
	var/mob/living/carbon/human/H = owner.current
	
	// Give thief the ability to snuff lights
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/snuff_light)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/magical_disguise)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/smoke_bomb)

	// Improve stealth-related skills
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 4, TRUE)
	// Only add knife skill if not a Manor Guard
	if(H.job != "Manor Guard")
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	// Only add athletics skill if not a Manor Guard
	if(H.job != "Manor Guard")
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

/datum/antagonist/thief/proc/give_lockpick(mob/living/carbon/human/H)
	if(lockpick_given || !H || !istype(H))
		return
	
	// Mark as given to prevent duplicates
	lockpick_given = TRUE
	
	// First check if the thief has a backpack or other storage
	var/obj/item/storage/backpack = H.back
	if(istype(backpack))
		new /obj/item/lockpickring/mundane(backpack)
		to_chat(H, span_notice("You find a lockpick ring in your backpack."))
		return
	
	// Try to place it in various equipment slots
	if(H.equip_to_slot_if_possible(new /obj/item/lockpickring/mundane(), SLOT_IN_BACKPACK))
		to_chat(H, span_notice("You find a lockpick ring tucked away in your backpack."))
		return
	
	// Try belt slots
	var/list/belt_slots = list(SLOT_BELT, SLOT_BELT_L, SLOT_BELT_R)
	for(var/belt_slot in belt_slots)
		if(H.equip_to_slot_if_possible(new /obj/item/lockpickring/mundane(), belt_slot))
			to_chat(H, span_notice("You find a lockpick ring attached to your belt."))
			return
	
	// If all else fails, drop at feet
	new /obj/item/lockpickring/mundane(get_turf(H))
	to_chat(H, span_notice("A lockpick ring appears at your feet."))

/datum/antagonist/thief/greet()
	to_chat(owner.current, "<span class='userdanger'>You are a thief!</span>")
	to_chat(owner.current, "<span class='boldwarning'>You've worked in the manor for years, always overlooked, always underappreciated. You know every corner, every secret passage. Now it's time to take what you deserve - precious treasures! Your insider knowledge gives you an advantage, but betrayal is punished harshly in these lands.</span>")
	to_chat(owner.current, "<span class='boldnotice'>You've been trained in the art of the thief, and have stealthy abilities and tools to help you complete your mission.</span>")
	
	
	if(owner.current.mind)
		owner.current.mind.show_memory()
	
	// Play thief theme music
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/thief.ogg', 60, FALSE, pressure_affected = FALSE)

/datum/antagonist/thief/proc/add_objectives()
	// We'll create objective items dynamically based on available treasures
	var/list/treasure_objectives = list()
	
	// Get all treasure subtypes
	var/list/treasure_types = subtypesof(/obj/item/treasure)
	treasure_types -= /obj/item/treasure // Remove the base type
	
	// Create objective items for each treasure
	for(var/treasure_path in treasure_types)
		var/obj/item/treasure/T = treasure_path
		
		// Create a new objective item for this treasure
		var/datum/objective_item/steal/treasure_objective = new
		treasure_objective.name = "the [initial(T.name)]"
		treasure_objective.targetitem = treasure_path
		treasure_objective.difficulty = initial(T.difficulty) || 1 // Use the treasure's difficulty or default to 1
		
		// Skip if this is for jobs the thief can't target
		if(owner.assigned_role in treasure_objective.excludefromjob)
			continue
			
		treasure_objectives += treasure_objective
	
	// If we don't have enough objectives, we're done
	if(treasure_objectives.len < 2)
		if(treasure_objectives.len > 0)
			// Add at least the one we have
			var/datum/objective_item/steal/selected_item = pick(treasure_objectives)
			
			var/datum/objective/steal/steal_obj = new
			steal_obj.owner = owner
			steal_obj.targetinfo = selected_item
			steal_obj.steal_target = selected_item.targetitem
			steal_obj.explanation_text = "Steal [selected_item.name]"
			objectives += steal_obj
			
			// If the objective is Kassidy's Leotard, make sure it exists in the world
			if(istype(selected_item.targetitem, /obj/item/treasure/kassidy) && !locate(/obj/item/treasure/kassidy) in world)
				new /obj/item/treasure/kassidy() // This will automatically place itself in a random location
		
		// Add survival objective
		var/datum/objective/survive/survive_obj = new
		survive_obj.owner = owner
		objectives += survive_obj
		
		owner.announce_objectives()
		return
	
	// Create weighted list based on difficulty
	var/list/weighted_treasures = list()
	for(var/datum/objective_item/steal/item in treasure_objectives)
		// Add with weighting based on inverse of difficulty
		// Higher difficulty = lower chance of selection
		var/weight = 10 - item.difficulty
		// Ensure at least a minimal chance for high-difficulty items
		weight = max(weight, 1)
		
		weighted_treasures[item] = weight
	
	// Pick first objective
	var/datum/objective_item/steal/first_objective = pickweight(weighted_treasures)
	
	var/datum/objective/steal/steal_obj1 = new
	steal_obj1.owner = owner
	steal_obj1.targetinfo = first_objective
	steal_obj1.steal_target = first_objective.targetitem
	steal_obj1.explanation_text = "Steal [first_objective.name]"
	objectives += steal_obj1
	
	// Remove the first selected item from the weighted list
	weighted_treasures -= first_objective
	
	// Pick second objective
	var/datum/objective_item/steal/second_objective = pickweight(weighted_treasures)
	
	var/datum/objective/steal/steal_obj2 = new
	steal_obj2.owner = owner
	steal_obj2.targetinfo = second_objective
	steal_obj2.steal_target = second_objective.targetitem
	steal_obj2.explanation_text = "Steal [second_objective.name]"
	objectives += steal_obj2
	
	// Check if either objective is Kassidy's Leotard and ensure it exists
	if((istype(first_objective.targetitem, /obj/item/treasure/kassidy) || istype(second_objective.targetitem, /obj/item/treasure/kassidy)) && !locate(/obj/item/treasure/kassidy) in world)
		new /obj/item/treasure/kassidy() // This will automatically place itself in a random location
	
	// Add survival objective
	var/datum/objective/survive/survive_obj = new
	survive_obj.owner = owner
	objectives += survive_obj
	
	// Announce objectives
	owner.announce_objectives()

/obj/effect/proc_holder/spell/self/snuff_light
	name = "Snuff Light"
	desc = "Silently extinguish lights in your view to enhance your stealth operations."
	overlay_state = "sacredflame"
	antimagic_allowed = TRUE
	charge_max = 3000 // 5 minutes (300 seconds)
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "spell0"

/obj/effect/proc_holder/spell/self/snuff_light/cast(mob/user = usr)
	var/snuffed = FALSE
	var/snuff_count = 0
	
	// Find all lights visible to the user
	for(var/obj/machinery/light/rogue/L in view(user))
		if(L.on)
			L.burn_out() // Extinguish the light
			snuffed = TRUE
			snuff_count++
	
	// Also extinguish any candles in view
	for(var/obj/item/candle/C in view(user))
		if(C.lit)
			C.lit = FALSE
			C.update_icon()
			C.set_light(0)
			snuffed = TRUE
			snuff_count++
	
	// Also extinguish any torches in view
	for(var/obj/item/flashlight/flare/torch/T in view(user))
		if(T.on)
			T.on = FALSE
			T.update_brightness()
			snuffed = TRUE
			snuff_count++
	
	if(snuffed)
		to_chat(user, "<span class='notice'>You silently extinguish [snuff_count] nearby lights.</span>")
		return TRUE // Return TRUE to trigger cooldown
	else
		to_chat(user, "<span class='warning'>There are no lit lights within sight.</span>")
		revert_cast() // Revert spell cast to reset cooldown
		return FALSE // Return FALSE to prevent cooldown

// New spell for thieves to magically disguise themselves as someone else
/obj/effect/proc_holder/spell/self/magical_disguise
	name = "Magical Disguise"
	desc = "Take on the appearance of another person."
	overlay_state = "comedy"
	clothes_req = FALSE
	human_req = TRUE
	charge_max = 600
	cooldown_min = 400
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "spell0"
	
	var/datum/disguise_info/stored_appearance
	var/mob/living/carbon/human/current_target
	var/disguise_duration = 2400 // 4 minutes
	var/disguise_active = FALSE
	var/datum/icon_snapshot/snapshot   // Snapshot of target's appearance
	var/list/original_held_items = list() // To track what items were originally held

/obj/effect/proc_holder/spell/self/magical_disguise/cast(list/targets, mob/living/carbon/human/user)
	if(disguise_active)
		remove_disguise(user)
		return TRUE // Return TRUE to trigger cooldown when removing an active disguise
		
	var/list/mob/living/carbon/human/targets_with_minds = list()
	
	// Find all human mobs with minds, regardless of distance
	for(var/mob/living/carbon/human/H)
		if(H != user && H.mind) // Only include other mobs with minds
			// Always use actual name for the menu, not the visible name
			var/target_name = H.real_name
			if(H.job) // Add job in parentheses if available
				target_name = "[target_name] ([H.job])"
			targets_with_minds[target_name] = H
	
	if(!length(targets_with_minds))
		to_chat(user, "<span class='warning'>No valid targets found!</span>")
		revert_cast()
		return FALSE // Don't trigger cooldown
	
	// Let the user select from the list with formatted names
	var/choice = input("Select a target to disguise as.", "Disguise Target") as null|anything in targets_with_minds
	if(!choice)
		to_chat(user, "<span class='warning'>No target selected!</span>")
		revert_cast() 
		return FALSE // Don't trigger cooldown
	
	var/mob/living/carbon/human/selected_target = targets_with_minds[choice]
	if(!selected_target || QDELETED(selected_target))
		to_chat(user, "<span class='warning'>Invalid target!</span>")
		revert_cast()
		return FALSE // Don't trigger cooldown
	
	if(!do_after(user, 50, target = user))
		to_chat(user, "<span class='warning'>You were interrupted!</span>")
		revert_cast() // Use revert_cast to properly reset spell charge
		return FALSE // Don't trigger cooldown
	
	apply_disguise(user, selected_target)
	return TRUE // Return TRUE to trigger cooldown

/obj/effect/proc_holder/spell/self/magical_disguise/proc/apply_disguise(mob/living/carbon/human/user, mob/living/carbon/human/target)
	// Store original appearance info for later restoration
	current_target = target
	stored_appearance = new /datum/disguise_info(user)
	
	// Store original held items
	original_held_items.Cut()
	for(var/obj/item/I in user.held_items)
		if(!(I.item_flags & ABSTRACT))
			original_held_items += I
	
	// Force regenerate target's icons to ensure complete appearance capture
	target.regenerate_icons()
	
	// Create a snapshot of the target's visual appearance
	snapshot = new
	snapshot.name = target.name
	snapshot.icon = target.icon
	snapshot.icon_state = target.icon_state
	
	// Capture all overlays from the target
	snapshot.overlays = list()
	for(var/overlay in target.overlays)
		snapshot.overlays += overlay
	
	// Store the user's original appearance
	stored_appearance.original_icon = user.icon
	stored_appearance.original_icon_state = user.icon_state
	stored_appearance.original_overlays = user.overlays.Copy()
	stored_appearance.original_obscured_flags = user.obscured_flags
	stored_appearance.original_name_override = user.name_override
	stored_appearance.original_advjob = user.advjob
	stored_appearance.original_strength = user.STASTR
	
	// Store fake traits for examination purposes
	stored_appearance.fake_traits = list()
	// Check if target has any of these traits
	var/list/traits_to_check = list(
		TRAIT_NOBLE, TRAIT_OUTLANDER, TRAIT_WITCH, TRAIT_BEAUTIFUL, TRAIT_UNSEEMLY, 
		TRAIT_INQUISITION, TRAIT_COMMIE, TRAIT_CABAL, TRAIT_HORDE, TRAIT_DEPRAVED
	)
	for(var/trait in traits_to_check)
		if(HAS_TRAIT(target, trait))
			stored_appearance.fake_traits += trait
	
	// Find and temporarily disable all of the user's own movement sound components
	stored_appearance.original_movement_components = list()
	
	// Get all of the user's equipped items with their variable names using the helper function
	var/list/user_equipment_data = user.get_visible_equipment_data(include_hands = TRUE, include_detailed_info = FALSE)
	
	// Store references to the user's original movement components and REMOVE them temporarily
	for(var/var_name in user_equipment_data)
		if(var_name == "held_items")
			continue // Skip held items for this processing
		
		var/obj/item/gear = user_equipment_data[var_name]
		for(var/datum/component/item_equipped_movement_rustle/R in gear.GetComponents(/datum/component/item_equipped_movement_rustle))
			// Store component parameters to recreate it later
			var/list/component_params = list(
				"item" = gear,
				"rustle_sounds" = R.rustle_sounds,
				"move_delay" = R.move_delay,
				"volume" = R.volume,
				"sound_vary" = R.sound_vary,
				"sound_extra_range" = R.sound_extra_range,
				"sound_falloff_exponent" = R.sound_falloff_exponent,
				"sound_falloff_distance" = R.sound_falloff_distance
			)
			stored_appearance.original_movement_components += list(component_params)
			
			// Remove the component
			qdel(R)
	
	// Store original existing mimic component if any
	var/datum/component/disguise_sound_mimic/existing_mimic = user.GetComponent(/datum/component/disguise_sound_mimic)
	if(existing_mimic)
		qdel(existing_mimic)
	
	// Look for all equipped items on the target that have movement components
	// and create a new sound mimicking component for the user
	var/list/sound_parameters = list()
	
	// Get all equipped items from the target with their variable names
	var/list/target_equipment_data = target.get_visible_equipment_data(include_hands = TRUE, include_detailed_info = FALSE)
	
	// Check each item for movement components and store their parameters
	for(var/var_name in target_equipment_data)
		if(var_name == "held_items")
			continue // Skip held items for this processing
			
		var/obj/item/gear = target_equipment_data[var_name]
		for(var/datum/component/item_equipped_movement_rustle/R in gear.GetComponents(/datum/component/item_equipped_movement_rustle))
			sound_parameters += list(list(
				"rustle_sounds" = R.rustle_sounds,
				"move_delay" = R.move_delay,
				"volume" = R.volume,
				"sound_vary" = R.sound_vary,
				"sound_extra_range" = R.sound_extra_range,
				"sound_falloff_exponent" = R.sound_falloff_exponent,
				"sound_falloff_distance" = R.sound_falloff_distance
			))
	
	// Add a component to mimic the sounds of the target's gear
	if(length(sound_parameters))
		user.AddComponent(/datum/component/disguise_sound_mimic, sound_parameters)
	
	// Store original traits that will be copied
	stored_appearance.original_traits = list()
	for(var/trait in traits_to_check)
		if(HAS_TRAIT(user, trait))
			stored_appearance.original_traits += trait
	
	// Handle identity - check if target's face is concealed/unknown
	var/target_visible_name = target.get_visible_name()
	var/static/list/unknown_names = list(
		"Unknown",
		"Unknown Man",
		"Unknown Woman",
	)
	
	if(target_visible_name in unknown_names)
		// If target appears as "Unknown", we should store that fact
		stored_appearance.disguised_as_unknown = TRUE
		// Set name_override to match the target's visible name for mouseover
		user.name_override = target_visible_name
		// Store target's visible name for examination
		stored_appearance.target_visible_name = target_visible_name
	else
		// Otherwise use the target's normal name
		stored_appearance.disguised_as_unknown = FALSE
		user.name_override = null // Clear any existing name override
		user.real_name = target.real_name
		user.name = target.name
	
	// Copy job if available
	if(target.job)
		stored_appearance.original_job = user.job
		user.job = target.job
		
		// Handle advanced job title if the target has one
		var/datum/job/T_Job = SSjob.GetJob(target.job)
		if(T_Job?.advjob_examine && target.advjob)
			stored_appearance.original_advjob = user.advjob
			user.advjob = target.advjob
	
	// Copy gender first - this ensures descriptors will generate properly
	stored_appearance.gender = user.gender
	user.gender = target.gender
	
	// Copy pronouns - essential for proper descriptor generation
	stored_appearance.pronouns = user.pronouns
	user.pronouns = target.pronouns
	
	// Copy the target's voice type, color, and pitch
	stored_appearance.voice_type = user.voice_type
	stored_appearance.original_voice_color = user.voice_color
	stored_appearance.original_voice_pitch = user.voice_pitch
	user.voice_type = target.voice_type
	user.voice_color = target.voice_color
	user.voice_pitch = target.voice_pitch
	
	// Instead of directly copying strength, add a trait that will be checked during examine
	ADD_TRAIT(user, TRAIT_FAKE_STRENGTH, MAGICAL_DISGUISE_TRAIT)
	user.fake_strength = target.STASTR  // Store the fake strength value to use during examine
	
	// Instead of directly adding traits, add a special trait for disguise and store the fake traits
	ADD_TRAIT(user, TRAIT_HAS_FAKE_TRAITS, MAGICAL_DISGUISE_TRAIT)
	
	// Copy species name and descriptors for examination
	if(istype(target) && target.dna && target.dna.species)
		stored_appearance.target_species_name = target.dna.species.name
		// Add the target species name trait to the user so examine() can access it
		ADD_TRAIT(user, TRAIT_DISGUISED_SPECIES, MAGICAL_DISGUISE_TRAIT)
		
		// Store original and target descriptors
		var/list/original_descriptors = user.mob_descriptors ? user.mob_descriptors.Copy() : list()
		var/list/target_descriptors = target.mob_descriptors ? target.mob_descriptors.Copy() : list()
		
		// Capture the visible equipment from the target
		var/list/equipment_data = target.get_visible_equipment_data()
		
		// Add our custom component
		user.AddComponent(/datum/component/disguised_species, target.dna.species.name, target_descriptors, original_descriptors, equipment_data, stored_appearance.disguised_as_unknown, stored_appearance.target_visible_name, stored_appearance.fake_traits)
		
		// Replace the user's descriptors with the target's after gender has been set
		user.clear_mob_descriptors()
		if(length(target_descriptors))
			user.mob_descriptors = target_descriptors.Copy()
	
	// Copy the target's obscured flags to properly handle hidden features
	user.obscured_flags = target.obscured_flags
	
	// Apply the visual snapshot to the user
	user.icon = snapshot.icon
	user.icon_state = snapshot.icon_state
	user.cut_overlays()
	for(var/overlay in snapshot.overlays)
		user.add_overlay(overlay)
	
	// Force an immediate appearance update using setDir to toggle direction briefly
	// This is a reliable BYOND trick to force a client appearance update without regenerating icons
	var/original_dir = user.dir
	user.setDir(turn(original_dir, 90))  // Change direction
	user.setDir(original_dir)  // Change back to original direction
	
	// Override attack and equip functions to break the disguise
	ADD_TRAIT(user, TRAIT_DISGUISE_ACTIVE, MAGICAL_DISGUISE_TRAIT)
	
	// Add the break disguise verb to the user
	user.verbs |= /mob/proc/break_magical_disguise
	
	// Set up a timer to remove the disguise
	addtimer(CALLBACK(src, PROC_REF(remove_disguise), user), disguise_duration)
	
	disguise_active = TRUE
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Create a more detailed disguise message that includes the job if available
	var/disguise_message = "You take on the appearance of [target_visible_name]"
	if(target.job)
		disguise_message += ", the [target.get_role_title()]"
	disguise_message += "! Attacking, putting anything in your hands or changing your clothing will break the disguise."
	
	// Add visual effect - lens shimmer effect from the Mirror of Truth
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(user))
	shimmer.color = "#c0ffff"
	
	to_chat(user, "<span class='notice'>[disguise_message]</span>")

/obj/effect/proc_holder/spell/self/magical_disguise/proc/remove_disguise(mob/living/carbon/human/user, force_update = FALSE)
	if(!disguise_active && !force_update)
		return
	
	// Mark as not active early to prevent recursion
	disguise_active = FALSE
	
	// Clear the snapshot and active target first to ensure we don't use old data
	snapshot = null
	current_target = null
	
	// If we don't have stored appearance data, just regenerate icons and return
	if(!stored_appearance)
		user.regenerate_icons()
		return
	
	// Restore original icon data
	user.icon = stored_appearance.original_icon
	user.icon_state = stored_appearance.original_icon_state
	user.cut_overlays()
	for(var/overlay in stored_appearance.original_overlays)
		user.add_overlay(overlay)
	
	// Restore identity information
	user.real_name = stored_appearance.real_name
	user.name = stored_appearance.name
	user.gender = stored_appearance.gender
	user.pronouns = stored_appearance.pronouns
	user.voice_type = stored_appearance.voice_type
	user.voice_color = stored_appearance.original_voice_color
	user.voice_pitch = stored_appearance.original_voice_pitch
	user.name_override = stored_appearance.original_name_override
	
	// Restore job if it was changed
	if(stored_appearance.original_job)
		user.job = stored_appearance.original_job
	
	// Restore advjob if it was changed
	if(stored_appearance.original_advjob)
		user.advjob = stored_appearance.original_advjob
	
	// Remove fake strength trait and value
	REMOVE_TRAIT(user, TRAIT_FAKE_STRENGTH, MAGICAL_DISGUISE_TRAIT)
	user.fake_strength = null
	
	// Remove fake traits indicator
	REMOVE_TRAIT(user, TRAIT_HAS_FAKE_TRAITS, MAGICAL_DISGUISE_TRAIT)
	
	// Remove the disguise sound mimic component
	var/datum/component/disguise_sound_mimic/sound_mimic = user.GetComponent(/datum/component/disguise_sound_mimic)
	if(sound_mimic)
		qdel(sound_mimic)
	
	// Restore original movement sound components by recreating them
	if(stored_appearance.original_movement_components)
		for(var/list/component_data in stored_appearance.original_movement_components)
			var/obj/item/gear = component_data["item"]
			
			// Check if item still exists and is currently equipped
			if(gear && !QDELETED(gear) && ismob(gear.loc))
				var/mob/M = gear.loc
				
				// First check if the item already has a rustle component
				var/has_rustle_component = FALSE
				for(var/datum/component/item_equipped_movement_rustle/existing in gear.GetComponents(/datum/component/item_equipped_movement_rustle))
					has_rustle_component = TRUE
					break
				
				// Only add a new component if there isn't one already
				if(!has_rustle_component)
					// Recreate the original component with stored parameters
					var/datum/component/item_equipped_movement_rustle/new_rustle = gear.AddComponent(/datum/component/item_equipped_movement_rustle, 
						component_data["rustle_sounds"],
						component_data["move_delay"],
						component_data["volume"],
						component_data["sound_vary"],
						component_data["sound_extra_range"],
						component_data["sound_falloff_exponent"],
						component_data["sound_falloff_distance"]
					)
					
					// Manually trigger the on_equip signal to properly register the component
					if(new_rustle && ishuman(M))
						var/mob/living/carbon/human/H = M
						
						// Get the slot using the new generic helper function
						var/slot = H.get_slot_from_item(gear)
						
						// Manually call the on_equip proc to register signals properly if we found a valid slot
						if(slot != NONE)
							new_rustle.on_equip(gear, H, slot)
	
	// Restore original traits by removing disguise trait versions
	for(var/trait in list(TRAIT_NOBLE, TRAIT_OUTLANDER, TRAIT_WITCH, TRAIT_BEAUTIFUL, TRAIT_UNSEEMLY, 
						  TRAIT_INQUISITION, TRAIT_COMMIE, TRAIT_CABAL, TRAIT_HORDE, TRAIT_DEPRAVED))
		REMOVE_TRAIT(user, trait, MAGICAL_DISGUISE_TRAIT)
	
	// Re-add original traits
	for(var/trait in stored_appearance.original_traits)
		ADD_TRAIT(user, trait, TRAIT_GENERIC)
	
	// Restore original obscured flags
	user.obscured_flags = stored_appearance.original_obscured_flags
	
	// Force complete icon regeneration to ensure original appearance is fully restored
	user.cut_overlays() 
	user.overlays.Cut()
	user.regenerate_icons()
	
	// Get the component and restore original descriptors
	var/datum/component/disguised_species/DS = user.GetComponent(/datum/component/disguised_species)
	if(DS)
		// Restore original descriptors
		user.clear_mob_descriptors()
		var/list/original_descriptors = DS.get_disguise_data("original_descriptors")
		if(length(original_descriptors))
			user.mob_descriptors = original_descriptors.Copy()
		
		// Remove the component
		qdel(DS)
	
	// Remove all disguise-related traits
	REMOVE_TRAIT(user, TRAIT_DISGUISED_SPECIES, MAGICAL_DISGUISE_TRAIT)
	REMOVE_TRAIT(user, TRAIT_DISGUISE_ACTIVE, MAGICAL_DISGUISE_TRAIT)
	
	// Remove the break disguise verb
	user.verbs -= /mob/proc/break_magical_disguise
	
	// Clear stored data
	stored_appearance = null
	original_held_items.Cut()
	
	// Final appearance refresh without moving the player
	user.regenerate_icons()
	
	// Add visual effect when removing the disguise
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(user))
	shimmer.color = "#ffc0ff" // Light pink color for the reversal effect
	
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	to_chat(user, "<span class='warning'>Your magical disguise wears off!</span>")

// New helper proc to completely remove all disguise effects
/mob/living/carbon/human/proc/remove_all_disguise_effects(message)
	to_chat(src, "<span class='warning'>[message]</span>")
	playsound(get_turf(src), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Visual effect to indicate the disguise breaking
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	sparks.start()
	
	// Add lens shimmer effect when breaking the disguise
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(src))
	shimmer.color = "#ff7070" // Reddish color for the broken effect
	
	// Remove disguise active trait first to prevent recursive calls
	REMOVE_TRAIT(src, TRAIT_DISGUISE_ACTIVE, MAGICAL_DISGUISE_TRAIT)
	
	// Find and remove the disguise
	for(var/obj/effect/proc_holder/spell/self/magical_disguise/spell in src.mind.spell_list)
		if(spell.disguise_active)
			spell.remove_disguise(src, force_update = TRUE)
			break
	
	// Force a thorough visual refresh
	src.cut_overlays() 
	src.overlays.Cut()
	src.regenerate_icons() // Regenerate all icons at once

// Override these functions in the mob/living/carbon/human type to detect when the disguise should break
/mob/living/carbon/human/ClickOn(atom/A, params)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE))
		// Check if the user is trying to attack something
		var/list/modifiers = params2list(params)
		if(modifiers["shift"] || modifiers["alt"] || modifiers["ctrl"])
			// Likely not an attack, let it proceed
			return ..()
		
		if(get_dist(src, A) <= 1 && isliving(A) && A != src)
			// This is likely an attack on a nearby living mob
			remove_all_disguise_effects("Attempting to attack breaks your magical disguise!")
			return ..()
	
	return ..()

// Hook into item equipping/unequipping
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE, silent = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !initial && !silent)
		remove_all_disguise_effects("Equipping an item breaks your magical disguise!")
	
	. = ..()

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	// First call the parent to actually unequip the item
	var/success = ..()
	
	// If we successfully unequipped the item and we have a disguise active
	if(success && HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !silent)
		// Instead of just breaking the disguise, we need to do a full sprite reset
		remove_all_disguise_effects("Unequipping an item breaks your magical disguise!")
	
	return success

// Helper method to handle item interactions that break disguise
/mob/living/carbon/human/proc/handle_item_interaction(obj/item/I, forced = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !forced && !istype(I, /obj/item/clothing/head/mob_holder))
		remove_all_disguise_effects("Handling an item breaks your magical disguise!")
		return TRUE
	return FALSE

// Override item handling methods to use the helper
/mob/living/carbon/human/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, forced = FALSE)
	handle_item_interaction(I, forced)
	. = ..()

/mob/living/carbon/human/put_in_hand_check(obj/item/I, hand_index, forced = FALSE)
	handle_item_interaction(I, forced)
	. = ..()

/mob/living/carbon/human/put_in_active_hand(obj/item/I, forced = FALSE)
	handle_item_interaction(I, forced)
	. = ..()

/mob/living/carbon/human/put_in_inactive_hand(obj/item/I, forced = FALSE)
	handle_item_interaction(I, forced)
	. = ..()

/mob/living/carbon/human/attack_hand(atom/movable/AM)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && isitem(AM))
		remove_all_disguise_effects("Picking up an item breaks your magical disguise!")
	
	. = ..()

// Update the break_magical_disguise verb to use our new helper
/mob/proc/break_magical_disguise()
	set name = "Break Disguise"
	set desc = "Voluntarily break your magical disguise."
	set category = "Abilities"
	
	if(!ishuman(src))
		return
		
	var/mob/living/carbon/human/H = src
	
	// Check if they have an active disguise
	if(HAS_TRAIT(H, TRAIT_DISGUISE_ACTIVE))
		to_chat(H, "<span class='notice'>You dispel your magical disguise.</span>")
		H.remove_all_disguise_effects("You voluntarily break your magical disguise.")
		return
	
	to_chat(H, "<span class='warning'>You don't have an active disguise to break!</span>")

// Simplified helper datum to store original appearance information
/datum/disguise_info
	var/real_name
	var/name
	var/gender
	var/pronouns
	var/original_job
	var/original_advjob
	var/target_species_name
	var/icon/original_icon
	var/original_icon_state
	var/list/original_overlays
	var/original_obscured_flags
	var/disguised_as_unknown = FALSE
	var/target_visible_name
	var/original_name_override
	var/original_strength
	var/voice_type  // Store original voice type
	var/original_voice_color  // Store original voice color
	var/original_voice_pitch  // Store original voice pitch
	var/list/original_traits
	var/list/original_movement_components
	var/list/target_movement_components
	var/list/fake_traits // List of traits the target has that we want to fake having

	// Constructor stores the original properties
	New(mob/living/carbon/human/H)
		src.real_name = H.real_name
		src.name = H.name
		src.gender = H.gender
		src.pronouns = H.pronouns
		src.original_name_override = H.name_override
		src.original_advjob = H.advjob
		src.original_strength = H.STASTR
		src.voice_type = H.voice_type  // Store original voice type
		src.original_voice_color = H.voice_color  // Store original voice color
		src.original_voice_pitch = H.voice_pitch  // Store original voice pitch

// The component to store species and descriptor info
/datum/component/disguised_species
	var/species_name
	var/list/original_descriptors
	var/list/disguised_descriptors
	var/list/disguised_equipment  // List to store visible equipment info
	var/is_face_hidden = FALSE
	var/visible_name = null
	var/list/fake_traits = list() // List of traits to fake having during examine

/datum/component/disguised_species/Initialize(species_name, list/disguised_descriptors, list/original_descriptors, list/disguised_equipment, is_face_hidden = FALSE, visible_name = null, list/fake_traits = list())
	src.species_name = species_name
	src.disguised_descriptors = disguised_descriptors
	src.original_descriptors = original_descriptors
	src.disguised_equipment = disguised_equipment
	src.is_face_hidden = is_face_hidden
	src.visible_name = visible_name
	src.fake_traits = fake_traits
	
/datum/component/disguised_species/proc/get_disguise_data(data_type)
	switch(data_type)
		if("species_name")
			return species_name
		if("descriptors")
			return disguised_descriptors
		if("original_descriptors")
			return original_descriptors
		if("equipment")
			return disguised_equipment
		if("concealed")
			return is_face_hidden
		if("visible_name")
			return visible_name
		if("fake_traits")
			return fake_traits
		else
			return null

// New component to mimic the sounds from equipped items
/datum/component/disguise_sound_mimic
	var/list/sound_parameters = list()
	var/list/sound_counters = list() // Track counters for each sound separately
	var/disabled = FALSE             // Add a disabled flag to the component

/datum/component/disguise_sound_mimic/Initialize(list/parameters)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	
	sound_parameters = parameters
	
	// Initialize counters for each sound parameter
	sound_counters = list()
	for(var/i in 1 to length(sound_parameters))
		sound_counters += 0
	
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/component/disguise_sound_mimic/proc/on_move()
	SIGNAL_HANDLER
	
	if(!sound_parameters.len || disabled)
		return
	
	// Check each sound individually with its own counter
	for(var/i in 1 to length(sound_parameters))
		var/list/params = sound_parameters[i]
		sound_counters[i]++
		
		if(sound_counters[i] >= params["move_delay"])
			sound_counters[i] = 0
			
			// Play this specific sound
			playsound(parent, params["rustle_sounds"], 
				params["volume"], 
				params["sound_vary"], 
				params["sound_extra_range"], 
				params["sound_falloff_exponent"], 
				falloff = params["sound_falloff_distance"])

/datum/component/disguise_sound_mimic/Destroy()
	UnregisterSignal(parent, COMSIG_MOVABLE_MOVED)
	return ..()

/obj/effect/proc_holder/spell/self/smoke_bomb
	name = "Smoke Bomb"
	desc = "Release a cloud of thick smoke around you, perfect for confusing guards or making a quick escape."
	overlay_state = "smokebomb"
	clothes_req = FALSE
	human_req = TRUE
	charge_max = 300
	cooldown_min = 300
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "spell0"
	
/obj/effect/proc_holder/spell/self/smoke_bomb/cast(list/targets, mob/living/carbon/human/user)
	var/turf/T = get_turf(user)
	
	playsound(T, 'sound/items/smokebomb.ogg', 100, TRUE)
	user.visible_message(span_warning("[user] releases a cloud of smoke!"), span_notice("You release a thick cloud of smoke around yourself!"))
	
	// Create the smoke effect
	var/datum/effect_system/smoke_spread/bad/smoke = new
	smoke.set_up(8, T) // Large smoke radius of 8
	smoke.start()
	
	return TRUE


