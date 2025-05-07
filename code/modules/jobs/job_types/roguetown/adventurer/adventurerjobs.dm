// Adventurer Manor Jobs

/datum/advclass/warrior_manor
	name = "Warrior"
	tutorial = "A battle-hardened fighter skilled in melee combat and physical defense."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/warrior_manor
	traits_applied = list(TRAIT_OUTLANDER)
	category_tags = list(CTAG_ADVENTURERMANOR)
	classes = list(
		"Defender" = "You specialize in defensive tactics, using your sturdy frame to protect allies.",
		"Striker" = "You focus on quick strikes and mobility, overwhelming opponents with speed rather than raw power.",
		"Veteran" = "Years of battle have honed your skills and instincts, making you a formidable all-around combatant."
	)

/datum/outfit/job/roguetown/adventurer/warrior_manor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Defender", "Striker", "Veteran")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Defender")
			to_chat(H, span_warning("You specialize in defensive tactics, using your sturdy frame to protect allies."))
			H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.set_blindness(0)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
			H.change_stat("strength", 2)
			H.change_stat("endurance", 2)
			H.change_stat("constitution", 2)
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
			pants = /obj/item/clothing/under/roguetown/platelegs
			shoes = /obj/item/clothing/shoes/roguetown/boots/armor
			armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

		if("Striker")
			to_chat(H, span_warning("You focus on quick strikes and mobility, overwhelming opponents with speed rather than raw power."))
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
			H.set_blindness(0)
			H.change_stat("strength", 1)
			H.change_stat("endurance", 1)
			H.change_stat("speed", 2)
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/armor/leather/studded
			pants = /obj/item/clothing/under/roguetown/chainlegs
			shoes = /obj/item/clothing/shoes/roguetown/boots/leather
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backl = /obj/item/storage/backpack/rogue/satchel
			belt = /obj/item/storage/belt/rogue/leather
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

		if("Veteran")
			to_chat(H, span_warning("Years of battle have honed your skills and instincts, making you a formidable all-around combatant."))
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/axes, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			H.set_blindness(0)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
			H.change_stat("strength", 1)
			H.change_stat("endurance", 1)
			H.change_stat("constitution", 1)
			H.change_stat("intelligence", 1)
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson/heavy
			pants = /obj/item/clothing/under/roguetown/splintlegs
			shoes = /obj/item/clothing/shoes/roguetown/boots/armor/iron
			armor = /obj/item/clothing/suit/roguetown/armor/brigandine
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

/datum/advclass/rogue_manor
	name = "Rogue"
	tutorial = "A sneaky and agile character adept at stealth, lockpicking, and quick strikes."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/rogue_manor
	traits_applied = list(TRAIT_OUTLANDER)
	category_tags = list(CTAG_ADVENTURERMANOR)
	classes = list(
		"Infiltrator" = "You excel at breaking into secure locations, with a focus on lockpicking and bypassing security.",
		"Shadow" = "You are a master of stealth, able to move unseen and strike from darkness.",
		"Scoundrel" = "You survive by your wits and quick reflexes, with a silver tongue to talk your way out of trouble."
	)

/datum/outfit/job/roguetown/adventurer/rogue_manor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Infiltrator", "Shadow", "Scoundrel")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Infiltrator")
			to_chat(H, span_warning("You excel at breaking into secure locations, with a focus on lockpicking and bypassing security."))
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.set_blindness(0)
			H.change_stat("speed", 1)
			H.change_stat("perception", 2)
			H.change_stat("fortune", 1)
			
			// Only add the disguise spell if they don't already have it
			var/has_disguise = FALSE
			for(var/obj/effect/proc_holder/spell/self/magical_disguise/S in H.mind.spell_list)
				has_disguise = TRUE
				break
			if(!has_disguise)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/magical_disguise)
				
			pants = /obj/item/clothing/under/roguetown/tights/black
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/lockpick = 1, /obj/item/flashlight/flare/torch = 1)

		if("Shadow")
			to_chat(H, span_warning("You are a master of stealth, able to move unseen and strike from darkness."))
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.set_blindness(0)
			H.change_stat("speed", 2)
			H.change_stat("perception", 1)
			H.change_stat("fortune", 1)
			
			// Only add the invisibility spell if they don't already have it
			var/has_invisibility = FALSE
			for(var/obj/effect/proc_holder/spell/invoked/invisibility/S in H.mind.spell_list)
				has_invisibility = TRUE
				break
			if(!has_invisibility)
				H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/invisibility)
				
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/smokebomb = 3)
			pants = /obj/item/clothing/under/roguetown/tights/black
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			cloak = /obj/item/clothing/cloak/raincloak
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel

		if("Scoundrel")
			to_chat(H, span_warning("You survive by your wits and quick reflexes, with a silver tongue to talk your way out of trouble."))
			H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.set_blindness(0)
			H.change_stat("speed", 1)
			H.change_stat("intelligence", 1)
			H.change_stat("fortune", 2)
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
			pants = /obj/item/clothing/under/roguetown/tights
			shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

