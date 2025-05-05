/datum/job/roguetown/knight
	title = "Knight" //Back to proper knights.
	flag = KNIGHT
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = NOBLE_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "The Knight is a noble warrior sworn to uphold justice and protect the manor's guests from danger.  \
				Though clad in heavy armor and bound by a strict code of honor, their presence alone is often enough to deter foul play."
	display_order = JDO_KNIGHT
	outfit = /datum/outfit/job/roguetown/knight
	advclass_cat_rolls = list(CTAG_ROYALGUARD = 20)

	give_bank_account = 22
	noble_income = 10
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_knight.ogg'

/datum/job/roguetown/knight/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/surcoat/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "knight's tabard ([index])"
		var/prev_real_name = H.real_name
		var/prev_name = H.name
		var/honorary = "Ser"
		if(should_wear_femme_clothes(H))
			honorary = "Dame"
		H.real_name = "[honorary] [prev_real_name]"
		H.name = "[honorary] [prev_name]"

		for(var/X in peopleknowme)
			for(var/datum/mind/MF in get_minds(X))
				if(MF.known_people)
					MF.known_people -= prev_real_name
					H.mind.person_knows_me(MF)

/datum/outfit/job/roguetown/knight/pre_equip(mob/living/carbon/human/H)
	..()
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)	
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_KNIGHTSMAN, TRAIT_GENERIC) 
	ADD_TRAIT(H, TRAIT_GOODTRAINER, TRAIT_GENERIC)

/datum/advclass/knight/valiant
	name = "Valiant Knight"
	tutorial = "You are the epitome of chivalry and honor, sworn to protect the Lord and uphold justice. Your heavy armor and shield make you an impenetrable wall against those who would do harm to the manor or its guests."
	outfit = /datum/outfit/job/roguetown/knight/valiant

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/valiant
	cloak = /obj/item/clothing/cloak/cape/knight
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/knight/valiant/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.change_stat("strength", 2)
	H.change_stat("constitution", 4)
	H.change_stat("endurance", 4)
	H.change_stat("intelligence", 1)

	// Basic backpack contents
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)
	
	// Handle weapon choices directly in pre_equip
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

