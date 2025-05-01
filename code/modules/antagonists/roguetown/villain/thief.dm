// Villain jobs based on stealth and stealing
#define TRAIT_DISGUISE_ACTIVE "disguise_active"

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
	to_chat(H, span_alertsyndie("I am a THIEF!"))
	to_chat(H, span_boldwarning("I've worked in the manor for years, always overlooked, always underappreciated. I know every corner, every secret passage. Now it's time to take what I deserve - the Lord's Crown. My insider knowledge gives me an advantage, but betrayal is punished harshly in these lands."))
	to_chat(H, span_boldnotice("I've learned how to silently snuff out lights to help me move unseen. Use the Snuff Light ability to extinguish any fire or light source within reach."))
	to_chat(H, span_boldnotice("I also possess the Magical Disguise spell that allows me to take on the appearance of any person for a short time. This can help me infiltrate restricted areas or avoid detection."))

/datum/antagonist/thief/greet()
	owner.announce_objectives()

/datum/antagonist/thief/proc/equip_thief()
	var/mob/living/carbon/human/H = owner.current
	
	
	// Give thief the ability to snuff lights
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/snuff_light)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/magical_disguise)

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

/datum/antagonist/thief/proc/add_objectives()
	var/datum/objective/steal/steal_obj = new
	steal_obj.owner = owner
	
	// Make sure GLOB.possible_items is populated
	if(!GLOB.possible_items.len)
		for(var/I in subtypesof(/datum/objective_item/steal/rogue))
			new I
	
	
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

/obj/effect/proc_holder/spell/self/snuff_light
	name = "Snuff Light"
	desc = "Silently extinguish nearby lights to enhance your stealth operations."
	overlay_state = "sacredflame"
	antimagic_allowed = TRUE
	charge_max = 50 // 5 seconds
	clothes_req = FALSE
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "spell0"

/obj/effect/proc_holder/spell/self/snuff_light/cast(mob/user = usr)
	var/snuffed = FALSE
	
	// Find all lights in range around the user
	for(var/obj/machinery/light/rogue/L in range(1, user))
		if(L.on)
			L.burn_out() // Extinguish the light
			snuffed = TRUE
	
	if(snuffed)
		to_chat(user, "<span class='notice'>You silently extinguish nearby lights.</span>")
	else
		to_chat(user, "<span class='warning'>There are no lit lights within reach.</span>")
	
	return TRUE

// New spell for thieves to magically disguise themselves as someone else
/obj/effect/proc_holder/spell/self/magical_disguise
	name = "Magical Disguise"
	desc = "Take on the appearance of another person."
	clothes_req = FALSE
	human_req = TRUE
	charge_max = 600
	cooldown_min = 400
	action_icon = 'icons/mob/actions/roguespells.dmi'
	action_icon_state = "comedy"
	
	var/datum/disguise_info/stored_appearance
	var/mob/living/carbon/human/current_target
	var/disguise_duration = 2400 // 4 minutes
	var/disguise_active = FALSE
	var/datum/icon_snapshot/snapshot   // Snapshot of target's appearance
	var/list/original_held_items = list() // To track what items were originally held

