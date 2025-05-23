// traitors, bandits, pro thieves, werewolves, vampires, demons, cultists
/*

/datum/game_mode/chaosmode
	name = "chaosmode"
	config_tag = "chaosmode"
	report_type = "chaosmode"
	false_report_weight = 0
	required_players = 0
	required_enemies = 0
	recommended_enemies = 0
	enemy_minimum_age = 0

	announce_span = "danger"
	announce_text = "The"

	var/allmig = FALSE
	var/roguefight = FALSE
	var/redscore = 0
	var/greenscore = 0

	var/list/allantags = list()

	var/datum/team/roguecultists

	var/list/datum/mind/villains = list()
	var/list/datum/mind/vampires = list()
	var/list/datum/mind/werewolves = list()
	var/list/datum/mind/bandits = list()

	var/list/datum/mind/pre_villains = list()
	var/list/datum/mind/pre_werewolves = list()
	var/list/datum/mind/pre_vampires = list()
	var/list/datum/mind/pre_bandits = list()
	var/list/datum/mind/pre_delfs = list()
	var/list/datum/mind/pre_rebels = list()
	
	var/banditcontrib = 0
	var/banditgoal = 1
	var/delfcontrib = 0
	var/delfgoal = 1

	var/skeletons = FALSE

	var/headrebdecree = FALSE

	var/check_for_lord = TRUE
	var/next_check_lord = 0
	var/missing_lord_time = FALSE
	var/roundvoteend = FALSE
	var/ttime

/datum/game_mode/chaosmode/proc/reset_skeletons()
	skeletons = FALSE

/datum/game_mode/chaosmode/check_finished()
	ttime = world.time - SSticker.round_start_time
	if(roguefight)
		if(ttime >= 30 MINUTES)
			return TRUE
		if((redscore >= 100) || (greenscore >= 100))
			return TRUE
		return FALSE

	if(allmig)
		return FALSE
/*		if(ttime >= 99 MINUTES)
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(H.stat != DEAD)
					if(H.allmig_reward && H.key)
						H.adjust_triumphs(H.allmig_reward)
						H.allmig_reward = 0
			return TRUE
		return FALSE*/

	if(ttime >= GLOB.round_timer)
		if(roundvoteend)
			if(ttime >= (GLOB.round_timer + 15 MINUTES) )
				for(var/mob/living/carbon/human/H in GLOB.human_list)
					if(H.stat != DEAD)
						if(H.allmig_reward)
							H.adjust_triumphs(H.allmig_reward)
							H.allmig_reward = 0
				return TRUE
		else
			if(!SSvote.mode)
				SSvote.initiate_vote("endround", pick("Zlod", "Sun King", "Gaia", "Moon Queen", "Aeon", "Gemini", "Aries"))
//	if(SSshuttle.emergency && (SSshuttle.emergency.mode == SHUTTLE_ENDGAME))
//		return TRUE

	if(headrebdecree)
		return TRUE

	check_for_lord()

	if(ttime > 180 MINUTES) //3 hour cutoff
		return TRUE

/datum/game_mode/chaosmode/proc/check_for_lord()
	if(world.time < next_check_lord)
		return
	next_check_lord = world.time + 1 MINUTES
	var/lord_found = FALSE
	var/lord_dead = FALSE
	for(var/mob/living/carbon/human/H in GLOB.human_list)
		if(H.mind)
			if((H.job == "King" || H.job == "Queen") && (SSticker.rulermob == H))
				lord_found = TRUE
				if(H.stat == DEAD)
					lord_dead = TRUE
				else
					if(lord_dead)
						lord_dead = FALSE
					break
	if(lord_dead || !lord_found)
		if(!missing_lord_time)
			missing_lord_time = world.time
		if(world.time > missing_lord_time + 10 MINUTES)
			missing_lord_time = world.time
			addomen(OMEN_NOLORD)
		return FALSE
	else
		return TRUE


/datum/game_mode/chaosmode/pre_setup()
	if(allmig || roguefight)
		return TRUE
	for(var/A in GLOB.special_roles_rogue)
		allantags |= get_players_for_role(A)

	pick_bandits()

	return TRUE

/datum/game_mode/proc/after_DO()
	return

/datum/game_mode/chaosmode/after_DO()
	if(allmig || roguefight)
		return TRUE

	var/list/modez_random = list(1,2,3)
	modez_random = shuffle(modez_random)
	for(var/i in modez_random)
		switch(i)
			if(1)
				if(prob(14))
					pick_rebels()
			if(2)
				var/amdt = max(round(num_players() / 3),1)
				for(var/j in 1 to amdt)
					if(prob(50))
						pick_vampires()
						pick_werewolves()
					else
						pick_werewolves()
						pick_vampires()
			if(3)
				if(prob(30))
					pick_maniac()

	return TRUE