/datum/outfit/job/roguetown/knight/valiant/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	var/helmchoice
	var/armorchoice
	
	// Define helmets list for reuse
	var/list/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"None"              = null
	)
	
	var/list/armors = list(
		"Full Plate"		= /obj/item/clothing/suit/roguetown/armor/plate,
		"Brigandine"		= /obj/item/clothing/suit/roguetown/armor/brigandine,
		"Coat of Plates"	= /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	)
	
	if(H.client)
		// Interactive selection for players with clients attached
		var/weapons = list("Longsword + Tower Shield", "Warhammer + Buckler", "Steel Mace + Wooden Shield")
		weapon_choice = timed_input_list(H, "Choose your weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
		
		// Helmet selection
		helmchoice = timed_input_list(H, "Choose your Helm within 30 seconds.", "TAKE UP HELMS", helmets, 30 SECONDS)
		if(!helmchoice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			var/list/helmet_keys = list()
			for(var/key in helmets)
				if(key != "None")
					helmet_keys += key
			helmchoice = pick(helmet_keys)
			to_chat(H, "<span class='warning'>Time's up! A helmet has been selected for you.</span>")
		
		// Armor selection
		armorchoice = timed_input_list(H, "Choose your armor within 30 seconds.", "TAKE UP ARMOR", armors, 30 SECONDS)
		if(!armorchoice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			armorchoice = pick(armors)
			to_chat(H, "<span class='warning'>Time's up! Armor has been selected for you.</span>")
	else
		// For knights with no client attached, use random selection
		var/list/weapons = list("Longsword + Tower Shield", "Warhammer + Buckler", "Steel Mace + Wooden Shield")
		weapon_choice = pick(weapons)
		
		// For non-client mode, select from keys
		var/list/helmet_keys = list()
		for(var/key in helmets)
			if(key != "None")
				helmet_keys += key
		helmchoice = pick(helmet_keys)
		
		var/list/armor_keys = list()
		for(var/key in armors)
			armor_keys += key
		armorchoice = pick(armor_keys)
	
	if(!weapon_choice)
		weapon_choice = "Longsword + Tower Shield" // Default if they cancel
		
	// Create the selected weapons
	var/obj/item/weapon_item
	var/obj/item/shield_item
	
	switch(weapon_choice)
		if("Longsword + Tower Shield")
			weapon_item = new /obj/item/rogueweapon/sword/long(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/tower/metal(get_turf(H))
		if("Warhammer + Buckler")
			weapon_item = new /obj/item/rogueweapon/mace/warhammer(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/buckler(get_turf(H))
		if("Steel Mace + Wooden Shield")
			weapon_item = new /obj/item/rogueweapon/mace/steel(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
	
	// Apply the chosen equipment
	if(!helmchoice)
		helmchoice = "None"
	
	var/helmet_type = helmets[helmchoice]
	
	if(helmet_type)
		var/obj/item/clothing/head/new_helmet = new helmet_type(get_turf(H))
		if(H.head)
			H.dropItemToGround(H.head)
		H.equip_to_slot_or_del(new_helmet, SLOT_HEAD)
	
	var/armor_type = armors[armorchoice]
	
	if(armor_type)
		var/obj/item/clothing/suit/new_armor = new armor_type(get_turf(H))
		if(H.wear_armor)
			H.dropItemToGround(H.wear_armor)
		H.equip_to_slot_or_del(new_armor, SLOT_ARMOR)
	
	// Equip the weapon and shield
	if(H.put_in_l_hand(weapon_item) || H.put_in_r_hand(weapon_item) || H.equip_to_slot_or_del(weapon_item, SLOT_BELT_L))
		to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [weapon_item], so it's on the ground.</span>")
	
	if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
		to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [shield_item], so it's on the ground.</span>")
		
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], honorable Valiant Knight!</span>")

/datum/advclass/knight/blackguard
	name = "Blackguard"
	tutorial = "You are a knight who has seen too much of the world's darkness. While still loyal to your lord, you have learned that sometimes the ends justify the means. Your combat style is brutal and efficient, favoring heavy weapons and intimidation."
	outfit = /datum/outfit/job/roguetown/knight/blackguard

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/blackguard
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	pants = /obj/item/clothing/under/roguetown/chainlegs
	cloak = /obj/item/clothing/cloak/cape/blkknight
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison
	armor = /obj/item/clothing/suit/roguetown/armor/plate

// This function is called after the outfit is equipped, for both players and mannequins
/datum/outfit/job/roguetown/knight/blackguard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	
	// Apply black coloring to all the armor pieces
	if(H.wear_armor)
		H.wear_armor.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_armor()
	if(H.wear_pants)
		H.wear_pants.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_pants()
	if(H.shoes)
		H.shoes.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_shoes()
	if(H.gloves)
		H.gloves.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_gloves()
	if(H.wear_wrists)
		H.wear_wrists.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_wrists()
	if(H.wear_neck)
		H.wear_neck.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_neck()
	if(H.wear_shirt)
		H.wear_shirt.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		H.update_inv_shirt()
	
	// Force a full update of the mob's appearance
	H.regenerate_icons()

/datum/outfit/job/roguetown/knight/blackguard/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.change_stat("strength", 4)
	H.change_stat("constitution", 3)
	H.change_stat("endurance", 2)
	H.change_stat("intelligence", 1)

	// Basic backpack contents
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)
	
	// Handle weapon choices directly in pre_equip
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

/datum/outfit/job/roguetown/knight/blackguard/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	var/helmchoice
	
	// Define helmets list for reuse
	var/list/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"None"              = null
	)
	
	if(H.client)
		// Interactive selection for players with clients attached
		var/weapons = list("Great Axe", "Zweihander", "Grand Mace")
		weapon_choice = timed_input_list(H, "Choose your weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
		
		// Helmet selection
		helmchoice = timed_input_list(H, "Choose your Helm within 30 seconds.", "TAKE UP HELMS", helmets, 30 SECONDS)
		if(!helmchoice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			var/list/helmet_keys = list()
			for(var/key in helmets)
				if(key != "None")
					helmet_keys += key
			helmchoice = pick(helmet_keys)
			to_chat(H, "<span class='warning'>Time's up! A helmet has been selected for you.</span>")
	else
		// For knights with no client attached, use random selection
		var/list/weapons = list("Great Axe", "Zweihander", "Morningstar")
		weapon_choice = pick(weapons)
		
		// For non-client mode, select from keys
		var/list/helmet_keys = list()
		for(var/key in helmets)
			if(key != "None")
				helmet_keys += key
		helmchoice = pick(helmet_keys)
	
	if(!weapon_choice)
		weapon_choice = "Zweihander" // Default if they cancel
		
	// Create the selected weapons
	var/obj/item/weapon_item
	var/obj/item/backpack_item
	
	switch(weapon_choice)
		if("Great Axe")
			weapon_item = new /obj/item/rogueweapon/greataxe/steel/doublehead(get_turf(H))
			backpack_item = new /obj/item/gwstrap(get_turf(H))
		if("Zweihander")
			weapon_item = new /obj/item/rogueweapon/greatsword/zwei(get_turf(H))
			backpack_item = new /obj/item/gwstrap(get_turf(H))
		if("Grand Mace")
			weapon_item = new /obj/item/rogueweapon/mace/goden/steel(get_turf(H))
			backpack_item = null
	
	// Process helmet choice
	if(!helmchoice)
		helmchoice = "Knight Helmet"
		
	var/helmet_type = helmets[helmchoice]
	
	// Apply the helmet if chosen
	if(helmet_type)
		var/obj/item/clothing/head/new_helmet = new helmet_type(get_turf(H))
		// Color the helmet black
		new_helmet.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY)
		
		if(H.head)
			H.dropItemToGround(H.head)
		H.equip_to_slot_or_del(new_helmet, SLOT_HEAD)
		H.update_inv_head()
	
	// Equip the weapon
	if(H.put_in_r_hand(weapon_item) || H.put_in_l_hand(weapon_item))
		to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [weapon_item], so it's on the ground.</span>")
	
	// Equip the gwstrap if needed - equip instantly
	if(backpack_item)
		H.equip_to_slot_or_del(backpack_item, SLOT_BACK_L)
		to_chat(H, "<span class='notice'>You equip \a [backpack_item] to carry your weapon when not in use.</span>")
		
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], fearsome Blackguard!</span>")

/datum/advclass/knight/templar
	name = "Templar"
	tutorial = "You are a holy warrior dedicated to eradicating magical threats and heresy. While loyal to your lord, you also hold deep respect for the Church of Psydon. Your combat style focuses on countering magical threats while maintaining traditional knightly virtues."
	outfit = /datum/outfit/job/roguetown/knight/templar

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/templar
	head = /obj/item/clothing/head/roguetown/helmet/heavy/psydonhelm
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	gloves = /obj/item/clothing/gloves/roguetown/chain/psydon
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	mask = /obj/item/clothing/head/roguetown/roguehood/psydon
	cloak = /obj/item/clothing/cloak/psydontabard
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/chainlegs
	armor = /obj/item/clothing/suit/roguetown/armor/plate/fluted/ornate
	id = /obj/item/scomstone/bad/garrison
	neck = /obj/item/clothing/neck/roguetown/bevor
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black

/datum/outfit/job/roguetown/knight/templar/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/lesser_heal)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_ANTIMAGIC, TRAIT_GENERIC)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.change_stat("strength", 3)
	H.change_stat("constitution", 2)
	H.change_stat("endurance", 2)
	H.change_stat("intelligence", 2)

	// Basic backpack contents
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)
	
	// Handle weapon choices directly in pre_equip
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