/obj/effect/proc_holder/spell/self/magical_disguise/cast(list/targets, mob/living/carbon/human/user)
	if(disguise_active)
		remove_disguise(user)
		return
		
	var/list/mob/living/carbon/human/targets_with_minds = list()
	
	// Find all human mobs with minds, regardless of distance
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H != user && H.mind) // Only include other mobs with minds
			var/target_name = H.name
			if(H.job) // Add job in parentheses if available
				target_name = "[target_name] ([H.job])"
			targets_with_minds[target_name] = H
	
	if(!length(targets_with_minds))
		to_chat(user, "<span class='warning'>No valid targets found!</span>")
		return
	
	// Let the user select from the list with formatted names
	var/choice = input("Select a target to disguise as.", "Disguise Target") as null|anything in targets_with_minds
	if(!choice)
		to_chat(user, "<span class='warning'>No target selected!</span>")
		return
	
	var/mob/living/carbon/human/selected_target = targets_with_minds[choice]
	if(!selected_target || QDELETED(selected_target))
		to_chat(user, "<span class='warning'>Invalid target!</span>")
		return
	
	if(!do_after(user, 50, target = user))
		to_chat(user, "<span class='warning'>You were interrupted!</span>")
		return
	
	apply_disguise(user, selected_target)

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
	
	// Copy gender first - this ensures descriptors will generate properly
	user.gender = target.gender
	
	// Copy species name and descriptors for examination
	if(istype(target) && target.dna && target.dna.species)
		stored_appearance.target_species_name = target.dna.species.name
		// Add the target species name trait to the user so examine() can access it
		ADD_TRAIT(user, TRAIT_DISGUISED_SPECIES, MAGICAL_DISGUISE_TRAIT)
		
		// Store original and target descriptors
		var/list/original_descriptors = user.mob_descriptors ? user.mob_descriptors.Copy() : list()
		var/list/target_descriptors = target.mob_descriptors ? target.mob_descriptors.Copy() : list()
		
		// Capture the visible equipment from the target
		var/list/equipment_data = capture_visible_equipment(target)
		
		// Add our custom component that doesn't use signals
		user.AddComponent(/datum/component/disguised_species, target.dna.species.name, target_descriptors, original_descriptors, equipment_data, stored_appearance.disguised_as_unknown, stored_appearance.target_visible_name)
		
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
	
	// Override attack and equip functions to break the disguise
	ADD_TRAIT(user, TRAIT_DISGUISE_ACTIVE, MAGICAL_DISGUISE_TRAIT)
	
	// Set up a timer to remove the disguise
	addtimer(CALLBACK(src, PROC_REF(remove_disguise), user), disguise_duration)
	
	disguise_active = TRUE
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Create a more detailed disguise message that includes the job if available
	var/disguise_message = "You take on the appearance of [target_visible_name]"
	if(target.job)
		disguise_message += ", the [target.job]"
	disguise_message += "! Attacking, putting anything in your hands or changing your clothing will break the disguise."
	
	to_chat(user, "<span class='notice'>[disguise_message]</span>")

/obj/effect/proc_holder/spell/self/magical_disguise/proc/remove_disguise(mob/living/carbon/human/user)
	if(!disguise_active || !stored_appearance)
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
	
	// Restore name_override
	user.name_override = stored_appearance.original_name_override
	
	// Restore job if it was changed
	if(stored_appearance.original_job)
		user.job = stored_appearance.original_job
	
	// Restore original obscured flags
	user.obscured_flags = stored_appearance.original_obscured_flags
	
	// Make sure we update the user's appearance to reflect the restored obscured flags
	user.update_hair()
	user.update_body()
	
	// Force complete icon regeneration to ensure original appearance is fully restored
	user.regenerate_icons()
	
	// Remove the target species name trait
	REMOVE_TRAIT(user, TRAIT_DISGUISED_SPECIES, MAGICAL_DISGUISE_TRAIT)
	
	// Remove the disguise active trait
	REMOVE_TRAIT(user, TRAIT_DISGUISE_ACTIVE, MAGICAL_DISGUISE_TRAIT)
	
	// Remove the break disguise verb
	user.verbs -= /mob/proc/break_magical_disguise
	
	// Get the component and restore original descriptors
	var/datum/component/disguised_species/DS = user.GetComponent(/datum/component/disguised_species)
	if(DS)
		// Restore original descriptors
		user.clear_mob_descriptors()
		var/list/original_descriptors = DS.get_original_descriptors()
		if(length(original_descriptors))
			user.mob_descriptors = original_descriptors.Copy()
		
		// Remove the component
		qdel(DS)
	
	// Clear stored data
	snapshot = null
	stored_appearance = null
	current_target = null
	original_held_items.Cut()
	disguise_active = FALSE
	
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	to_chat(user, "<span class='warning'>Your magical disguise wears off!</span>")

// Add a new verb that humans can use to break their disguise voluntarily
/mob/proc/break_magical_disguise()
	set name = "Break Disguise"
	set desc = "Voluntarily break your magical disguise."
	set category = "Abilities"
	
	// Find any active magical disguise spell
	for(var/obj/effect/proc_holder/spell/self/magical_disguise/spell in src.mind.spell_list)
		if(spell.disguise_active)
			to_chat(src, "<span class='notice'>You dispel your magical disguise.</span>")
			spell.remove_disguise(src)
			return
	
	to_chat(src, "<span class='warning'>You don't have an active disguise to break!</span>")

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
			break_disguise_effect("Attempting to attack breaks your magical disguise!")
			return ..()
	
	return ..()

