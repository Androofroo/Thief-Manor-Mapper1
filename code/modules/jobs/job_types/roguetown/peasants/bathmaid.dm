/datum/job/roguetown/nightmaiden
	title = "Bathhouse Attendant"
	f_title = "Bathhouse Attendant"
	flag = WENCH
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 0
	spawn_positions = 0

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)

	tutorial = "Most would decry the humble bath attendant as a desperate fool tempting others into bedsheets for money--only sometimes, you say! You work under your Bathmaster in the communal bathhouse, keeping it and the guests in turn as tidy as they please. Wash laundry, tend mild wounds, and deftly wash your patrons with soap and a skilled 'caress', for this is your craft."

	outfit = /datum/outfit/job/roguetown/nightmaiden
	advclass_cat_rolls = list(CTAG_NIGHTMAIDEN = 20)
	display_order = JDO_WENCH
	give_bank_account = TRUE
	can_random = FALSE
	min_pq = -10
	max_pq = null
	round_contrib_points = 2
	advjob_examine = TRUE

/datum/job/roguetown/nightmaiden/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup") // Classes are for aesthetic clothing only, mechanically they're identical.

/datum/outfit/job/roguetown/nightmaiden
	name = "Bathhouse Attendant"
	// This is just a base outfit, the actual outfits are defined in the advclasses

/datum/advclass/nightmaiden
	name = "Bath Attendant"
	tutorial = "Most would decry the humble bath attendant as a desperate fool tempting others into bedsheets for money--only sometimes, you say! You work under your Bathmaster in the communal bathhouse, keeping it and the guests in turn as tidy as they please. Wash laundry, tend mild wounds, and deftly wash your patrons with soap and a skilled 'caress', for this is your craft."
	outfit = /datum/outfit/job/roguetown/nightmaiden/attendant
	category_tags = list(CTAG_NIGHTMAIDEN)

/datum/outfit/job/roguetown/nightmaiden/attendant/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/sandals
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	r_hand = /obj/item/soap/bath
	belt =	/obj/item/storage/belt/rogue/leather/cloth
	beltl = /obj/item/roguekey/nightmaiden
	if(should_wear_femme_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/sexy
		pants = /obj/item/clothing/under/roguetown/tights/stockings/fishnet/random //Added fishnet stockings to the wenches
	else if(should_wear_masc_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
		pants =	/obj/item/clothing/under/roguetown/loincloth
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/music, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 1, TRUE)

		H.change_stat("constitution", 1)
		H.change_stat("endurance", 2)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CICERONE, TRAIT_GENERIC)

/datum/advclass/nightmaiden/concubine
	name = "Concubine"
	tutorial = "Unlike your fellow bath attendants who maintain a professional facade, you have abandoned all pretense. You are a prized possession of the nobility, adorned in exotic silks and gold. Your role is to provide companionship, entertainment, and pleasure."
	outfit = /datum/outfit/job/roguetown/nightmaiden/concubine
	category_tags = list(CTAG_NIGHTMAIDEN)

/datum/outfit/job/roguetown/nightmaiden/concubine/pre_equip(mob/living/carbon/human/H)
	..()
	mask = /obj/item/clothing/mask/rogue/exoticsilkmask
	neck = /obj/item/clothing/neck/roguetown/collar
	belt = /obj/item/storage/belt/rogue/leather/exoticsilkbelt
	shoes = /obj/item/clothing/shoes/roguetown/anklets
	backl = /obj/item/storage/backpack/rogue/satchel
	shirt = /obj/item/clothing/suit/roguetown/shirt/exoticsilkbra
	pants = /obj/item/clothing/under/roguetown/tights/stockings/silk
	
	// Add items to the satchel
	backpack_contents = list(
		/obj/item/rope = 1,
		/obj/item/candle = 1,
		/obj/item/rogueweapon/whip = 1,
		/obj/item/clothing/mask/rogue/blindfold = 1,
		/obj/item/roguekey/nightmaiden = 1
	)
	
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/music, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/riding, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE)
		H.change_stat("constitution", 1)
		H.change_stat("endurance", 1)
		H.change_stat("speed", 1)
		H.change_stat("strength", 1)
	ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
	
	// Let the concubine choose an instrument
	var/weapons = list("Harp","Lute","Accordion","Guitar","Hurdy-Gurdy","Viola","Vocal Talisman","Flute")
	var/weapon_choice = input("Choose your instrument.", "TAKE UP ARMS") as anything in weapons
	H.set_blindness(0)
	switch(weapon_choice)
		if("Harp")
			backr = /obj/item/rogue/instrument/harp
		if("Lute")
			backr = /obj/item/rogue/instrument/lute
		if("Accordion")
			backr = /obj/item/rogue/instrument/accord
		if("Guitar")
			backr = /obj/item/rogue/instrument/guitar
		if("Hurdy-Gurdy")
			backr = /obj/item/rogue/instrument/hurdygurdy
		if("Viola")
			backr = /obj/item/rogue/instrument/viola
		if("Vocal Talisman")
			backr = /obj/item/rogue/instrument/vocals
		if("Flute")
			backr = /obj/item/rogue/instrument/flute

// Washing Implements

/obj/item/soap/bath
	name = "herbal soap"
	desc = "A soap made from various herbs"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "soap"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	item_flags = NOBLUDGEON

/obj/item/bath/soap/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 80)
