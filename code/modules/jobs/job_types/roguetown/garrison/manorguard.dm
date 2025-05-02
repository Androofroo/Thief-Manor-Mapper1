/datum/job/roguetown/manorguard
	title = "Manor Guard"
	flag = MANATARMS
	department_flag = GARRISON
	faction = "Station"
	total_positions = 3
	spawn_positions = 3

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED)
	tutorial = "Having proven yourself loyal and capable, you are entrusted to defend the manor. \
				Trained regularly in combat and siege warfare, you deal with threats - both within and without. \
				Obey your Lord and Knight. Show the nobles and knights your respect, so that you may earn it in turn. Not as a commoner, but as a soldier.."
	display_order = JDO_CASTLEGUARD
	
	outfit = /datum/outfit/job/roguetown/manorguard
	advclass_cat_rolls = list(CTAG_MENATARMS = 20)

	give_bank_account = 22
	min_pq = 0
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_guard2.ogg'

/datum/job/roguetown/manorguard/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(istype(H.cloak, /obj/item/clothing/cloak/stabard/surcoat/guard))
			var/obj/item/clothing/S = H.cloak
			var/index = findtext(H.real_name, " ")
			if(index)
				index = copytext(H.real_name, 1,index)
			if(!index)
				index = H.real_name
			S.name = "man-at-arms jupon ([index])"

/datum/outfit/job/roguetown/manorguard
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

// Melee goon
/datum/advclass/manorguard/footsman
	name = "Footman"
	tutorial = "You are a professional soldier of the realm, specializing in melee warfare. Stalwart and hardy, your body can both withstand and dish out powerful strikes.."
	outfit = /datum/outfit/job/roguetown/manorguard/footsman

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/footsman
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/sallet
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/gorget

/datum/outfit/job/roguetown/manorguard/footsman/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/slings, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 1, TRUE)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC) //+1 spd, con, end, +2 per in town
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	H.change_stat("strength", 2) // seems kinda lame but remember guardsman bonus!!
	H.change_stat("intelligence", 1)
	H.change_stat("constitution", 1)
	H.change_stat("endurance", 1)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 5)

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/footsman/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		H.adjust_blindness(-3)
		var/weapons = list("Warhammer & Shield","Axe & Shield","Halberd")
		weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as null|anything in weapons
		H.set_blindness(0)
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Warhammer & Shield","Axe & Shield","Halberd")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Warhammer & Shield" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Warhammer & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace/warhammer(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
			
			if(H.equip_to_slot_if_possible(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_if_possible(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
		
		if("Axe & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/stoneaxe/woodcut/steel(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
			
			if(H.equip_to_slot_if_possible(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_if_possible(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
		
		if("Halberd")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/halberd(get_turf(H))
			var/obj/item/gwstrap_item = new /obj/item/gwstrap(get_turf(H))
			
			if(H.put_in_r_hand(weapon_item) || H.put_in_l_hand(weapon_item))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_if_possible(gwstrap_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [gwstrap_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], valiant Footman of the Manor!</span>")

// Ranged weapons and daggers on the side - lighter armor, but fleet!
/datum/advclass/manorguard/skirmisher
	name = "Skirmisher"
	tutorial = "You are a professional soldier of the realm, specializing in ranged implements. You sport a keen eye, looking for your enemies weaknesses."
	outfit = /datum/outfit/job/roguetown/manorguard/skirmisher

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/skirmisher
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	pants = /obj/item/clothing/under/roguetown/trou/leather

/datum/outfit/job/roguetown/manorguard/skirmisher/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE) 		// Still have a cugel.
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)		//Only effects draw and reload time.
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)			//Only effects draw times.
	H.mind.adjust_skillrank(/datum/skill/combat/slings, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE) // A little better; run fast, weak boy.
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC) //+1 spd, con, end, +3 per in town
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	//Garrison ranged/speed class. Time to go wild
	H.change_stat("endurance", 1) // seems kinda lame but remember guardsman bonus!!
	H.change_stat("perception", 2)
	H.change_stat("speed", 2)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 5)

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/skirmisher/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		H.adjust_blindness(-3)
		var/weapons = list("Crossbow","Longbow","Sling")
		weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as null|anything in weapons
		H.set_blindness(0)
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Crossbow","Longbow","Sling")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Crossbow" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Crossbow")
			var/obj/item/quiver_item = new /obj/item/quiver/bolts(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow(get_turf(H))
			
			if(H.equip_to_slot_if_possible(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.equip_to_slot_if_possible(weapon_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
		
		if("Longbow")
			var/obj/item/quiver_item = new /obj/item/quiver/arrows(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow(get_turf(H))
			
			if(H.equip_to_slot_if_possible(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.equip_to_slot_if_possible(weapon_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
		
		if("Sling")
			var/obj/item/quiver_item = new /obj/item/quiver/sling/iron(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/sling(get_turf(H))
			
			if(H.equip_to_slot_if_possible(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.put_in_r_hand(weapon_item) || H.put_in_l_hand(weapon_item))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], skilled Skirmisher of the Manor!</span>")

/datum/advclass/manorguard/cavalry
	name = "Cavalryman"
	tutorial = "You are a professional soldier of the realm, specializing in the steady beat of hoof falls. Lighter and more expendable then the knights, you charge with lance in hand. Beast sold seperately."
	outfit = /datum/outfit/job/roguetown/manorguard/cavalry

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/cavalry
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/winged
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/gorget

/datum/outfit/job/roguetown/manorguard/cavalry/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE) 		// Still have a cugel.
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)	//Best whip training out of MAAs, they're strong.
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 1, TRUE)			// We discourage horse archers, though.
	H.mind.adjust_skillrank(/datum/skill/combat/slings, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE) 
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE) 		// Like the other horselords.
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)	//Best tracker. Might as well give it something to stick-out utility wise.
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_GUARDSMAN, TRAIT_GENERIC) //+1 spd, con, end, +3 per in town
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	//Garrison mounted class; charge and charge often.
	H.change_stat("strength", 1)
	H.change_stat("constitution", 2) 
	H.change_stat("endurance", 2) // Your name is speed, and speed is running.
	H.change_stat("intelligence", 1) // No strength to account for the nominally better weapons. We'll see.

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 5)

	backpack_contents = list(/obj/item/rogueweapon/huntingknife/idagger/steel/special = 1, /obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/cavalry/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		H.adjust_blindness(-3)
		var/weapons = list("Bardiche","Sword & Shield")
		weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as null|anything in weapons
		H.set_blindness(0)
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Bardiche","Sword & Shield")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Bardiche" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Bardiche")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/halberd/bardiche(get_turf(H))
			var/obj/item/gwstrap_item = new /obj/item/gwstrap(get_turf(H))
			
			if(H.put_in_r_hand(weapon_item) || H.put_in_l_hand(weapon_item))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_if_possible(gwstrap_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [gwstrap_item].</span>")
		
		if("Sword & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/sword/sabre(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
			
			if(H.equip_to_slot_if_possible(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_if_possible(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], charging Cavalryman of the Manor!</span>")
