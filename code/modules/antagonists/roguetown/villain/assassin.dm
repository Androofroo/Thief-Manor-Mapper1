/datum/antagonist/assassin
	name = "Assassin"
	roundend_category = "assassins"
	antagpanel_category = "Assassin"
	job_rank = ROLE_ASSASSIN
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "assassin"
	confess_lines = list(
		"I am the blade in the shadows!",
		"Death is my trade, and business is good.",
		"I was hired to kill, and kill I shall.",
	)
	rogue_enabled = TRUE
	thief_enabled = TRUE  // This will make it visible in villain selection
	var/datum/mind/target

/datum/antagonist/assassin/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(istype(examined_datum, /datum/antagonist/assassin))
		return span_boldnotice("Another assassin. A professional killer like me.")

/datum/antagonist/assassin/on_gain()
	owner.special_role = "Assassin"
	owner.assigned_role = "Stranger"
	forge_objectives()
	. = ..()
	equip_assassin()
	finalize_assassin()
	move_to_spawnpoint()

/datum/antagonist/assassin/proc/finalize_assassin()
	owner.current.playsound_local(get_turf(owner.current), 'sound/music/traitor.ogg', 60, FALSE, pressure_affected = FALSE)
	var/mob/living/carbon/human/H = owner.current
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_OUTLANDER, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_OUTLAW, TRAIT_GENERIC)
	to_chat(H, span_alertsyndie("I am an ASSASSIN!"))
	to_chat(H, span_boldwarning("I've been hired to eliminate a specific target. I must study their patterns, find the perfect moment, and strike without hesitation. The payment for this job will be substantial, but only if I complete my contract and survive."))
	to_chat(H, span_boldnotice("I've been provided with specialized equipment for this task, including poisons, a disguise kit, and a sharp blade. Use them wisely to complete the contract."))

/datum/antagonist/assassin/greet()
	owner.announce_objectives()

/datum/antagonist/assassin/proc/forge_objectives()
	// Select random target
	var/list/possible_targets = list()
	for(var/datum/mind/M in SSticker.minds)
		if(M != owner && ishuman(M.current) && M.current.stat != DEAD)
			possible_targets += M
	
	if(possible_targets.len > 0)
		target = pick(possible_targets)
		
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = owner
		kill_objective.target = target
		kill_objective.explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
		objectives += kill_objective
	
	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = owner
	objectives += survive_objective

/datum/antagonist/assassin/proc/move_to_spawnpoint()
	if(GLOB.assassin_starts.len > 0)
		owner.current.forceMove(pick(GLOB.assassin_starts))
	else
		// Fallback to bandit spawns if no assassin spawns are available
		owner.current.forceMove(pick(GLOB.bandit_starts))

/datum/antagonist/assassin/proc/equip_assassin()
	var/mob/living/carbon/human/H = owner.current
	
	// Cancel advclass setup if active
	H.advsetup = 0
	
	// Update job to "Stranger" for consistency
	H.job = "Stranger"
	
	// Make the assassin unknown to others and vice versa
	owner.unknow_all_people()
	for(var/datum/mind/MF in get_minds())
		owner.become_unknown_to(MF)
	
	// But assassins know each other
	for(var/datum/mind/MF in get_minds("Assassin"))
		owner.i_know_person(MF)
		owner.person_knows_me(MF)
	
	// Set assassination-related skills - direct assignment like the bandit approach
	H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/stealing, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/knives, 5, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/combat/maces, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/alchemy, 3, TRUE)
	H.mind.adjust_skillrank(/datum/skill/craft/traps, 4, TRUE)
	H.mind.adjust_skillrank(/datum/skill/misc/tracking, 4, TRUE)
	
	// Set assassin stats
	H.change_stat("dexterity", 4)
	H.change_stat("intelligence", 2)
	H.change_stat("perception", 4)
	H.change_stat("speed", 3)
	H.change_stat("strength", 2)
	
	// Outfit the assassin with gear similar to thief but with assassin-specific items
	H.equipOutfit(/datum/outfit/job/roguetown/assassin)
	
	// Add special abilities
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/smoke_bomb)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/snuff_light)
	H.mind.AddSpell(new /obj/effect/proc_holder/spell/self/magical_disguise)
	
	// Add traits
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	
	// Add combat music
	H.cmode_music = 'sound/music/combat_rogue.ogg'

	return TRUE

// Assassin outfit definition
/datum/outfit/job/roguetown/assassin
	name = "Assassin"
	
	// Clothing
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/leather
	cloak = /obj/item/clothing/cloak/raincloak/mortus
	shirt = /obj/item/clothing/suit/roguetown/armor/gambeson
	backl = /obj/item/storage/backpack/rogue/satchel
	belt = /obj/item/storage/belt/rogue/leather/knifebelt/iron
	gloves = /obj/item/clothing/gloves/roguetown/fingerless
	shoes = /obj/item/clothing/shoes/roguetown/boots
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	wrists = /obj/item/clothing/wrists/roguetown/bracers/leather
	beltl = /obj/item/lockpickring/mundane
	beltr = /obj/item/rogueweapon/huntingknife/idagger/steel
	
	// Backpack contents
	backpack_contents = list(
		/obj/item/reagent_containers/glass/bottle/rogue/strongpoison = 2,
		/obj/item/flashlight/flare/torch = 1,
		/obj/item/rogueweapon/huntingknife/idagger/steel/poisoned = 1
	)

/datum/antagonist/assassin/roundend_report()
	if(owner?.current)
		var/the_name = owner.name
		if(ishuman(owner.current))
			var/mob/living/carbon/human/H = owner.current
			the_name = H.real_name
		
		var/objectives_complete = TRUE
		var/objectives_text = ""
		
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
			objectives_text += "[objective.explanation_text]: [objective.check_completion() ? "Success" : "Failed"]\n"
		
		if(objectives_complete)
			to_chat(world, "[the_name] was an assassin who successfully completed their contract.")
		else
			to_chat(world, "[the_name] was an assassin who failed their contract.")
