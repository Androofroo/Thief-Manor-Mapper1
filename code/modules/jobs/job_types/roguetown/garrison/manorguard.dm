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

// Basic guard
/datum/advclass/manorguard/footman
	name = "Footman"
	tutorial = "You are a basic guard of the manor, maintaining order and security. You are armed with standard-issue equipment and trained to handle common threats to the estate."
	outfit = /datum/outfit/job/roguetown/manorguard/footman

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/footman
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/manorguard/footman/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	H.change_stat("strength", 2)
	H.change_stat("constitution", 1)
	H.change_stat("endurance", 1)
	H.change_stat("speed", 1)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

	backpack_contents = list(/obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/footman/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		var/weapons = list("Sword & Shield","Mace & Shield","Halberd")
		weapon_choice = timed_input_list(H, "Choose your weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Sword & Shield","Mace & Shield","Halberd")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Sword & Shield" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Sword & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/sword(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
		
		if("Mace & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/wood(get_turf(H))
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
		
		if("Halberd")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/halberd(get_turf(H))
			var/obj/item/gwstrap_item = new /obj/item/gwstrap(get_turf(H))
			
			if(H.put_in_r_hand(weapon_item) || H.put_in_l_hand(weapon_item))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_or_del(gwstrap_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [gwstrap_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], vigilant Footman of the Manor!</span>")

// Gatewarden - Responsible for the manor's gates and checkpoints
/datum/advclass/manorguard/gatewarden
	name = "Gatewarden"
	tutorial = "You are responsible for the manor's gates and checkpoints—first to see who enters and last to see who escapes. You're trained in observation and control of access points, with a keen eye and steady hands for ranged weaponry."
	outfit = /datum/outfit/job/roguetown/manorguard/gatewarden

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/gatewarden
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/lord
	armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
	head = /obj/item/clothing/head/roguetown/helmet/kettle
	pants = /obj/item/clothing/under/roguetown/trou/leather
	neck = /obj/item/clothing/neck/roguetown/chaincoif
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/leather
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/rogueweapon/huntingknife
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/manorguard/gatewarden/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	// Ranged weapons specialist
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/bows, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/slings, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	// Better perception and speed for a ranged specialist
	H.change_stat("perception", 4)
	H.change_stat("intelligence", 1)
	H.change_stat("speed", 2)
	H.change_stat("endurance", 1)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

	backpack_contents = list(/obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/gatewarden/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		var/weapons = list("Crossbow & Bolts","Yew Longbow & Arrows","Recurve Bow & Arrows")
		weapon_choice = timed_input_list(H, "Choose your ranged weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Crossbow & Bolts","Yew Longbow & Arrows","Recurve Bow & Arrows")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Crossbow & Bolts" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Crossbow & Bolts")
			var/obj/item/quiver_item = new /obj/item/quiver/bolts(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow(get_turf(H))
			
			if(H.equip_to_slot_or_del(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
		
		if("Yew Longbow & Arrows")
			var/obj/item/quiver_item = new /obj/item/quiver/arrows(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/bow/longbow(get_turf(H))
			
			if(H.equip_to_slot_or_del(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
				
		if("Recurve Bow & Arrows")
			var/obj/item/quiver_item = new /obj/item/quiver/arrows(get_turf(H))
			var/obj/item/weapon_item = new /obj/item/gun/ballistic/revolver/grenadelauncher/bow/recurve(get_turf(H))
			
			if(H.equip_to_slot_or_del(quiver_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You take up \a [quiver_item].</span>")
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	
	// Extra secondary weapon - a dagger for close combat
	var/obj/item/secondary_weapon = new /obj/item/rogueweapon/huntingknife(get_turf(H))
	if(H.equip_to_slot_or_del(secondary_weapon, SLOT_BACK_R))
		to_chat(H, "<span class='notice'>You keep \a [secondary_weapon] as a sidearm.</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], vigilant Gatewarden of the Manor!</span>")

// Witchfinder - Trained to interrogate suspects and uncover secrets
/datum/advclass/manorguard/witchfinder
	name = "Witchfinder"
	tutorial = "Trained to interrogate suspects, sniff out lies, and dig up secrets better left buried. You have specialized in the art of deduction and intimidation to serve the manor's darker security needs."
	outfit = /datum/outfit/job/roguetown/manorguard/witchfinder

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/witchfinder
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	armor = /obj/item/clothing/suit/roguetown/armor/plate/scale/inqcoat
	head = /obj/item/clothing/head/roguetown/duelhat
	cloak = /obj/item/clothing/cloak/half
	pants = /obj/item/clothing/under/roguetown/trou/beltpants
	wrists = /obj/item/clothing/neck/roguetown/psicross/silver
	gloves = /obj/item/clothing/gloves/roguetown/angle
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/manorguard/witchfinder/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/whipsflails, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 5, TRUE)
	ADD_TRAIT(H, TRAIT_NOSEGRAB, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PERFECT_TRACKER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PURITAN, JOB_TRAIT)

	H.change_stat("perception", 2)
	H.change_stat("intelligence", 3)
	H.change_stat("speed", 1)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

	backpack_contents = list(/obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= list(/mob/proc/haltyell, /mob/living/carbon/human/proc/torture_victim)

/datum/outfit/job/roguetown/manorguard/witchfinder/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		var/weapons = list("Knife & Whip","Knife & Cudgel","Mace & Dagger")
		weapon_choice = timed_input_list(H, "Choose your implements within 30 seconds.", "TOOLS OF INQUIRY", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! Implements have been selected for you.</span>")
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Knife & Whip","Knife & Cudgel","Mace & Dagger")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Knife & Whip" // Default if they cancel
	
	// Create chosen weapons
	switch(weapon_choice)
		if("Knife & Whip")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/huntingknife(get_turf(H))
			var/obj/item/whip_item = new /obj/item/rogueweapon/whip(get_turf(H))
			
			// Store in backpack using SEND_SIGNAL
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, weapon_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [weapon_item] in your satchel.</span>")
			else
				H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R)
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, whip_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [whip_item] in your satchel.</span>")
			else
				if(H.equip_to_slot_or_del(whip_item, SLOT_BACK_L))
					to_chat(H, "<span class='notice'>You take up \a [whip_item].</span>")
		
		if("Knife & Cudgel")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace/cudgel(get_turf(H))
			var/obj/item/dagger_item = new /obj/item/rogueweapon/huntingknife/idagger(get_turf(H))
			
			// Store in backpack using SEND_SIGNAL
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, weapon_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [weapon_item] in your satchel.</span>")
			else
				H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R)
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, dagger_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [dagger_item] in your satchel.</span>")
			else
				if(H.equip_to_slot_or_del(dagger_item, SLOT_BACK_L))
					to_chat(H, "<span class='notice'>You take up \a [dagger_item].</span>")
		
		if("Mace & Dagger")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace(get_turf(H))
			var/obj/item/dagger_item = new /obj/item/rogueweapon/huntingknife/idagger(get_turf(H))
			
			// Store in backpack using SEND_SIGNAL
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, weapon_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [weapon_item] in your satchel.</span>")
			else
				H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R)
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.backr && SEND_SIGNAL(H.backr, COMSIG_TRY_STORAGE_INSERT, dagger_item, H, TRUE))
				to_chat(H, "<span class='notice'>You place \a [dagger_item] in your satchel.</span>")
			else
				if(H.equip_to_slot_or_del(dagger_item, SLOT_BACK_L))
					to_chat(H, "<span class='notice'>You take up \a [dagger_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], shrewd Witchfinder of the Manor!</span>")

// Sentinel - Heavily armored and slow, but nearly unbreakable
/datum/advclass/manorguard/sentinel
	name = "Sentinel"
	tutorial = "Heavily armored and slow, but nearly unbreakable—you are stationed in critical hallways or vaults. You serve as the last line of defense for the manor's most precious assets and inhabitants."
	outfit = /datum/outfit/job/roguetown/manorguard/sentinel

	category_tags = list(CTAG_MENATARMS)

/datum/outfit/job/roguetown/manorguard/sentinel
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail/hauberk
	armor = /obj/item/clothing/suit/roguetown/armor/plate
	head = /obj/item/clothing/head/roguetown/helmet/sallet/visored
	pants = /obj/item/clothing/under/roguetown/chainlegs
	neck = /obj/item/clothing/neck/roguetown/bevor
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	gloves = /obj/item/clothing/gloves/roguetown/chain
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	beltl = /obj/item/rogueweapon/mace/cudgel
	belt = /obj/item/storage/belt/rogue/leather/black
	backr = /obj/item/storage/backpack/rogue/satchel/black
	id = /obj/item/scomstone/bad/garrison

/datum/outfit/job/roguetown/manorguard/sentinel/pre_equip(mob/living/carbon/human/H)
	..()
	if(!H || !H.mind)
		return
		
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/shields, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/axes, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/polearms, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)

	H.change_stat("strength", 3)
	H.change_stat("constitution", 3)
	H.change_stat("endurance", 3)
	H.change_stat("speed", -2)

	// Handle weapon choices
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

	backpack_contents = list(/obj/item/rope/chain = 1, /obj/item/storage/keyring/guardcastle = 1)
	H.verbs |= /mob/proc/haltyell

/datum/outfit/job/roguetown/manorguard/sentinel/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		var/weapons = list("Warhammer & Shield","Mace & Shield")
		weapon_choice = timed_input_list(H, "Choose your weapon within 30 seconds.", "TAKE UP ARMS", weapons, 30 SECONDS)
		if(!weapon_choice)
			// If they didn't make a selection within 30 seconds or cancelled, pick a random one
			weapon_choice = pick(weapons)
			to_chat(H, "<span class='warning'>Time's up! A weapon has been selected for you.</span>")
	else
		// For roundstart guards with no client attached yet, use random selection
		var/list/weapons = list("Warhammer & Shield","Mace & Shield","Halberd")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Warhammer & Shield" // Default if they cancel
	
	// Equip chosen weapon
	switch(weapon_choice)
		if("Warhammer & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace/warhammer(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/tower/metal(get_turf(H))
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
		
		if("Mace & Shield")
			var/obj/item/weapon_item = new /obj/item/rogueweapon/mace(get_turf(H))
			var/obj/item/shield_item = new /obj/item/rogueweapon/shield/tower/metal(get_turf(H))
			
			if(H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R))
				to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
			
			if(H.equip_to_slot_or_del(shield_item, SLOT_BACK_L))
				to_chat(H, "<span class='notice'>You take up \a [shield_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], immovable Sentinel of the Manor!</span>")