/datum/game_mode/chaosmode/proc/pick_bandits()
	//BANDITS
	banditgoal = rand(200,400)
	restricted_jobs = list("King",
	"Queen",
	"Merchant",
	"Priest")
	var/num_bandits = 0
	if(num_players() >= 10)
		num_bandits = CLAMP(round(num_players() / 2), 1, 4)
		banditgoal += (num_bandits * rand(200,400))
#ifdef TESTSERVER
	num_bandits = 999
#endif
	if(num_bandits)
		antag_candidates = get_players_for_role(ROLE_BANDIT, pre_do=TRUE) //pre_do checks for their preferences since they don't have a job yet
		for(var/i = 0, i < num_bandits, ++i)
			var/datum/mind/bandito = pick_n_take(antag_candidates)
			var/found = FALSE
			for(var/M in allantags)
				if(M == bandito)
					found = TRUE
					allantags -= M
					break
			if(!found)
				continue
			pre_bandits += bandito
			bandito.assigned_role = "Bandit"
			bandito.special_role = "Bandit"
			testing("[key_name(bandito)] has been selected as a bandit")
			log_game("[key_name(bandito)] has been selected as a bandit")
	for(var/antag in pre_bandits)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_rebels()
	restricted_jobs = list() //handled after picking
	var/num_rebels = 0
	if(num_players() >= 10)
		num_rebels = CLAMP(round(num_players() / 3), 1, 3)
	if(num_rebels)
		antag_candidates = get_players_for_role(ROLE_PREBEL)
		if(antag_candidates.len)
			for(var/i = 0, i < num_rebels, ++i)
				var/datum/mind/rebelguy = pick_n_take(antag_candidates)
				if(!rebelguy)
					continue
				var/blockme = FALSE
				if(!(rebelguy in allantags))
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.garrison_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.noble_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.youngfolk_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.church_positions)
					blockme = TRUE
				if(rebelguy.assigned_role in GLOB.yeoman_positions)
					blockme = TRUE
				if(blockme)
					continue
				allantags -= rebelguy
				pre_rebels += rebelguy
				rebelguy.special_role = "Peasant Rebel"
				testing("[key_name(rebelguy)] has been selected as a Peasant Rebel")
				log_game("[key_name(rebelguy)] has been selected as a Peasant Rebel")
	for(var/antag in pre_rebels)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_maniac()
	restricted_jobs = list("King",
	"Queen",
	"Prisoner",
	"Dungeoneer",
	"Inquisitor",
	"Confessor",
	"Watchman",
	"Man at Arms",
	"Veteran",
	"Acolyte",
	"Cleric",
	"Knight Captain")
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	var/datum/mind/villain = pick_n_take(antag_candidates)
	if(villain)
		var/blockme = FALSE
		if(!(villain in allantags))
			blockme = TRUE
		if(villain.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(villain.current)
			if(villain.current.gender == FEMALE)
				blockme = TRUE
		if(blockme)
			return
		allantags -= villain
		pre_villains += villain
		villain.special_role = "maniac"
		villain.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(villain)] has been selected as the [villain.special_role]")
		log_game("[key_name(villain)] has been selected as the [villain.special_role]")
	for(var/antag in pre_villains)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_vampires()
	restricted_jobs = list("Acolyte","Priest","Adventurer","Confessor","Watchman","Veteran","Man at Arms","Knight Captain")
/*	var/num_vampires = rand(1,3)
#ifdef TESTSERVER
	num_vampires = 100
#endif*/
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	if(antag_candidates.len)
		var/datum/mind/vampire = pick(antag_candidates)
		var/blockme = FALSE
		if(!(vampire in allantags))
			blockme = TRUE
		if(vampire.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(blockme)
			return
		allantags -= vampire
		pre_vampires += vampire
		vampire.special_role = "vampire"
		vampire.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(vampire)] has been selected as a VAMPIRE")
		log_game("[key_name(vampire)] has been selected as a [vampire.special_role]")
		antag_candidates.Remove(vampire)
	for(var/antag in pre_vampires)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/proc/pick_werewolves()
	restricted_jobs = list("Acolyte","Priest","Adventurer","Confessor","Watchman","Veteran","Man at Arms","Knight Captain")