/datum/advclass/mage_manor
	name = "Mage"
	tutorial = "A wielder of arcane magic, capable of casting offensive, defensive, or utility spells."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/mage_manor
	category_tags = list(CTAG_ADVENTURERMANOR)
	traits_applied = list(TRAIT_OUTLANDER)
	classes = list(
		"Elementalist" = "You focus on manipulating the fundamental forces of nature - fire, water, earth, and air.",
		"Enchanter" = "You specialize in enchantments that affect the mind and manipulate others.",
		"Scholar" = "Your magical knowledge comes from dedicated study and research of ancient texts."
	)

/datum/outfit/job/roguetown/adventurer/mage_manor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Elementalist", "Enchanter", "Scholar")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Elementalist")
			to_chat(H, span_warning("You focus on manipulating the fundamental forces of nature - fire, water, earth, and air."))
			head = /obj/item/clothing/head/roguetown/roguehood/mage
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
			H.change_stat("intelligence", 2)
			H.change_stat("perception", 2)
			H.mind.adjust_spellpoints(3)
			ADD_TRAIT(H, TRAIT_MAGEARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_ARCYNE_T2, TRAIT_GENERIC)

		if("Enchanter")
			to_chat(H, span_warning("You specialize in enchantments that affect the mind and manipulate others."))
			head = /obj/item/clothing/head/roguetown/circlet
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/tights
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
			H.change_stat("intelligence", 2)
			H.change_stat("perception", 1)
			H.change_stat("fortune", 1)
			H.mind.adjust_spellpoints(3)
			ADD_TRAIT(H, TRAIT_MAGEARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_ARCYNE_T2, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)

		if("Scholar")
			to_chat(H, span_warning("Your magical knowledge comes from dedicated study and research of ancient texts."))
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/mage
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1, /obj/item/paper = 3)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/arcane, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 1, TRUE)
			H.change_stat("intelligence", 3)
			H.change_stat("perception", 1)
			H.mind.adjust_spellpoints(3)
			ADD_TRAIT(H, TRAIT_MAGEARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_ARCYNE_T2, TRAIT_GENERIC)

/datum/advclass/archer_manor
	name = "Archer"
	tutorial = "A ranged specialist with precise aim and the ability to strike from a distance."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/archer_manor
	traits_applied = list(TRAIT_OUTLANDER)
	category_tags = list(CTAG_ADVENTURERMANOR)
	classes = list(
		"Marksman" = "You focus on accuracy and hitting vital areas from great distances.",
		"Hunter" = "You specialize in tracking prey and surviving in the wilderness.",
		"Scout" = "Your keen eyes and light armor make you an excellent observer and first-striker."
	)

/datum/outfit/job/roguetown/adventurer/archer_manor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Marksman", "Hunter", "Scout")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Marksman")
			to_chat(H, span_warning("You focus on accuracy and hitting vital areas from great distances."))
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.set_blindness(0)
			H.change_stat("perception", 3)
			H.change_stat("endurance", 1)
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

		if("Hunter")
			to_chat(H, span_warning("You specialize in tracking prey and surviving in the wilderness."))
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
			H.set_blindness(0)
			H.change_stat("perception", 2)
			H.change_stat("endurance", 2)
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/brown
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			cloak = /obj/item/clothing/cloak/raincloak/furcloak/brown
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

		if("Scout")
			to_chat(H, span_warning("Your keen eyes and light armor make you an excellent observer and first-striker."))
			H.mind.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.set_blindness(0)
			H.change_stat("perception", 2)
			H.change_stat("speed", 2)
			pants = /obj/item/clothing/under/roguetown/tights
			shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			shoes = /obj/item/clothing/shoes/roguetown/boots
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)