/mob/living/carbon/human/proc/break_disguise_effect(message = "Your actions have broken your magical disguise!")
	to_chat(src, "<span class='warning'>[message]</span>")
	playsound(get_turf(src), 'sound/magic/swap.ogg', 50, TRUE)
	
	// Visual effect to indicate the disguise breaking
	var/datum/effect_system/spark_spread/sparks = new
	sparks.set_up(5, 0, src)
	sparks.attach(src)
	sparks.start()
	
	// Find and remove the disguise
	for(var/obj/effect/proc_holder/spell/self/magical_disguise/spell in src.mind.spell_list)
		if(spell.disguise_active)
			spell.remove_disguise(src)
			break

// Hook into item equipping/unequipping
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial = FALSE, redraw_mob = FALSE, silent = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !initial && !silent)
		break_disguise_effect("Equipping an item breaks your magical disguise!")
	
	. = ..()

/mob/living/carbon/human/doUnEquip(obj/item/I, force, newloc, no_move, invdrop = TRUE, silent = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !silent)
		break_disguise_effect("Unequipping an item breaks your magical disguise!")
	
	. = ..()

// Override put_in_hands to detect when items are placed in hands
/mob/living/carbon/human/put_in_hands(obj/item/I, del_on_fail = FALSE, merge_stacks = TRUE, forced = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !forced && !istype(I, /obj/item/clothing/head/mob_holder))
		break_disguise_effect("Holding an item breaks your magical disguise!")
	
	. = ..()

// Also override put_in_hand_check which gets called before put_in_hands in some cases
/mob/living/carbon/human/put_in_hand_check(obj/item/I, hand_index, forced = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !forced && !istype(I, /obj/item/clothing/head/mob_holder))
		break_disguise_effect("Holding an item breaks your magical disguise!")
	
	. = ..()

// Override put_in_active_hand and put_in_inactive_hand specifically
/mob/living/carbon/human/put_in_active_hand(obj/item/I, forced = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !forced && !istype(I, /obj/item/clothing/head/mob_holder))
		break_disguise_effect("Holding an item breaks your magical disguise!")
	
	. = ..()

/mob/living/carbon/human/put_in_inactive_hand(obj/item/I, forced = FALSE)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && !forced && !istype(I, /obj/item/clothing/head/mob_holder))
		break_disguise_effect("Holding an item breaks your magical disguise!")
	
	. = ..()

// Instead of pickup, override attack_hand for items which is called when picking up items
/mob/living/carbon/human/attack_hand(atom/movable/AM)
	if(HAS_TRAIT(src, TRAIT_DISGUISE_ACTIVE) && isitem(AM))
		break_disguise_effect("Picking up an item breaks your magical disguise!")
	
	. = ..()

// Simplified helper datum to store original appearance information
/datum/disguise_info
	var/real_name
	var/name
	var/gender
	var/original_job
	var/target_species_name
	var/icon/original_icon
	var/original_icon_state
	var/list/original_overlays
	var/original_obscured_flags
	var/disguised_as_unknown = FALSE
	var/target_visible_name
	var/original_name_override

	// Constructor stores the original properties
	New(mob/living/carbon/human/H)
		src.real_name = H.real_name
		src.name = H.name
		src.gender = H.gender
		src.original_name_override = H.name_override

// The component to store species and descriptor info
/datum/component/disguised_species
	var/species_name
	var/list/original_descriptors
	var/list/disguised_descriptors
	var/list/disguised_equipment  // List to store visible equipment info
	var/is_face_hidden = FALSE
	var/visible_name = null

/datum/component/disguised_species/Initialize(species_name, list/disguised_descriptors, list/original_descriptors, list/disguised_equipment, is_face_hidden = FALSE, visible_name = null)
	src.species_name = species_name
	src.disguised_descriptors = disguised_descriptors
	src.original_descriptors = original_descriptors
	src.disguised_equipment = disguised_equipment
	src.is_face_hidden = is_face_hidden
	src.visible_name = visible_name
	
/datum/component/disguised_species/proc/get_species_name()
	return species_name

/datum/component/disguised_species/proc/get_descriptors()
	return disguised_descriptors

/datum/component/disguised_species/proc/get_original_descriptors()
	return original_descriptors

/datum/component/disguised_species/proc/get_disguised_equipment()
	return disguised_equipment

/datum/component/disguised_species/proc/is_identity_concealed()
	return is_face_hidden

/datum/component/disguised_species/proc/get_visible_name()
	return visible_name

