/datum/job/roguetown/squire
	title = "Squire"
	flag = SQUIRE
	department_flag = GARRISON
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	allowed_races = RACES_ALL_KINDS
	allowed_sexes = list(MALE, FEMALE)
	allowed_ages = list(AGE_ADULT)

	tutorial = "The Squire is a loyal aide-in-training, eager to prove themselves in service to their knight or the manor. Though inexperienced, they're resourceful, quick on their feet, and often underestimated by friend and foe alike."
	outfit = /datum/outfit/job/roguetown/squire
	display_order = JDO_SQUIRE
	give_bank_account = TRUE
	min_pq = -5 //squires aren't great but they can do some damage
	max_pq = null
	round_contrib_points = 2

	cmode_music = 'sound/music/combat_squire.ogg'

/datum/job/roguetown/squire/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
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
			S.name = "squire's tabard ([index])"

/datum/outfit/job/roguetown/squire
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/guard
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather
	beltl = /obj/item/storage/keyring/guardcastle
	cloak = /obj/item/clothing/cloak/stabard/surcoat/guard
	id = /obj/item/scomstone/bad/garrison
	armor = /obj/item/clothing/suit/roguetown/armor/chainmail
	gloves = /obj/item/clothing/gloves/roguetown/leather
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	pants = /obj/item/clothing/under/roguetown/chainlegs/iron
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/storage/belt/rogue/pouch,
		/obj/item/clothing/neck/roguetown/chaincoif
	)

/datum/outfit/job/roguetown/squire/pre_equip(mob/living/carbon/human/H)
	if(!H || !H.mind)
		return
	
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.change_stat("strength", 1)
	H.change_stat("perception", 1)
	H.change_stat("constitution", 1)
	H.change_stat("intelligence", 1)
	H.change_stat("speed", 1)
	ADD_TRAIT(H, TRAIT_SQUIRE_REPAIR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	
	addtimer(CALLBACK(src, PROC_REF(give_weapon_choices), H), 1)

/datum/outfit/job/roguetown/squire/proc/give_weapon_choices(mob/living/carbon/human/H)
	if(!H)
		return
	
	var/weapon_choice
	
	if(H.client)
		// Interactive selection for players with clients attached
		var/weapons = list("Iron Sword", "Cudgel")
		weapon_choice = input(H, "Choose your weapon.", "TAKE UP ARMS") as null|anything in weapons
	else
		// For roundstart squires with no client attached yet, use random selection
		var/list/weapons = list("Iron Sword", "Cudgel")
		weapon_choice = pick(weapons)
	
	if(!weapon_choice)
		weapon_choice = "Iron Sword" // Default if they cancel
	
	// Create the selected weapon
	var/obj/item/weapon_item
	
	switch(weapon_choice)
		if("Iron Sword")
			weapon_item = new /obj/item/rogueweapon/sword/iron(get_turf(H))
		if("Cudgel")
			weapon_item = new /obj/item/rogueweapon/mace/cudgel(get_turf(H))
	
	// Equip the weapon instantly
	if(H.equip_to_slot_or_del(weapon_item, SLOT_BELT_R))
		to_chat(H, "<span class='notice'>You arm yourself with \a [weapon_item].</span>")
	
	to_chat(H, "<span class='boldnotice'>Welcome, [H.real_name], eager Squire!</span>")