/*	var/num_werewolves = rand(1,3)
#ifdef TESTSERVER
	num_werewolves = 100
#endif*/
	antag_candidates = get_players_for_role(ROLE_NBEAST)
	if(antag_candidates.len)
		var/datum/mind/werewolf = pick(antag_candidates)
		var/blockme = FALSE
		if(!(werewolf in allantags))
			blockme = TRUE
		if(werewolf.assigned_role in GLOB.youngfolk_positions)
			blockme = TRUE
		if(blockme)
			return
		allantags -= werewolf
		pre_werewolves += werewolf
		werewolf.special_role = "werewolf"
		werewolf.restricted_roles = restricted_jobs.Copy()
		testing("[key_name(werewolf)] has been selected as a WEREWOLF")
		log_game("[key_name(werewolf)] has been selected as a [werewolf.special_role]")
		antag_candidates.Remove(werewolf)
	for(var/antag in pre_werewolves)
		GLOB.pre_setup_antags |= antag
	restricted_jobs = list()

/datum/game_mode/chaosmode/post_setup()
	set waitfor = FALSE
///////////////// VILLAINS
	for(var/datum/mind/traitor in pre_villains)
		var/datum/antagonist/new_antag = new /datum/antagonist/maniac()
		addtimer(CALLBACK(traitor, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(10,100))
		GLOB.pre_setup_antags -= traitor
		villains += traitor

///////////////// WWOLF
	for(var/datum/mind/werewolf in pre_werewolves)
		var/datum/antagonist/new_antag = new /datum/antagonist/werewolf()
		addtimer(CALLBACK(werewolf, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(10,100))
		GLOB.pre_setup_antags -= werewolf
		werewolves += werewolf

///////////////// VAMPIRES
	for(var/datum/mind/vampire in pre_vampires)
		var/datum/antagonist/new_antag = new /datum/antagonist/vampire()
		addtimer(CALLBACK(vampire, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(10,100))
		GLOB.pre_setup_antags -= vampire
		vampires += vampire

///////////////// BANDIT
	for(var/datum/mind/bandito in pre_bandits)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
		bandito.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= bandito
		bandits += bandito

///////////////// REBELS
	for(var/datum/mind/rebelguy in pre_rebels)
		var/datum/antagonist/new_antag = new /datum/antagonist/prebel/head()
		rebelguy.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= rebelguy

	..()
	//We're not actually ready until all traitors are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

/datum/game_mode/chaosmode/make_antag_chance(mob/living/carbon/human/character) //klatejoin
	return
/////////////////// VILLAINS
	var/num_villains = round((num_players() * 0.30)+1, 1)
	if((villains.len + pre_villains.len) >= num_villains) //Upper cap for number of latejoin antagonists
		return
	if(ROLE_MANIAC in character.client.prefs.be_special)
		if(!is_banned_from(character.ckey, list(ROLE_MANIAC)) && !QDELETED(character))
			if(age_check(character.client))
				if(!(character.job in restricted_jobs))
					if(prob(66))
						add_latejoin_villain(character.mind)

/datum/game_mode/chaosmode/proc/add_latejoin_villain(datum/mind/character)
	var/datum/antagonist/maniac/new_antag = new /datum/antagonist/maniac()
	character.add_antag_datum(new_antag)

/datum/game_mode/chaosmode/proc/vampire_werewolf()
	var/vampyr = 0
	var/wwoelf = 0
	for(var/mob/living/carbon/human/player in GLOB.human_list)
		if(player.mind)
			if(player.stat != DEAD)
				if(isbrain(player)) //also technically dead
					continue
				if(is_in_roguetown(player))
					var/datum/antagonist/D = player.mind.has_antag_datum(/datum/antagonist/werewolf)
					if(D && D.increase_votepwr)
						wwoelf++
						continue
					D = player.mind.has_antag_datum(/datum/antagonist/vampire)
					if(D && D.increase_votepwr)
						vampyr++
						continue
	if(vampyr)
		if(!wwoelf)
			return "vampire"
	if(wwoelf)
		if(!vampyr)
			return "werewolf"
*/

// Roguelite mode - the simplest version, with only bandits OR werewolves
/datum/game_mode/chaosmode/roguelite
	name = "roguelite"
	config_tag = "roguelite"
	report_type = "roguelite"
	false_report_weight = 0
	required_players = 0 // Helps it be the default mode.
	required_enemies = 0
	recommended_enemies = 0
	enemy_minimum_age = 0
	votable = 1
	probability = 99

	announce_span = "danger"
	announce_text = "The town may have been infiltrated! Watch your back..."
	
	var/chosen_antag = ""  // Will be either "bandits" or "werewolves"

// Override can_start to enforce player minimum
/datum/game_mode/chaosmode/roguelite/can_start()
	var/playerC = 0
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY)
			playerC++
	
	if(!GLOB.Debug2)
		if(playerC < required_players)
			return FALSE
	
	return TRUE

// Override pre_setup to clear any previously selected antagonists
/datum/game_mode/chaosmode/roguelite/pre_setup()
	if(allmig || roguefight)
		return TRUE
	
	// Get antagonist candidates
	for(var/A in GLOB.special_roles_rogue)
		allantags |= get_players_for_role(A)
	
	if(num_players() <= 30) // Need at least a chunk of people before we start throwing ne'er-do-wells into the mix.
		log_game("Roguelite is active, but less than 30 playercount. Antags will not be picked automatically.")
		return TRUE
	else // Randomly choose between bandits or werewolves
		if(prob(50))
			chosen_antag = "bandits"
			pick_bandits()
			log_game("Antagonists: Roguelite Mode - Bandits")
		else
			chosen_antag = "werewolves"
			pick_werewolves()
			log_game("Antagonists: Roguelite Mode - Werewolves")
		return TRUE

// Override after_DO to do nothing for roguelite
/datum/game_mode/chaosmode/roguelite/after_DO()
	if(allmig || roguefight)
		return TRUE
	
	// Do nothing - antagonists have already been chosen in pre_setup
	// This ensures we don't run the parent after_DO which might add additional antagonists
	
	return TRUE

// Override post_setup to only process the chosen antagonist type
/datum/game_mode/chaosmode/roguelite/post_setup()
	set waitfor = FALSE

	if(chosen_antag == "werewolves")
		// Process werewolves only
		for(var/datum/mind/werewolf_mind in pre_werewolves)
			var/datum/antagonist/new_antag = new /datum/antagonist/werewolf()
			werewolf_mind.add_antag_datum(new_antag)
			werewolves += werewolf_mind
			GLOB.pre_setup_antags -= werewolf_mind
		
		// Clear any bandits that might have been selected previously
		pre_bandits.Cut()

	else if(chosen_antag == "bandits")
		// Process bandits only
		for(var/datum/mind/bandito_mind in pre_bandits)
			var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
			bandito_mind.add_antag_datum(new_antag)
			bandits += bandito_mind
			GLOB.pre_setup_antags -= bandito_mind
			SSrole_class_handler.bandits_in_round = TRUE
		
		// Clear any werewolves that might have been selected previously
		pre_werewolves.Cut()

	..()
	//We're not actually ready until all antagonists are assigned.
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

// Override generate_report to provide roguelite-specific report
/datum/game_mode/chaosmode/roguelite/generate_report()
	return {"<span class='header'>Town Intelligence Report</span><br>
			<span class='alert'>Roguelite Mode</span><br>
			<span class='alert'>Recent intelligence suggests potential hostile activity in the vicinity.</span><br>
			<span class='alert'>Be vigilant and report suspicious activity to the town authorities.</span>
	"}

/datum/game_mode/chaosmode/roguemedium
	name = "roguemedium"
	config_tag = "roguemedium"
	report_type = "roguemedium"
	false_report_weight = 0
	required_players = 30 // Require at least 30 players
	required_enemies = 0
	recommended_enemies = 0
	enemy_minimum_age = 0
	votable = FALSE
	probability = 80

	announce_span = "danger"
	announce_text = "The town has been infiltrated by bandits and werewolves! Watch your back..."

// Override can_start to enforce player minimum
/datum/game_mode/chaosmode/roguemedium/can_start()
	var/playerC = 0
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY)
			playerC++
	
	if(!GLOB.Debug2)
		if(playerC < required_players)
			return FALSE
	
	return TRUE

// Override after_DO to only use bandits and werewolves
/datum/game_mode/chaosmode/roguemedium/after_DO()
	if(allmig || roguefight)
		return TRUE

	// Clear any previously selected antagonists
	pre_villains.Cut()
	pre_vampires.Cut()
	pre_rebels.Cut()

	// Select bandits
	pick_bandits()

	// Select werewolves
	pick_werewolves()

	return TRUE

/datum/game_mode/chaosmode/thiefmode
	name = "thiefmode"
	config_tag = "thiefmode"
	report_type = "thiefmode"
	false_report_weight = 0
	required_players = 0 // No minimum player count to make it easily selectable
	required_enemies = 0
	recommended_enemies = 0
	enemy_minimum_age = 0
	votable = TRUE
	probability = 75

	announce_span = "danger"
	announce_text = "Something valuable has gone missing! There may be thieves in the manor..."
	
	var/list/datum/mind/pre_thieves = list() // List to hold pre-setup thieves
	var/list/datum/mind/thieves = list() // List to hold actual thieves
	var/list/datum/mind/pre_assassins = list() // List to hold pre-setup assassins
	var/list/datum/mind/assassins = list() // List to hold actual assassins
	var/assassin_spawned = FALSE // Track if we've spawned an assassin
	var/initial_thief_count = 0 // Store the number of initial thieves selected

// Override can_start to ensure it can always start
/datum/game_mode/chaosmode/thiefmode/can_start()
	var/playerC = 0
	for(var/i in GLOB.new_player_list)
		var/mob/dead/new_player/player = i
		if(player.ready == PLAYER_READY_TO_PLAY)
			playerC++
	
	if(!GLOB.Debug2)
		if(playerC < required_players)
			return FALSE
	
	return TRUE

// Override pre_setup to select thieves
/datum/game_mode/chaosmode/thiefmode/pre_setup()
	if(allmig || roguefight)
		return TRUE
	
	// Get antagonist candidates
	for(var/A in GLOB.special_roles_rogue)
		allantags |= get_players_for_role(A)
	
	// First, decide if we'll have an assassin (25% chance)
	assassin_spawned = prob(25)
	
	// Select thieves first
	pick_thieves()
	
	// Then select assassin if applicable
	if(assassin_spawned)
		pick_assassin()
	
	return TRUE

// Override after_DO to do nothing additional
/datum/game_mode/chaosmode/thiefmode/after_DO()
	if(allmig || roguefight)
		return TRUE
	
	// No additional antagonists needed
	return TRUE

// Function to select thieves
/datum/game_mode/chaosmode/thiefmode/proc/pick_thieves()
	// Define restricted jobs - noble positions that can't be thieves
	restricted_jobs = list("Lord", "Heir", "Knight", "Lady", "Successor", "Consort", "Court Magician")
	
	var/num_thieves = 0
	var/manor_guard_count = 0 // Track the number of Manor Guards selected as thieves
	
	// Determine number of thieves based on player count
	var/player_count = num_players()
	if(player_count >= 20)
		num_thieves = 3 // 20+ players: 3 thieves
	else if(player_count >= 15)
		num_thieves = 3 // 15-19 players: 3 thieves
	else if(player_count >= 10)
		num_thieves = 2 // 10-14 players: 2 thieves
	else
		num_thieves = 1 // Less than 10 players: 1 thief
	
	// Store initial thief count for reference
	initial_thief_count = num_thieves
	
	message_admins("Thiefmode: Starting thief selection with [num_thieves] thieves needed")
	
	if(num_thieves)
		// First try to get candidates from ROLE_THIEF
		var/list/initial_candidates = get_players_for_role(ROLE_THIEF)
		
		message_admins("Thiefmode: Initial ROLE_THIEF candidates: [initial_candidates.len]")
		
		// Prepare a list to track selected thieves
		var/list/selected_thieves = list()
		
		// First pass - select thieves from ROLE_THIEF candidates
		for(var/i = 0, i < num_thieves && initial_candidates.len > 0, i++)
			var/datum/mind/thief = pick_n_take(initial_candidates)
			if(thief)
				// Check if this is a Manor Guard and if we've already selected one
				if(thief.assigned_role == "Manor Guard")
					if(manor_guard_count >= 1)
						// Skip this candidate if we already have a Manor Guard
						i-- // Don't count this attempt
						continue
					manor_guard_count++
				
				selected_thieves += thief
				message_admins("Thiefmode: Selected [thief.key] as thief #[i+1] (first pass) [thief.assigned_role == "Manor Guard" ? "(Manor Guard)" : ""]")
		
		// If we still need more thieves, get candidates from all roles
		if(selected_thieves.len < num_thieves)
			message_admins("Thiefmode: Not enough ROLE_THIEF candidates, getting candidates from all roles")
			// Get all available candidates from all roles
			var/list/all_candidates = SSticker.minds.Copy()
			
			// Remove nobles/restricted roles
			for(var/datum/mind/M in all_candidates)
				// Only check if assigned_role exists to avoid null references
				if(M.assigned_role && (M.assigned_role in restricted_jobs))
					message_admins("Thiefmode: Removing [M.key] from candidates - restricted job: [M.assigned_role]")
					all_candidates -= M
			
			// Remove already selected thieves
			for(var/datum/mind/T in selected_thieves)
				all_candidates -= T
			
			// Second pass - select remaining thieves from all available candidates
			for(var/i = selected_thieves.len, i < num_thieves && all_candidates.len > 0, i++)
				// First try to get non-Manor Guard candidates if we already have one
				if(manor_guard_count >= 1)
					var/list/non_guard_candidates = all_candidates.Copy()
					for(var/datum/mind/M in non_guard_candidates)
						if(M.assigned_role == "Manor Guard")
							non_guard_candidates -= M
					
					// If we have non-guard candidates, pick from them
					if(non_guard_candidates.len > 0)
						var/datum/mind/thief = pick_n_take(non_guard_candidates)
						selected_thieves += thief
						all_candidates -= thief
						message_admins("Thiefmode: Selected [thief.key] as thief #[i+1] (second pass)")
						continue
				
				// If we don't have a Manor Guard yet or no non-guard candidates remain, proceed with regular selection
				var/datum/mind/thief = pick_n_take(all_candidates)
				if(thief)
					// Check if this is a Manor Guard and if we've already selected one
					if(thief.assigned_role == "Manor Guard")
						if(manor_guard_count >= 1)
							// If we already have a Manor Guard, try again with a different candidate
							i-- // Don't count this attempt
							continue
						manor_guard_count++
					
					selected_thieves += thief
					message_admins("Thiefmode: Selected [thief.key] as thief #[i+1] (second pass) [thief.assigned_role == "Manor Guard" ? "(Manor Guard)" : ""]")
		
		// Set special_role for all selected thieves and add to pre_thieves list
		for(var/datum/mind/thief in selected_thieves)
			thief.special_role = "Thief"
			pre_thieves += thief
			// Try to remove from allantags if it's there
			if(thief in allantags)
				allantags -= thief
		
		message_admins("Thiefmode: Selected [pre_thieves.len] thieves in total (Manor Guards: [manor_guard_count])")
	
	// Add thieves to pre_setup_antags
	for(var/datum/mind/thief in pre_thieves)
		GLOB.pre_setup_antags |= thief
	
	// Reset restricted jobs list
	restricted_jobs = list()
	
	return TRUE

// Function to select an assassin
/datum/game_mode/chaosmode/thiefmode/proc/pick_assassin()
	// Use the same job restrictions as thieves
	restricted_jobs = list("Lord", "Heir", "Knight", "Lady", "Successor", "Consort", "Court Magician")
	
	message_admins("Thiefmode: Starting assassin selection")
	
	// First try to get candidates from ROLE_ASSASSIN, similar to how thieves use ROLE_THIEF
	var/list/initial_candidates = get_players_for_role(ROLE_ASSASSIN)
	
	// Remove any candidates already selected as thieves
	for(var/datum/mind/thief in pre_thieves)
		initial_candidates -= thief
	
	message_admins("Thiefmode: Initial ROLE_ASSASSIN candidates (excluding thieves): [initial_candidates.len]")
	
	var/datum/mind/selected_assassin = null
	
	// First pass - select assassin from appropriate candidates
	if(initial_candidates.len > 0)
		selected_assassin = pick(initial_candidates)
		message_admins("Thiefmode: Selected [selected_assassin.key] as assassin (first pass)")
	
	// If we still need an assassin, get candidates from all roles
	if(!selected_assassin)
		message_admins("Thiefmode: Not enough ROLE_ASSASSIN candidates, getting candidates from all roles")
		// Get all available candidates from all roles
		var/list/all_candidates = SSticker.minds.Copy()
		
		// Remove nobles/restricted roles
		for(var/datum/mind/M in all_candidates)
			// Only check if assigned_role exists to avoid null references
			if(M.assigned_role && (M.assigned_role in restricted_jobs))
				all_candidates -= M
		
		// Ensure we don't select any thieves as assassins
		for(var/datum/mind/T in pre_thieves)
			if(T in all_candidates)
				all_candidates -= T
		
		message_admins("Thiefmode: Available assassin candidates after excluding thieves: [all_candidates.len]")
		
		// Second pass - select assassin from all available candidates
		if(all_candidates.len > 0)
			selected_assassin = pick(all_candidates)
			message_admins("Thiefmode: Selected [selected_assassin.key] as assassin (second pass)")
	
	// Set special_role for the selected assassin and add to pre_assassins list
	if(selected_assassin)
		selected_assassin.special_role = "Assassin"
		pre_assassins += selected_assassin
		// Try to remove from allantags if it's there
		if(selected_assassin in allantags)
			allantags -= selected_assassin
		
		message_admins("Thiefmode: Successfully selected [selected_assassin.key] as assassin")
		
		// Add assassin to pre_setup_antags
		GLOB.pre_setup_antags |= selected_assassin
	else
		message_admins("Thiefmode: Failed to find a suitable assassin candidate")
		assassin_spawned = FALSE
	
	// Reset restricted jobs list
	restricted_jobs = list()
	
	return (selected_assassin != null)

// Override post_setup to process thieves and assassins
/datum/game_mode/chaosmode/thiefmode/post_setup()
	set waitfor = FALSE
	
	// Define restricted jobs again for reference
	var/list/restricted_roles = list("Lord", "Heir", "Knight", "Lady", "Successor", "Consort", "Court Magician")
	
	// Create a list to track valid thieves
	var/list/valid_thieves = list()
	var/list/rejected_thieves = list()
	var/manor_guard_count = 0 // Track Manor Guards
	
	// First pass - check all pre-selected thieves for validity
	for(var/datum/mind/thief_mind in pre_thieves)
		// Skip if it's a noble/restricted role
		var/is_restricted = FALSE
		if(thief_mind.assigned_role)
			for(var/job in restricted_roles)
				if(thief_mind.assigned_role == job)
					message_admins("Thiefmode: Rejecting thief [thief_mind.key] in post_setup - restricted job: [thief_mind.assigned_role]")
					is_restricted = TRUE
					rejected_thieves += thief_mind
					break
		
		// Check for Manor Guard limit
		if(!is_restricted && thief_mind.assigned_role == "Manor Guard")
			if(manor_guard_count >= 1)
				message_admins("Thiefmode: Rejecting thief [thief_mind.key] in post_setup - already have a Manor Guard thief")
				rejected_thieves += thief_mind
				is_restricted = TRUE
			else
				manor_guard_count++
		
		if(!is_restricted)
			valid_thieves += thief_mind
	
	// If we have rejected thieves, try to find replacements
	if(rejected_thieves.len > 0)
		message_admins("Thiefmode: Trying to find [rejected_thieves.len] replacement thieves")
		
		// Get a pool of potential replacement candidates
		var/list/replacement_candidates = SSticker.minds.Copy()
		
		// Remove players already selected as thieves
		for(var/datum/mind/T in valid_thieves)
			replacement_candidates -= T
		
		// Remove players in restricted roles
		for(var/datum/mind/M in replacement_candidates)
			// Skip if no assigned role yet
			if(!M.assigned_role)
				continue
				
			// Remove if in restricted roles
			for(var/job in restricted_roles)
				if(M.assigned_role == job)
					replacement_candidates -= M
					break
			
			// Remove Manor Guards if we already have one
			if(manor_guard_count >= 1 && M.assigned_role == "Manor Guard")
				replacement_candidates -= M
		
		// Add replacement thieves
		var/replacements_found = 0
		for(var/i = 1, i <= rejected_thieves.len && replacement_candidates.len > 0, i++)
			var/datum/mind/replacement = pick_n_take(replacement_candidates)
			if(replacement)
				// Update Manor Guard count if this is a Manor Guard
				if(replacement.assigned_role == "Manor Guard")
					manor_guard_count++
				
				valid_thieves += replacement
				replacement.special_role = "Thief"
				message_admins("Thiefmode: Found replacement thief [replacement.key] ([replacement.assigned_role])")
				replacements_found++
		
		message_admins("Thiefmode: Found [replacements_found] replacement thieves")
	
	// Process valid thieves
	message_admins("Thiefmode: Processing [valid_thieves.len] valid thieves (Manor Guards: [manor_guard_count])")
	for(var/datum/mind/thief_mind in valid_thieves)
		message_admins("Thiefmode: Processing thief [thief_mind.key] ([thief_mind.assigned_role]) in post_setup")
		var/datum/antagonist/new_antag = new /datum/antagonist/thief()
		thief_mind.add_antag_datum(new_antag)
		thieves += thief_mind
		
		// Remove from pre_setup_antags if it's there
		if(thief_mind in GLOB.pre_setup_antags)
			GLOB.pre_setup_antags -= thief_mind
	
	// Process assassin if one was selected
	if(assassin_spawned && pre_assassins.len > 0)
		// Get our assassin
		var/datum/mind/assassin_mind = pre_assassins[1]
		
		// Check if assassin is in a restricted role
		var/is_restricted = FALSE
		if(assassin_mind.assigned_role)
			for(var/job in restricted_roles)
				if(assassin_mind.assigned_role == job)
					message_admins("Thiefmode: Rejecting assassin [assassin_mind.key] in post_setup - restricted job: [assassin_mind.assigned_role]")
					is_restricted = TRUE
					break
		
		// Process valid assassin
		if(!is_restricted)
			message_admins("Thiefmode: Processing assassin [assassin_mind.key] ([assassin_mind.assigned_role]) in post_setup")
			var/datum/antagonist/new_antag = new /datum/antagonist/assassin()
			assassin_mind.add_antag_datum(new_antag)
			assassins += assassin_mind
			
			// Remove from pre_setup_antags if it's there
			if(assassin_mind in GLOB.pre_setup_antags)
				GLOB.pre_setup_antags -= assassin_mind
		else
			// Try to find a replacement assassin
			message_admins("Thiefmode: Trying to find a replacement assassin")
			
			// Get a pool of potential replacement candidates
			var/list/replacement_candidates = SSticker.minds.Copy()
			
			// Remove players already selected as thieves
			for(var/datum/mind/T in valid_thieves)
				replacement_candidates -= T
			
			// Remove players in restricted roles
			for(var/datum/mind/M in replacement_candidates)
				// Skip if no assigned role yet
				if(!M.assigned_role)
					continue
					
				// Remove if in restricted roles
				for(var/job in restricted_roles)
					if(M.assigned_role == job)
						replacement_candidates -= M
						break
			
			// Find replacement assassin
			if(replacement_candidates.len > 0)
				var/datum/mind/replacement = pick(replacement_candidates)
				if(replacement)
					message_admins("Thiefmode: Found replacement assassin [replacement.key] ([replacement.assigned_role])")
					replacement.special_role = "Assassin"
					var/datum/antagonist/new_antag = new /datum/antagonist/assassin()
					replacement.add_antag_datum(new_antag)
					assassins += replacement
			else
				message_admins("Thiefmode: Failed to find a replacement assassin")
	
	// Clear the pre-lists since we've processed all valid antagonists
	pre_thieves.Cut()
	pre_assassins.Cut()
	
	..()
	// We're not actually ready until all antagonists are assigned
	gamemode_ready = FALSE
	addtimer(VARSET_CALLBACK(src, gamemode_ready, TRUE), 101)
	return TRUE

// Override make_antag_chance to allow late joining players to become thieves
/datum/game_mode/chaosmode/thiefmode/make_antag_chance(mob/living/carbon/human/character)
	// Check if we're in thiefmode first
	if(!istype(src, /datum/game_mode/chaosmode/thiefmode))
		return
	
	// Define restricted jobs that can't be thieves
	var/list/restricted_roles = list("Lord", "Heir", "Knight", "Lady", "Successor", "Consort", "Court Magician")
	
	// Check if the character's job is restricted
	if(character.mind && character.mind.assigned_role)
		if(character.mind.assigned_role in restricted_roles)
			return
	
	// Check for antagonist bans
	if(is_banned_from(character.ckey, list(ROLE_THIEF)))
		return
		
	// Check for age restrictions
	if(!age_check(character.client))
		return
	
	// Count how many Manor Guards are already thieves
	var/manor_guard_thieves = 0
	for(var/datum/mind/T in thieves)
		if(T.assigned_role == "Manor Guard")
			manor_guard_thieves++
	
	// If this character is a Manor Guard and we already have one as a thief, don't make them a thief
	if(character.mind.assigned_role == "Manor Guard" && manor_guard_thieves >= 1)
		return
	
	// Calculate the maximum number of latejoin thieves based on player count
	var/max_latejoin_thieves = 1 // Default is 1 latejoin thief
	var/player_count = num_players()
	if(player_count >= 20)
		max_latejoin_thieves = 2 // 2 possible latejoin thieves for 20+ players
	
	// Get current thief count without counting initial thieves
	var/current_latejoin_thief_count = thieves.len - initial_thief_count
	
	// Calculate maximum total thieves (initial + latejoin)
	var/max_total_thieves = 0
	if(player_count >= 20)
		max_total_thieves = 3 + 2 // 3 initial + 2 latejoin = 5 max
	else if(player_count >= 15)
		max_total_thieves = 3 + 1 // 3 initial + 1 latejoin = 4 max
	else if(player_count >= 10)
		max_total_thieves = 2 + 1 // 2 initial + 1 latejoin = 3 max
	else
		max_total_thieves = 1 + 1 // 1 initial + 1 latejoin = 2 max
	
	// If we've already reached the maximum allowed latejoin thieves, don't add more
	if(current_latejoin_thief_count >= max_latejoin_thieves)
		return
	
	// If we've reached the maximum total thieves, don't add more
	if(thieves.len >= max_total_thieves)
		return
	
	// Check if player has ROLE_THIEF in preferences
	if(ROLE_THIEF in character.client.prefs.be_special)
		// 10% chance to become a thief
		if(prob(10))
			message_admins("Thiefmode: Adding [character.mind.key] as latejoin thief ([thieves.len+1]/[max_total_thieves] thieves; Latejoin: [current_latejoin_thief_count+1]/[max_latejoin_thieves]) [character.mind.assigned_role == "Manor Guard" ? "(Manor Guard)" : ""]")
			var/datum/antagonist/new_antag = new /datum/antagonist/thief()
			character.mind.add_antag_datum(new_antag)
			thieves += character.mind
			log_game("[key_name(character.mind)] has been selected as a latejoin thief")