// Helper function to capture visible equipment from the target
/obj/effect/proc_holder/spell/self/magical_disguise/proc/capture_visible_equipment(mob/living/carbon/human/target)
	var/list/equipment_data = list()
	
	// Check each equipment slot that would be visible during examination
	if(target.wear_shirt)
		equipment_data["wear_shirt"] = list(
			"name" = target.wear_shirt.name,
			"desc" = target.wear_shirt.desc,
			"icon_state" = target.wear_shirt.icon_state
		)
	
	if(target.wear_armor)
		equipment_data["wear_armor"] = list(
			"name" = target.wear_armor.name,
			"desc" = target.wear_armor.desc,
			"icon_state" = target.wear_armor.icon_state
		)
	
	if(target.wear_pants)
		equipment_data["wear_pants"] = list(
			"name" = target.wear_pants.name,
			"desc" = target.wear_pants.desc,
			"icon_state" = target.wear_pants.icon_state
		)
	
	if(target.head)
		equipment_data["head"] = list(
			"name" = target.head.name,
			"desc" = target.head.desc,
			"icon_state" = target.head.icon_state
		)
	
	if(target.belt)
		equipment_data["belt"] = list(
			"name" = target.belt.name,
			"desc" = target.belt.desc,
			"icon_state" = target.belt.icon_state
		)
	
	if(target.beltr)
		equipment_data["beltr"] = list(
			"name" = target.beltr.name,
			"desc" = target.beltr.desc,
			"icon_state" = target.beltr.icon_state
		)
	
	if(target.beltl)
		equipment_data["beltl"] = list(
			"name" = target.beltl.name,
			"desc" = target.beltl.desc,
			"icon_state" = target.beltl.icon_state
		)
	
	if(target.wear_ring)
		equipment_data["wear_ring"] = list(
			"name" = target.wear_ring.name,
			"desc" = target.wear_ring.desc,
			"icon_state" = target.wear_ring.icon_state
		)
	
	if(target.gloves)
		equipment_data["gloves"] = list(
			"name" = target.gloves.name,
			"desc" = target.gloves.desc,
			"icon_state" = target.gloves.icon_state
		)
	
	if(target.wear_wrists)
		equipment_data["wear_wrists"] = list(
			"name" = target.wear_wrists.name,
			"desc" = target.wear_wrists.desc,
			"icon_state" = target.wear_wrists.icon_state
		)
	
	if(target.backr)
		equipment_data["backr"] = list(
			"name" = target.backr.name,
			"desc" = target.backr.desc,
			"icon_state" = target.backr.icon_state
		)
	
	if(target.backl)
		equipment_data["backl"] = list(
			"name" = target.backl.name,
			"desc" = target.backl.desc,
			"icon_state" = target.backl.icon_state
		)
	
	if(target.cloak)
		equipment_data["cloak"] = list(
			"name" = target.cloak.name,
			"desc" = target.cloak.desc,
			"icon_state" = target.cloak.icon_state
		)
	
	if(target.shoes)
		equipment_data["shoes"] = list(
			"name" = target.shoes.name,
			"desc" = target.shoes.desc,
			"icon_state" = target.shoes.icon_state
		)
	
	if(target.wear_mask)
		equipment_data["wear_mask"] = list(
			"name" = target.wear_mask.name,
			"desc" = target.wear_mask.desc,
			"icon_state" = target.wear_mask.icon_state
		)
	
	if(target.mouth)
		equipment_data["mouth"] = list(
			"name" = target.mouth.name,
			"desc" = target.mouth.desc,
			"icon_state" = target.mouth.icon_state
		)
	
	if(target.wear_neck)
		equipment_data["wear_neck"] = list(
			"name" = target.wear_neck.name,
			"desc" = target.wear_neck.desc,
			"icon_state" = target.wear_neck.icon_state
		)
	
	if(target.glasses)
		equipment_data["glasses"] = list(
			"name" = target.glasses.name,
			"desc" = target.glasses.desc,
			"icon_state" = target.glasses.icon_state
		)
	
	if(target.ears)
		equipment_data["ears"] = list(
			"name" = target.ears.name,
			"desc" = target.ears.desc,
			"icon_state" = target.ears.icon_state
		)

	// Also capture any items in the target's hands
	equipment_data["held_items"] = list()
	for(var/obj/item/I in target.held_items)
		if(!(I.item_flags & ABSTRACT))
			equipment_data["held_items"] += list(list(
				"name" = I.name,
				"desc" = I.desc,
				"icon_state" = I.icon_state,
				"held_index" = target.get_held_index_of_item(I),
				"held_name" = target.get_held_index_name(target.get_held_index_of_item(I))
			))
	
	return equipment_data
