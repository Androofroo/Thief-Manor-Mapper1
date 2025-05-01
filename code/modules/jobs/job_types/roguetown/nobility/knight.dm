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
	whitelist_req = TRUE
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
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
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

/datum/outfit/job/roguetown/knight
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	neck = /obj/item/clothing/neck/roguetown/bevor
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/steel
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison
	backpack_contents = list(/obj/item/storage/keyring/guardcastle = 1)

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

/datum/outfit/job/roguetown/knight/valiant/pre_equip(mob/living/carbon/human/H)
	..()
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
	H.change_stat("constitution", 3)
	H.change_stat("endurance", 3)
	H.change_stat("intelligence", 1)

	H.adjust_blindness(-3)
	var/weapons = list("Longsword + Tower Shield","Warhammer + Buckler","Steel Mace + Wooden Shield")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Longsword + Tower Shield")
			beltl = /obj/item/rogueweapon/sword/long
			backl = /obj/item/rogueweapon/shield/tower/metal
		if("Warhammer + Buckler")
			beltl = /obj/item/rogueweapon/mace/warhammer
			backl = /obj/item/rogueweapon/shield/buckler
		if("Steel Mace + Wooden Shield")
			beltl = /obj/item/rogueweapon/mace/steel
			backl = /obj/item/rogueweapon/shield/wood

	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	pants = /obj/item/clothing/under/roguetown/chainlegs

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Hounskull Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/pigface/hounskull,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	var/armors = list(
		"Full Plate"		= /obj/item/clothing/suit/roguetown/armor/plate,
		"Steel Cuirass"		= /obj/item/clothing/suit/roguetown/armor/plate/half,
		"Brigandine"		= /obj/item/clothing/suit/roguetown/armor/brigandine,
		"Coat of Plates"	= /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates,
	)
	var/armorchoice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors
	armor = armors[armorchoice]

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)

/datum/advclass/knight/blackguard
	name = "Blackguard"
	tutorial = "You are a knight who has seen too much of the world's darkness. While still loyal to your lord, you have learned that sometimes the ends justify the means. Your combat style is brutal and efficient, favoring heavy weapons and intimidation."
	outfit = /datum/outfit/job/roguetown/knight/blackguard

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/blackguard/pre_equip(mob/living/carbon/human/H)
	..()
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

	H.change_stat("strength", 3)
	H.change_stat("constitution", 2)
	H.change_stat("endurance", 2)
	H.change_stat("intelligence", 1)

	H.adjust_blindness(-3)
	var/weapons = list("Great Axe","Zweihander","Morningstar")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Great Axe")
			r_hand = /obj/item/rogueweapon/stoneaxe/battle
			backl = /obj/item/gwstrap
		if("Zweihander")
			r_hand = /obj/item/rogueweapon/greatsword/zwei
			backl = /obj/item/gwstrap
		if("Morningstar")
			r_hand = /obj/item/rogueweapon/mace/steel/morningstar

	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/iron
	pants = /obj/item/clothing/under/roguetown/chainlegs

	var/helmets = list(
		"Pigface Bascinet" 	= /obj/item/clothing/head/roguetown/helmet/bascinet/pigface,
		"Guard Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/guard,
		"Barred Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/sheriff,
		"Bucket Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/bucket,
		"Knight Helmet"		= /obj/item/clothing/head/roguetown/helmet/heavy/knight,
		"Visored Sallet"	= /obj/item/clothing/head/roguetown/helmet/sallet/visored,
		"Armet"				= /obj/item/clothing/head/roguetown/helmet/heavy/knight/armet,
		"Etruscan Bascinet" = /obj/item/clothing/head/roguetown/helmet/bascinet/etruscan,
		"None"
	)
	var/helmchoice = input("Choose your Helm.", "TAKE UP HELMS") as anything in helmets
	if(helmchoice != "None")
		head = helmets[helmchoice]

	var/armors = list(
		"Black Steel Cuirass"	= /obj/item/clothing/suit/roguetown/armor/plate/blacksteel_half_plate,
		"Brigandine"		= /obj/item/clothing/suit/roguetown/armor/brigandine,
		"Studded Leather"	= /obj/item/clothing/suit/roguetown/armor/leather/studded,
	)
	var/armorchoice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors
	armor = armors[armorchoice]

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)

