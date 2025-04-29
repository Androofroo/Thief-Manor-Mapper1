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

	if(outfit)
		// Create a temporary outfit instance to check which slots will be affected
		var/datum/outfit/O = new outfit()
		var/list/slots_to_clear = list()
		
		// Identify which slots need to be cleared based on the outfit
		if(O.uniform || O.pants)
			slots_to_clear += H.wear_pants
		if(O.suit || O.armor)
			slots_to_clear += H.wear_armor
		if(O.back)
			slots_to_clear += H.back
		if(O.belt)
			slots_to_clear += H.belt
		if(O.gloves)
			slots_to_clear += H.gloves
		if(O.shoes)
			slots_to_clear += H.shoes
		if(O.head)
			slots_to_clear += H.head
		if(O.mask)
			slots_to_clear += H.wear_mask
		if(O.neck)
			slots_to_clear += H.wear_neck
		if(O.ears)
			slots_to_clear += H.ears
		if(O.glasses)
			slots_to_clear += H.glasses
		if(O.id)
			slots_to_clear += H.wear_ring
		if(O.wrists)
			slots_to_clear += H.wear_wrists
		if(O.suit_store)
			slots_to_clear += H.s_store
		if(O.cloak)
			slots_to_clear += H.cloak
		if(O.beltl)
			slots_to_clear += H.beltl
		if(O.beltr)
			slots_to_clear += H.beltr
		if(O.backr)
			slots_to_clear += H.backr
		if(O.backl)
			slots_to_clear += H.backl
		if(O.mouth)
			slots_to_clear += H.mouth
		if(O.shirt)
			slots_to_clear += H.wear_shirt
			
		// Remove only items in slots that will be replaced
		for(var/obj/item/I in slots_to_clear)
			if(I)
				qdel(I)
				
		// Clear hands if outfit specifies hand items
		if(O.r_hand || O.l_hand)
			H.drop_all_held_items()
			
		// Clean up the temporary outfit
		qdel(O)
		
		// Apply the outfit
		H.equipOutfit(outfit)
	
	post_equip(H)

	H.advjob = name

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

/datum/advclass/proc/post_equip(mob/living/carbon/human/H)
	addtimer(CALLBACK(H,TYPE_PROC_REF(/mob/living/carbon/human, add_credit), TRUE), 20)
	if(cmode_music)
		H.cmode_music = cmode_music

/*
	Whoa! we are checking requirements here!
	On the datum! Wow!
*/
/datum/advclass/proc/check_requirements(mob/living/carbon/human/H)

	var/datum/species/pref_species = H.dna.species
	var/list/local_allowed_sexes = list()
	if(length(allowed_sexes))
		local_allowed_sexes |= allowed_sexes
	if(!immune_to_genderswap && pref_species?.gender_swapping)
		if(MALE in allowed_sexes)
			local_allowed_sexes -= MALE
			local_allowed_sexes += FEMALE
		if(FEMALE in allowed_sexes)
			local_allowed_sexes -= FEMALE
			local_allowed_sexes += MALE
	if(length(local_allowed_sexes) && !(H.gender in local_allowed_sexes))
		return FALSE

	if(length(allowed_races) && !(H.dna.species.type in allowed_races))
		return FALSE

	if(length(allowed_ages) && !(H.age in allowed_ages))
		return FALSE

	if(length(allowed_patrons) && !(H.patron in allowed_patrons))
		return FALSE

	if(maximum_possible_slots > -1)
		if(total_slots_occupied >= maximum_possible_slots)
			return FALSE

	if(min_pq != -100) // If someone sets this we actually do the check.
		if(!(get_playerquality(H.client.ckey) >= min_pq))
			return FALSE

	if(prob(pickprob))
		return TRUE

// Basically the handler has a chance to plus up a class, heres a generic proc you can override to handle behavior related to it.
// For now you just get an extra stat in everything depending on how many plusses you managed to get.
/datum/advclass/proc/boost_by_plus_power(plus_factor, mob/living/carbon/human/H)
	for(var/S in MOBSTATS)
		H.change_stat(S, plus_factor)


//Final proc in the set for really silly shit
///datum/advclass/proc/extra_slop_proc_ending(mob/living/carbon/human/H)

