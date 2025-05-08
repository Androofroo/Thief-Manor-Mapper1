/datum/job/roguetown/councillor
	title = "Noble Guest"
	flag = COUNCILLOR
	department_flag = NOBLEMEN
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	allowed_ages = ALL_AGES_LIST
	allowed_races = NOBLE_RACES_TYPES
	allowed_sexes = list(MALE, FEMALE)
	display_order = JDO_COUNCILLOR
	tutorial = "A visiting aristocrat draped in silk and status, here for diplomacy, indulgence, or intrigue. They speak with entitlement, move with practiced grace, and expect the manor—and its secrets—to cater to their whims."
	whitelist_req = FALSE
	outfit = /datum/outfit/job/roguetown/councillor

	give_bank_account = 40
	noble_income = 20
	min_pq = 0 
	max_pq = null
	round_contrib_points = 2
	cmode_music = 'sound/music/combat_noble.ogg'

/datum/outfit/job/roguetown/councillor
	shoes = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	belt = /obj/item/storage/belt/rogue/leather/black
	beltr = /obj/item/flashlight/flare/torch/lantern
	backl = /obj/item/storage/backpack/rogue/satchel
	neck = /obj/item/storage/belt/rogue/pouch/coins/rich
	id = /obj/item/clothing/ring/silver

/datum/outfit/job/roguetown/councillor/pre_equip(mob/living/carbon/human/H)
	..()
	if(should_wear_masc_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/red
		pants = /obj/item/clothing/under/roguetown/tights/black
		cloak = /obj/item/clothing/cloak/half/red
	else if(should_wear_femme_clothes(H))
		shirt = /obj/item/clothing/suit/roguetown/shirt/dress/gen/purple
		pants = /obj/item/clothing/under/roguetown/tights/stockings/silk/purple
		cloak = /obj/item/clothing/cloak/raincloak/purple

	if(!H.mind)
		return

	H.mind.adjust_skillrank(/datum/skill/misc/riding, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/music, 1, TRUE)

	ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
	H.change_stat("strength", 1)
	H.change_stat("perception", 2)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 2)

