	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override, antag_override = FALSE)
	if(!pref_species)
		random_species()
	real_name = pref_species.random_name(gender,1)
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE,FEMALE)
	// Set voice type based on gender
	voice_type = gender == FEMALE ? VOICE_TYPE_FEM : VOICE_TYPE_MASC
	// Set pronouns based on gender
	pronouns = gender == FEMALE ? SHE_HER : HE_HIM
	age = AGE_ADULT
	var/list/skins = pref_species.get_skin_list()
	skin_tone = skins[pick(skins)]
	eye_color = random_eye_color()
	is_legacy = FALSE
	flavortext = null
	flavortext_display = null
	ooc_notes_display = null
	ooc_notes = null
	ooc_extra_link = null
	ooc_extra = null
	headshot_link = null
	features = pref_species.get_random_features()
	body_markings = pref_species.get_random_body_markings(features)
	accessory = "Nothing"
	reset_all_customizer_accessory_colors()
	randomize_all_customizer_accessories()

/datum/preferences/proc/random_species()
	var/random_species_type = GLOB.species_list[pick(get_selectable_species())]
	pref_species = new random_species_type
	if(randomise[RANDOM_NAME])
		real_name = pref_species.random_name(gender,1)
	set_new_race(new random_species_type)

/datum/preferences/proc/update_preview_icon()
	set waitfor = 0
	if(!parent)
		return
	if(parent.is_new_player())
		return
//	last_preview_update = world.time
	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highest_pref = 0
	for(var/job in job_preferences)
		if(job_preferences[job] > highest_pref)
			previewJob = SSjob.GetJob(job)
			highest_pref = job_preferences[job]

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = generate_or_wait_for_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)
	copy_to(mannequin, 1, TRUE, TRUE)

	if(previewJob)
		testing("previewjob")
		mannequin.job = previewJob.title
		previewJob.equip(mannequin, TRUE, preference_source = parent)
		
		// Check if this job has an advclass selected and if the job has advclass_cat_rolls
		if(job_advclasses && job_advclasses[previewJob.title] && previewJob.advclass_cat_rolls)
			var/selected_class_name = job_advclasses[previewJob.title]
			
			// Find the advclass in the appropriate categories
			var/datum/advclass/AC = null
			for(var/ctag in previewJob.advclass_cat_rolls)
				if(!SSrole_class_handler.sorted_class_categories[ctag])
					continue
					
				// Check each class in this category
				for(var/datum/advclass/potential_class in SSrole_class_handler.sorted_class_categories[ctag])
					if(potential_class.name == selected_class_name)
						AC = potential_class
						break
				
				if(AC) // If we found the class, no need to check more categories
					break
			
			// Apply the advclass if found and requirements are met
			if(AC && AC.check_requirements(pref_species))
				// Apply only the outfit portion of the advclass to the mannequin
				// without any stats, skills, or traits
				if(AC.outfit)
					// Create a temporary outfit instance to check which slots will be affected
					var/datum/outfit/O = new AC.outfit()
					var/list/slots_to_clear = list()
					
					// Identify which slots need to be cleared based on the outfit
					if(O.uniform || O.pants)
						slots_to_clear += mannequin.wear_pants
					if(O.suit || O.armor)
						slots_to_clear += mannequin.wear_armor
					if(O.back)
						slots_to_clear += mannequin.back
					if(O.belt)
						slots_to_clear += mannequin.belt
					if(O.gloves)
						slots_to_clear += mannequin.gloves
					if(O.shoes)
						slots_to_clear += mannequin.shoes
					if(O.head)
						slots_to_clear += mannequin.head
					if(O.mask)
						slots_to_clear += mannequin.wear_mask
					if(O.neck)
						slots_to_clear += mannequin.wear_neck
					if(O.ears)
						slots_to_clear += mannequin.ears
					if(O.glasses)
						slots_to_clear += mannequin.glasses
					if(O.id)
						slots_to_clear += mannequin.wear_ring
					if(O.wrists)
						slots_to_clear += mannequin.wear_wrists
					if(O.suit_store)
						slots_to_clear += mannequin.s_store
					if(O.cloak)
						slots_to_clear += mannequin.cloak
					if(O.beltl)
						slots_to_clear += mannequin.beltl
					if(O.beltr)
						slots_to_clear += mannequin.beltr
					if(O.backr)
						slots_to_clear += mannequin.backr
					if(O.backl)
						slots_to_clear += mannequin.backl
					if(O.mouth)
						slots_to_clear += mannequin.mouth
					if(O.shirt)
						slots_to_clear += mannequin.wear_shirt
						
					// Remove only items in slots that will be replaced
					for(var/obj/item/I in slots_to_clear)
						if(I)
							qdel(I)
							
					// Clean up the temporary outfit reference
					qdel(O)
					
					// Apply only the outfit portion without running post_equip
					mannequin.equipOutfit(AC.outfit)
					
				// Set the advjob name for display purposes only - no stats or skills
				mannequin.advjob = AC.name

	mannequin.rebuild_obscured_flags()
	COMPILE_OVERLAYS(mannequin)
	parent.show_character_previews(new /mutable_appearance(mannequin))
	unset_busy_human_dummy(DUMMY_HUMAN_SLOT_PREFERENCES)


/datum/preferences/proc/spec_check(mob/user)
	if(!istype(pref_species))
		return FALSE
	if(!(pref_species.name in get_selectable_species()))
		return FALSE
	if(!pref_species.check_roundstart_eligible())
		return FALSE
	if(user && (pref_species.patreon_req > user.patreonlevel()))
		return FALSE
	return TRUE

/mob/proc/patreonlevel()
	if(client)
		return client.patreonlevel()
