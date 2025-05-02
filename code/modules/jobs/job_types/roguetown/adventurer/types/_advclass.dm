/datum/advclass
	var/name
	var/list/classes
	var/outfit
	var/tutorial = "Choose me!"
	var/list/allowed_sexes
	var/list/allowed_races = RACES_ALL_KINDS
	var/list/allowed_patrons
	var/list/allowed_ages
	var/pickprob = 100
	var/maximum_possible_slots = -1
	var/total_slots_occupied = 0
	var/min_pq = -100

	var/horse = FALSE
	var/vampcompat = TRUE
	var/list/traits_applied
	var/cmode_music

	var/noble_income = FALSE //Passive income every day from noble estate

	/// This class is immune to species-based swapped gender locks
	var/immune_to_genderswap = FALSE

	//What categories we are going to sort it in
	var/list/category_tags = list(CTAG_DISABLED)

/datum/advclass/proc/equipme(mob/living/carbon/human/H)
	// input sleeps....
	set waitfor = FALSE
	if(!H)
		return FALSE

	// Check if this is a preview mannequin
	var/is_preview_mannequin = istype(H, /mob/living/carbon/human/dummy)

	if(outfit)
		H.equipOutfit(outfit)
	
	// Only apply stat changes, traits, etc. if this is NOT a preview mannequin
	if(!is_preview_mannequin && H.mind)
		var/turf/TU = get_turf(H)
		if(TU)
			if(horse)
				new horse(TU)

		for(var/trait in traits_applied)
			ADD_TRAIT(H, trait, ADVENTURER_TRAIT)

		if(noble_income)
			SStreasury.noble_incomes[H] = noble_income

		// After the end of adv class equipping, apply a SPECIAL trait if able
		apply_character_post_equipment(H)
		
		post_equip(H)

	H.advjob = name
	return TRUE

/datum/advclass/proc/post_equip(mob/living/carbon/human/H)
	addtimer(CALLBACK(H,TYPE_PROC_REF(/mob/living/carbon/human, add_credit), TRUE), 20)
	if(cmode_music)
		H.cmode_music = cmode_music

/*
	Whoa! we are checking requirements here!
	On the datum! Wow!
*/
/datum/advclass/proc/check_requirements(arg)
	var/datum/species/pref_species
	var/gender
	var/age
	var/datum/patron/patron
	var/client/client
	
	// Check if we were given a mob or just a species
	if(istype(arg, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = arg
		pref_species = H.dna.species
		gender = H.gender
		age = H.age
		patron = H.patron
		client = H.client
	else if(istype(arg, /datum/species))
		// We were just given a species datum directly from preferences
		pref_species = arg
		// Use default values since we don't have a mob
		gender = MALE
		age = AGE_ADULT
		
		// If we're coming from preferences UI, grab the client reference
		// and relevant preference values
		if(usr && usr.client && usr.client.prefs)
			gender = usr.client.prefs.gender
			age = usr.client.prefs.age
			patron = usr.client.prefs.selected_patron
			client = usr.client
	else
		// We weren't given a valid argument
		return FALSE
	
	// Now do the actual checks
	var/list/local_allowed_sexes = list()
	if(length(allowed_sexes))
		local_allowed_sexes |= allowed_sexes
		
	// Check gender swapping for species, safely
	if(!immune_to_genderswap && pref_species?.gender_swapping)
		if(MALE in allowed_sexes)
			local_allowed_sexes -= MALE
			local_allowed_sexes += FEMALE
		if(FEMALE in allowed_sexes)
			local_allowed_sexes -= FEMALE
			local_allowed_sexes += MALE
			
	// Only check gender if allowed_sexes is specified
	if(length(local_allowed_sexes) && !(gender in local_allowed_sexes))
		return FALSE

	// Only check race if allowed_races is specified
	if(length(allowed_races) && pref_species && !(pref_species.type in allowed_races))
		return FALSE

	// Only check age if allowed_ages is specified
	if(length(allowed_ages) && !(age in allowed_ages))
		return FALSE

	// Only check patron if allowed_patrons is specified and patron exists
	if(length(allowed_patrons) && patron)
		if(!(patron.type in allowed_patrons))
			return FALSE

	if(maximum_possible_slots > -1)
		if(total_slots_occupied >= maximum_possible_slots)
			return FALSE

	// Only check PQ if min_pq is set and client exists
	if(min_pq != -100 && client)
		if(!(get_playerquality(client.ckey) >= min_pq))
			return FALSE

	if(prob(pickprob))
		return TRUE
	
	return FALSE

// Basically the handler has a chance to plus up a class, heres a generic proc you can override to handle behavior related to it.
// For now you just get an extra stat in everything depending on how many plusses you managed to get.
/datum/advclass/proc/boost_by_plus_power(plus_factor, mob/living/carbon/human/H)
	for(var/S in MOBSTATS)
		H.change_stat(S, plus_factor)


//Final proc in the set for really silly shit
///datum/advclass/proc/extra_slop_proc_ending(mob/living/carbon/human/H)