/datum/outfit/job/roguetown/knight/templar/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		// Interactive selection for players with clients attached
		var/weapons = list("Longsword + Kite Shield","Steel Mace + Buckler","Warhammer + Wooden Shield")
		weapon_choice = timed_input_list(H, "Choose your weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
	else
		// For knights with no client attached, use random selection
		var/list/weapons = list("Longsword + Kite Shield","Steel Mace + Buckler","Warhammer + Wooden Shield")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Longsword + Kite Shield" // Default if they cancel
		
	// Create the selected weapons
	var/obj/item/weapon_item
	var/obj/item/shield_item
	
	switch(weapon_choice)
		if("Longsword + Kite Shield")
			weapon_item = new /obj/item/rogueweapon/sword/long(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/tower/metal(get_turf(H))
		if("Steel Mace + Buckler")
			weapon_item = new /obj/item/rogueweapon/mace/steel(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/buckler(get_turf(H))
		if("Warhammer + Wooden Shield")
			weapon_item = new /obj/item/rogueweapon/mace/warhammer(get_turf(H))
			shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
	
	// Attempt to put items in the appropriate slots
	if(H.put_in_l_hand(weapon_item) || H.put_in_r_hand(weapon_item) || H.equip_to_slot_or_del(weapon_item, SLOT_BELT_L))
		to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [weapon_item], so it's on the ground.</span>")
	
	if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
		to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [shield_item], so it's on the ground.</span>")
		
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], blessed Templar of the Church!</span>")

/datum/advclass/knight/otavan
	name = "Foreign Knight"
	tutorial = "You are a noble knight from a foreign land, serving as both a dignitary and protector of the Lord. Your presence represents the diplomatic ties between your homeland and this realm, while your martial prowess ensures the safety of the manor's most important guests."
	outfit = /datum/outfit/job/roguetown/knight/otavan
	allowed_races = NON_DWARVEN_RACE_TYPES
	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/otavan
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	belt = /obj/item/storage/belt/rogue/leather
	beltr = /obj/item/storage/belt/rogue/pouch/coins/poor
	neck = /obj/item/clothing/neck/roguetown/fencerguard
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy/otavan
	head = /obj/item/clothing/head/roguetown/helmet/otavan
	armor = /obj/item/clothing/suit/roguetown/armor/plate/otavan
	pants = /obj/item/clothing/under/roguetown/heavy_leather_pants/otavan
	shoes = /obj/item/clothing/shoes/roguetown/boots/otavan
	gloves = /obj/item/clothing/gloves/roguetown/otavan
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/knight/otavan/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GOODTRAINER, TRAIT_GENERIC)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.change_stat("strength", 3)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 3)
	H.change_stat("intelligence", 2)
	H.change_stat("perception", 1)
	H.change_stat("speed", -1)

	// Grant the language
	H.grant_language(/datum/language/otavan)
	
	// Basic backpack contents
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)
	
	// Handle weapon choices directly in pre_equip
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

