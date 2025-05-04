/datum/job/roguetown/villager
	title = "Artisan"
	flag = VILLAGER
	department_flag = PEASANTS
	faction = "Station"
	total_positions = 4
	spawn_positions = 4
	allowed_races = RACES_ALL_KINDS
	tutorial = "Skilled hands in service to noble gold, Artisans are the lifeblood of the manor’s daily function and quiet prestige. Whether forging steel, weaving finery, or brewing potions, each Artisan holds knowledge, tools, and secrets that others overlook... until something goes missing."
	advclass_cat_rolls = list(CTAG_TOWNER = 20)
	outfit = null
	outfit_female = null
	bypass_lastclass = TRUE
	bypass_jobban = FALSE
	display_order = JDO_VILLAGER
	give_bank_account = TRUE
	min_pq = -15
	max_pq = null
	round_contrib_points = 2
	wanderer_examine = FALSE
	advjob_examine = TRUE
	same_job_respawn_delay = 0

/datum/job/roguetown/villager/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")

/*
/datum/job/roguetown/adventurer/villager/New()
	. = ..()
	for(var/X in GLOB.peasant_positions)
		peopleiknow += X
		peopleknowme += X
	for(var/X in GLOB.yeoman_positions)
		peopleiknow += X
	for(var/X in GLOB.church_positions)
		peopleiknow += X
	for(var/X in GLOB.garrison_positions)
		peopleiknow += X
	for(var/X in GLOB.noble_positions)
		peopleiknow += X*/