/datum/advclass/cleric_manor
	name = "Temple Cleric"
	tutorial = "A holy healer and protector, using divine magic to support allies or repel dark forces."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/temple_cleric
	traits_applied = list(TRAIT_OUTLANDER)
	vampcompat = FALSE
	category_tags = list(CTAG_ADVENTURERMANOR)
	classes = list(
		"Healer" = "You focus on healing wounds and curing ailments through divine magic.",
		"Guardian" = "Your protective magic forms barriers and shields to protect allies.",
		"Crusader" = "You channel divine power to oppose darkness and undeath."
	)

/datum/outfit/job/roguetown/adventurer/temple_cleric
	allowed_patrons = ALL_PATRONS

/datum/outfit/job/roguetown/adventurer/temple_cleric/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Healer", "Crusader")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Healer")
			to_chat(H, span_warning("You focus on healing wounds and curing ailments through divine magic."))
			head = /obj/item/clothing/head/roguetown/roguehood
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/shirt/robe/priest
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
			H.change_stat("intelligence", 1)
			H.change_stat("perception", 2)
			H.change_stat("constitution", 1)
			var/datum/devotion/C = new /datum/devotion(H, H.patron)
			C.grant_spells_templar(H)
			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)

		if("Crusader")
			to_chat(H, span_warning("You channel divine power to oppose darkness and undeath."))
			head = /obj/item/clothing/head/roguetown/roguehood
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
			armor = /obj/item/clothing/suit/roguetown/armor/plate/half/fluted/ornate
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/holy, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
			H.change_stat("strength", 1)
			H.change_stat("constitution", 1)
			H.change_stat("intelligence", 1)
			H.change_stat("perception", 1)
			ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)

/datum/advclass/druid_manor
	name = "Druid"
	tutorial = "A nature-based spellcaster who communes with animals, plants, and elemental forces."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	outfit = /datum/outfit/job/roguetown/adventurer/druid_manor
	traits_applied = list(TRAIT_OUTLANDER)
	category_tags = list(CTAG_ADVENTURERMANOR)
	classes = list(
		"Beastmaster" = "You have a special connection to animals and can communicate with them.",
		"Herbalist" = "Your knowledge of plants and herbs allows you to heal and create potions.",
		"Elementalist" = "You can call upon the powers of nature's elemental forces."
	)

/datum/outfit/job/roguetown/adventurer/druid_manor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Beastmaster", "Herbalist", "Elementalist")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)
		if("Beastmaster")
			to_chat(H, span_warning("You have a special connection to animals and can communicate with them."))
			head = /obj/item/clothing/head/roguetown/roguehood
			shoes = /obj/item/clothing/shoes/roguetown/boots/furlinedboots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			cloak = /obj/item/clothing/cloak/raincloak/furcloak
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/druidic, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
			H.change_stat("perception", 2)
			H.change_stat("constitution", 1)
			H.change_stat("endurance", 1)
			H.mind.adjust_spellpoints(3)
			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)

		if("Herbalist")
			to_chat(H, span_warning("Your knowledge of plants and herbs allows you to heal and create potions."))
			head = /obj/item/clothing/head/roguetown/roguehood
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/druidic, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 2, TRUE)
			H.change_stat("intelligence", 2)
			H.change_stat("perception", 2)
			H.mind.adjust_spellpoints(2)
			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)

		if("Elementalist")
			to_chat(H, span_warning("You can call upon the powers of nature's elemental forces."))
			head = /obj/item/clothing/head/roguetown/roguehood
			shoes = /obj/item/clothing/shoes/roguetown/boots
			pants = /obj/item/clothing/under/roguetown/trou/leather
			shirt = /obj/item/clothing/suit/roguetown/shirt/tunic
			armor = /obj/item/clothing/suit/roguetown/armor/leather
			cloak = /obj/item/clothing/cloak/raincloak
			gloves = /obj/item/clothing/gloves/roguetown/fingerless_leather
			belt = /obj/item/storage/belt/rogue/leather
			backl = /obj/item/storage/backpack/rogue/satchel
			backr = /obj/item/rogueweapon/woodstaff
			backpack_contents = list(/obj/item/flashlight/flare/torch = 1)
			H.mind.adjust_skillrank(/datum/skill/combat/polearms, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/magic/druidic, 3, TRUE)
			H.change_stat("intelligence", 2)
			H.change_stat("perception", 1)
			H.change_stat("endurance", 1)
			H.mind.adjust_spellpoints(3)
			ADD_TRAIT(H, TRAIT_MAGEARMOR, TRAIT_GENERIC)