/datum/outfit/job/roguetown/knight/blackguard/post_equip(mob/living/carbon/human/H)
	..()
	// Apply black color only to armor components
	if(H.head)
		H.head.add_atom_colour("#414143", FIXED_COLOUR_PRIORITY) // Black from the dyer
		H.update_inv_head()
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
	
	// Force a full update of the mob's appearance
	H.regenerate_icons()

/datum/advclass/knight/templar
	name = "Templar"
	tutorial = "You are a holy warrior dedicated to eradicating magical threats and heresy. While loyal to your lord, you also hold deep respect for the Church of Psydon. Your combat style focuses on countering magical threats while maintaining traditional knightly virtues."
	outfit = /datum/outfit/job/roguetown/knight/templar

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/templar/pre_equip(mob/living/carbon/human/H)
	..()
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
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_ANTIMAGIC, TRAIT_GENERIC)
	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	H.verbs |= /mob/proc/haltyell

	H.change_stat("strength", 2)
	H.change_stat("constitution", 2)
	H.change_stat("endurance", 2)
	H.change_stat("intelligence", 2)

	H.adjust_blindness(-3)
	var/weapons = list("Longsword + Kite Shield","Steel Mace + Buckler","Warhammer + Wooden Shield")
	var/weapon_choice = input("Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Longsword + Kite Shield")
			beltl = /obj/item/rogueweapon/sword/long
			backl = /obj/item/rogueweapon/shield/tower/metal
		if("Steel Mace + Buckler")
			beltl = /obj/item/rogueweapon/mace/steel
			backl = /obj/item/rogueweapon/shield/buckler
		if("Warhammer + Wooden Shield")
			beltl = /obj/item/rogueweapon/mace/warhammer
			backl = /obj/item/rogueweapon/shield/wood

	head = /obj/item/clothing/head/roguetown/helmet/heavy/psydonhelm
	shoes = /obj/item/clothing/shoes/roguetown/boots/psydonboots
	gloves = /obj/item/clothing/gloves/roguetown/chain/psydon
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	mask = /obj/item/clothing/head/roguetown/roguehood/psydon
	cloak = /obj/item/clothing/cloak/psydontabard
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	pants = /obj/item/clothing/under/roguetown/chainlegs

	var/armors = list(
		"Psydonite Hauberk"		= /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk/ornate,
		"Coat of Plates"	= /obj/item/clothing/suit/roguetown/armor/brigandine/coatplates
	)
	var/armorchoice = input("Choose your armor.", "TAKE UP ARMOR") as anything in armors
	armor = armors[armorchoice]

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)

/datum/advclass/knight/otavan
	name = "Foreign Knight"
	tutorial = "You are a noble knight from a foreign land, serving as both a dignitary and protector of the Lord. Your presence represents the diplomatic ties between your homeland and this realm, while your martial prowess ensures the safety of the manor's most important guests."
	outfit = /datum/outfit/job/roguetown/knight/otavan

	category_tags = list(CTAG_ROYALGUARD)

/datum/outfit/job/roguetown/knight/otavan/pre_equip(mob/living/carbon/human/H)
	..()
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

	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 3)
	H.change_stat("intelligence", 2)
	H.change_stat("perception", 1)
	H.change_stat("speed", -1)

	H.adjust_blindness(-3)
	var/classes = list("Swordsman","Macebearer","Flailman")
	var/classchoice = input("Choose your archetype", "Available archetypes") as anything in classes
	H.set_blindness(0)
	switch(classchoice)
		if("Swordsman")
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			beltl = /obj/item/rogueweapon/sword/long
			backl = /obj/item/rogueweapon/shield/tower/metal
		if("Macebearer")
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
			beltl = /obj/item/rogueweapon/mace/steel/morningstar
			backl = /obj/item/rogueweapon/shield/tower/metal
		if("Flailman")
			H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
			beltl = /obj/item/rogueweapon/flail/sflail
			backl = /obj/item/rogueweapon/shield/tower/metal

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
	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/royal = 1)

	H.grant_language(/datum/language/otavan)
