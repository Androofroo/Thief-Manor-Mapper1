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
	ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC) // Knowledge of the manor layout
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
	invocation = "I AM NOT WHO I APPEAR TO BE!"
	invocation_type = "shout"
	action_icon_state = "thief"
	
	var/datum/disguise_info/stored_appearance
	var/mob/living/carbon/human/current_target
	var/disguise_duration = 2400 // 4 minutes
	var/disguise_active = FALSE
	var/datum/icon_snapshot/snapshot   // Snapshot of target's appearance

/obj/effect/proc_holder/spell/self/magical_disguise/cast(list/targets, mob/living/carbon/human/user)
	if(disguise_active)
		remove_disguise(user)
		return
		
	var/list/mob/living/carbon/human/targets_in_range = list()
	for(var/mob/living/carbon/human/H in view(7, user))
		if(H != user)
			targets_in_range += H
			
	if(!targets_in_range.len)
		to_chat(user, "<span class='warning'>No valid targets found!</span>")
		return
		
	var/mob/living/carbon/human/selected_target = input("Select a target to disguise as.", "Disguise Target") as null|anything in targets_in_range
	if(!selected_target || QDELETED(selected_target) || selected_target == user || !(selected_target in view(7, user)))
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
	
	// Basic identity information
	user.real_name = target.real_name
	user.name = target.name
	
	// Copy job if available
	if(target.job)
		stored_appearance.original_job = user.job
		user.job = target.job
	
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
		
		// Use a component to store the species name, descriptors, and equipment
		user.AddComponent(/datum/component/disguised_species, target.dna.species.name, target_descriptors, original_descriptors, equipment_data)
		
		// Replace the user's descriptors with the target's
		user.clear_mob_descriptors()
		if(length(target_descriptors))
			user.mob_descriptors = target_descriptors.Copy()
	
	// Copy gender for consistency
	user.gender = target.gender
	
	// Store the flags for hair/face visibility to ensure proper hiding with helmets
	if(target.head)
		stored_appearance.target_head_flags = target.head.flags_inv
		// If the target is wearing a helmet that hides things, we should simulate those being hidden
		if(target.head.flags_inv & HIDEHAIR)
			stored_appearance.original_hair = user.hairstyle
			stored_appearance.original_hair_color = user.hair_color
			user.hairstyle = "Bald"
			// No need to change the color as it won't be visible
		
		if(target.head.flags_inv & HIDEFACE)
			stored_appearance.original_face = user.facial_hairstyle
			stored_appearance.original_face_color = user.facial_hair_color
			user.facial_hairstyle = "Shaved"
			// No need to change the color as it won't be visible
		
		// Update the user's appearance to apply the hair changes
		user.update_hair()
		user.update_body()
	
	// Apply the visual snapshot to the user
	user.icon = snapshot.icon
	user.icon_state = snapshot.icon_state
	user.cut_overlays()
	for(var/overlay in snapshot.overlays)
		user.add_overlay(overlay)
	
	// Set a timer to remove the disguise
	addtimer(CALLBACK(src, PROC_REF(remove_disguise), user), disguise_duration)
	
	disguise_active = TRUE
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	to_chat(user, "<span class='notice'>You take on the appearance of [target.real_name]!</span>")

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
	
	// Restore job if it was changed
	if(stored_appearance.original_job)
		user.job = stored_appearance.original_job
	
	// Restore hair and facial hair if they were changed
	if(stored_appearance.original_hair)
		user.hairstyle = stored_appearance.original_hair
	
	if(stored_appearance.original_hair_color)
		user.hair_color = stored_appearance.original_hair_color
	
	if(stored_appearance.original_face)
		user.facial_hairstyle = stored_appearance.original_face
	
	if(stored_appearance.original_face_color)
		user.facial_hair_color = stored_appearance.original_face_color
	
	// Make sure we update the user's appearance to show restored hair
	user.update_hair()
	user.update_body()
	
	// Remove the target species name trait
	REMOVE_TRAIT(user, TRAIT_DISGUISED_SPECIES, MAGICAL_DISGUISE_TRAIT)
	
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
	disguise_active = FALSE
	
	playsound(get_turf(user), 'sound/magic/swap.ogg', 50, TRUE)
	to_chat(user, "<span class='warning'>Your magical disguise wears off!</span>")

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
	var/target_head_flags    // Flags for target's helmet/head item
	var/original_hair        // Original hair style
	var/original_hair_color  // Original hair color
	var/original_face        // Original facial hair style  
	var/original_face_color  // Original facial hair color
	
	// Constructor stores the original properties
	New(mob/living/carbon/human/H)
		src.real_name = H.real_name
		src.name = H.name
		src.gender = H.gender

// Define a component for storing the disguised species name and descriptors
/datum/component/disguised_species
	var/species_name
	var/list/original_descriptors
	var/list/disguised_descriptors
	var/list/disguised_equipment  // List to store visible equipment info

/datum/component/disguised_species/Initialize(species_name, list/disguised_descriptors, list/original_descriptors, list/disguised_equipment)
	src.species_name = species_name
	src.disguised_descriptors = disguised_descriptors
	src.original_descriptors = original_descriptors
	src.disguised_equipment = disguised_equipment
	
/datum/component/disguised_species/proc/get_species_name()
	return species_name

/datum/component/disguised_species/proc/get_descriptors()
	return disguised_descriptors

/datum/component/disguised_species/proc/get_original_descriptors()
	return original_descriptors

/datum/component/disguised_species/proc/get_disguised_equipment()
	return disguised_equipment

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