/datum/outfit/job/roguetown/knight/otavan/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/classchoice
	
	if(H.client)
		// Interactive selection for players with clients attached
		var/classes = list("Swordsman", "Macebearer", "Flailman")
		classchoice = timed_input_list(H, "Choose your archetype within 30 seconds.", "Available archetypes", classes, 30 SECONDS)
		if(!classchoice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			classchoice = pick(classes)
			to_chat(H, "<span class='warning'>Time's up! An archetype has been selected for you.</span>")
	else
		var/list/classes = list("Swordsman", "Macebearer", "Flailman")
		classchoice = pick(classes)
	
	// Create and equip the selected weapon and shield
	var/obj/item/weapon_item
	var/obj/item/shield_item = new /obj/item/rogueweapon/shield/tower/metal(get_turf(H))
	
	switch(classchoice)
		if("Swordsman")
			weapon_item = new /obj/item/rogueweapon/sword/long(get_turf(H))
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
		if("Macebearer")
			weapon_item = new /obj/item/rogueweapon/mace/steel/morningstar(get_turf(H))
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
		if("Flailman")
			weapon_item = new /obj/item/rogueweapon/flail/sflail(get_turf(H))
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
	
	// Equip the weapon and shield
	if(H.put_in_l_hand(weapon_item) || H.put_in_r_hand(weapon_item) || H.equip_to_slot_or_del(weapon_item, SLOT_BELT_L))
		to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [weapon_item], so it's on the ground.</span>")
	
	if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
		to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
	else
		to_chat(H, "<span class='warning'>You couldn't equip \a [shield_item], so it's on the ground.</span>")
		
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], noble Foreign Knight!</span>")
