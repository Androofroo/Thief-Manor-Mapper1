// Frost Trap - requires Traps skill 4 to use
/obj/item/trap/frost_trap
	var/armed = FALSE
	var/fade_timer = null
	name = "Frost Trap"
	desc = "A cunning device that freezes intruders in a block of ice. Requires skill to arm."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "frosttrap"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "frosttrap"
	associated_skill = /datum/skill/craft/traps

/obj/item/trap/frost_trap/attack_self(mob/living/user)
	if(armed)
		to_chat(user, span_warning("The frost trap is already armed! Set it down to deploy it."))
		return
	if(!user.mind || user.mind.get_skill_level(/datum/skill/craft/traps) < 4)
		to_chat(user, span_danger("You lack the skill to arm this trap. (Traps 4 required)"))
		return
	armed = TRUE
	to_chat(user, span_notice("You carefully arm the frost trap. Set it down to deploy it!"))
	playsound(user, 'sound/foley/trap_arm.ogg', 50, FALSE)
	return

/obj/item/trap/frost_trap/dropped(mob/living/user)
	if(armed)
		var/turf/T = get_turf(src)
		if(T)
			var/obj/structure/trap/frosttrap/F = new /obj/structure/trap/frosttrap(T)
			F.alpha = 200 // Start visible
			F.fade_to_invisible()
		qdel(src)
	..()

// Custom Frost Trap Structure
/obj/structure/trap/frosttrap
	name = "frost trap"
	desc = "A nearly invisible trap that freezes those who step on it."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "frosttrap"
	trap_item_type = /obj/item/trap/frost_trap

/obj/structure/trap/frosttrap/Crossed(AM as mob|obj)
	if(isturf(loc))
		if(isliving(AM))
			var/mob/living/L = AM
			// Only freeze, no damage, no embedding
			to_chat(L, span_danger("<B>You step on a frost trap and are frozen solid in a block of ice!</B>"))
			L.Paralyze(300)
			L.adjust_bodytemperature(-300)
			L.apply_status_effect(/datum/status_effect/freon)
			visible_message(span_danger("[L] is encased in ice by a frost trap!"), span_danger("I am encased in ice by a frost trap!"))
			alpha = 255
			icon_state = "frosttrap"
			playsound(src.loc, 'sound/items/beartrap.ogg', 100, TRUE, -1)
	..()

// Engineer's Wrench
/obj/item/rogueweapon/engineers_wrench
	name = "engineer's wrench"
	desc = "A heavy, specialized wrench for trap maintenance. Can reset trap cooldowns or recover traps."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "wrench"
	w_class = WEIGHT_CLASS_TINY
	force = 10
	throwforce = 10
	max_blade_int = 100
	max_integrity = 125
	gripped_intents = null
	minstr = 4
	wdefense = 6
	item_state = "wrench"
	possible_item_intents = list(/datum/intent/use, /datum/intent/mace/strike)

// Define an attackby for the base trap type to handle the engineer's wrench
/obj/structure/trap/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/rogueweapon/engineers_wrench))
		// Recover the trap as an item
		if(hasvar(src, "trap_item_type"))
			var/item_type = src:trap_item_type
			if(item_type)
				var/turf/T = get_turf(src)
				new item_type(T)
				to_chat(user, span_notice("You reset and recover [src] as a trap item."))
				playsound(user, 'thiefmanor/sound/wrench.ogg', 100, FALSE)
				qdel(src)
				return TRUE
			else
				to_chat(user, span_warning("This trap cannot be recovered as an item with the engineer's wrench."))
				playsound(user, 'thiefmanor/sound/wrench.ogg', 100, FALSE)
				return FALSE
		else
			to_chat(user, span_warning("This trap cannot be recovered as an item with the engineer's wrench."))
			playsound(user, 'thiefmanor/sound/wrench.ogg', 100, FALSE)
			return FALSE
	
	return ..()

// Define the fade_to_invisible proc at the parent level so all traps can use it
/obj/structure/trap/proc/fade_to_invisible(fade_time = 100)
	// Animate alpha from 200 to 10 over the specified time (10 seconds by default)
	animate(src, alpha = 10, time = fade_time)

// Tripwire Bell - requires Traps skill 3 to use
/obj/item/trap/tripwire_bell
	var/armed = FALSE
	var/fade_timer = null
	name = "Tripwire Bell"
	desc = "A cunning trap that creates a loud sound when stepped on. Requires skill to arm."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "belltrap"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "belltrap"
	associated_skill = /datum/skill/craft/traps

/obj/item/trap/tripwire_bell/attack_self(mob/living/user)
	if(armed)
		to_chat(user, span_warning("The tripwire bell is already armed! Set it down to deploy it."))
		return
	if(!user.mind || user.mind.get_skill_level(/datum/skill/craft/traps) < 3)
		to_chat(user, span_danger("You lack the skill to arm this trap. (Traps 3 required)"))
		return
	armed = TRUE
	to_chat(user, span_notice("You carefully arm the tripwire bell. Set it down to deploy it!"))
	playsound(user, 'sound/foley/trap_arm.ogg', 50, FALSE)
	return

/obj/item/trap/tripwire_bell/dropped(mob/living/user)
	if(armed)
		var/turf/T = get_turf(src)
		if(T)
			var/obj/structure/trap/tripwire_bell/F = new /obj/structure/trap/tripwire_bell(T)
			F.alpha = 200 // Start visible
			F.fade_to_invisible()
		qdel(src)
	..()

// Custom Tripwire Bell Structure
/obj/structure/trap/tripwire_bell
	name = "tripwire bell"
	desc = "A nearly invisible tripwire connected to a bell."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "belltrap"
	trap_item_type = /obj/item/trap/tripwire_bell

/obj/structure/trap/tripwire_bell/Crossed(AM as mob|obj)
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(AM, ignore_typecache))
		return
	if(ismob(AM))
		var/mob/M = AM
		if(M.mind in immune_minds)
			return
		if(checks_antimagic && M.anti_magic_check())
			flare()
			return
	if(charges <= 0)
		return
		
	// Get the area name for the alert
	var/area/trap_area = get_area(src)
	var/area_name = trap_area?.name || "unknown area"
	
	// Trigger the bell sound and alert
	flare()
	if(isliving(AM))
		playsound(src.loc, 'sound/misc/bell.ogg', 100, TRUE, -1)
		visible_message(span_warning("[src] rings loudly as someone trips over the wire!"))
		
		// Send an alert to everyone
		for(var/mob/M in GLOB.player_list)
			to_chat(M, span_warningbig("You hear a loud burglar alarm bell ring from [area_name]!"))
	..()

// Fire Trap - requires Traps skill 5 to use
/obj/item/trap/fire_trap
	var/armed = FALSE
	var/fade_timer = null
	name = "Fire Trap"
	desc = "A vicious trap that ignites victims in a burst of intense flame. Requires high skill to arm."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "firetrap"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "firetrap"
	associated_skill = /datum/skill/craft/traps

/obj/item/trap/fire_trap/attack_self(mob/living/user)
	if(armed)
		to_chat(user, span_warning("The fire trap is already armed! Set it down to deploy it."))
		return
	if(!user.mind || user.mind.get_skill_level(/datum/skill/craft/traps) < 4)
		to_chat(user, span_danger("You lack the skill to arm this trap. (Traps 4 required)"))
		return
	armed = TRUE
	to_chat(user, span_notice("You carefully arm the fire trap. Set it down to deploy it!"))
	playsound(user, 'sound/foley/trap_arm.ogg', 50, FALSE)
	return

/obj/item/trap/fire_trap/dropped(mob/living/user)
	if(armed)
		var/turf/T = get_turf(src)
		if(T)
			var/obj/structure/trap/firetrap/F = new /obj/structure/trap/firetrap(T)
			F.alpha = 200 // Start visible
			F.fade_to_invisible()
		qdel(src)
	..()

// Custom Fire Trap Structure
/obj/structure/trap/firetrap
	name = "fire trap"
	desc = "A nearly invisible trap that erupts in flames when triggered."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "firetrap"
	trap_item_type = /obj/item/trap/fire_trap

/obj/structure/trap/firetrap/Crossed(AM as mob|obj)
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(AM, ignore_typecache))
		return
	if(ismob(AM))
		var/mob/M = AM
		if(M.mind in immune_minds)
			return
		if(checks_antimagic && M.anti_magic_check())
			flare()
			return
	if(charges <= 0)
		return
	
	// Trigger the fire trap
	flare()
	if(isliving(AM))
		var/mob/living/L = AM
		// Apply fire damage and fire effects
		to_chat(L, span_danger("<B>You step on a fire trap and are engulfed in a burst of flames!</B>"))
		L.Paralyze(100) // Shorter stun than the frost trap
		L.adjust_fire_stacks(3)
		L.IgniteMob()
		L.adjustFireLoss(20)
		visible_message(span_danger("[L] is engulfed in flames from a fire trap!"), span_danger("I am engulfed in flames from a fire trap!"))
		alpha = 255
		icon_state = "firetrap"
		playsound(src.loc, 'sound/magic/fireball.ogg', 100, TRUE, -1)
		// Create fire effect on the tile
		new /obj/effect/hotspot(get_turf(src))
	..()

// Pepper Trap - requires Traps skill 4 to use
/obj/item/trap/pepper_trap
	var/armed = FALSE
	var/fade_timer = null
	name = "Pepper Trap"
	desc = "A nasty trap that releases a cloud of pepper spray when triggered. Requires skill to arm."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "peppertrap"
	w_class = WEIGHT_CLASS_SMALL
	item_state = "peppertrap"
	associated_skill = /datum/skill/craft/traps

/obj/item/trap/pepper_trap/attack_self(mob/living/user)
	if(armed)
		to_chat(user, span_warning("The pepper trap is already armed! Set it down to deploy it."))
		return
	if(!user.mind || user.mind.get_skill_level(/datum/skill/craft/traps) < 4)
		to_chat(user, span_danger("You lack the skill to arm this trap. (Traps 4 required)"))
		return
	armed = TRUE
	to_chat(user, span_notice("You carefully arm the pepper trap. Set it down to deploy it!"))
	playsound(user, 'sound/foley/trap_arm.ogg', 50, FALSE)
	return

/obj/item/trap/pepper_trap/dropped(mob/living/user)
	if(armed)
		var/turf/T = get_turf(src)
		if(T)
			var/obj/structure/trap/peppertrap/F = new /obj/structure/trap/peppertrap(T)
			F.alpha = 200 // Start visible
			F.fade_to_invisible()
		qdel(src)
	..()

// Custom Pepper Trap Structure
/obj/structure/trap/peppertrap
	name = "pepper trap"
	desc = "A nearly invisible trap that releases a cloud of irritating pepper spray when triggered."
	icon = 'thiefmanor/icons/misc2.dmi'
	icon_state = "peppertrap"
	trap_item_type = /obj/item/trap/pepper_trap

/obj/structure/trap/peppertrap/Crossed(AM as mob|obj)
	if(last_trigger + time_between_triggers > world.time)
		return
	// Don't want the traps triggered by sparks, ghosts or projectiles.
	if(is_type_in_typecache(AM, ignore_typecache))
		return
	if(ismob(AM))
		var/mob/M = AM
		if(M.mind in immune_minds)
			return
		if(checks_antimagic && M.anti_magic_check())
			flare()
			return
	if(charges <= 0)
		return
	
	// Trigger the pepper trap
	flare()
	if(isliving(AM))
		// Create the pepper spray cloud - using chemical smoke system
		var/datum/effect_system/smoke_spread/chem/S = new
		var/obj/chemholder = new /obj()
		var/datum/reagents/R = new/datum/reagents(15) // Small amount of reagents
		chemholder.reagents = R
		R.my_atom = chemholder
		// Add capsaicin to the chemical holder
		R.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 50)
		
		// Set up and start the smoke
		S.chemholder = chemholder
		S.set_up(R, 2, get_turf(src), 0)
		S.start()
		
		// Visual and sound effects
		visible_message(span_danger("A cloud of irritating pepper spray erupts from [src]!"))
		playsound(src.loc, 'sound/items/smokebomb.ogg', 70, TRUE, -3)
		alpha = 255
	..()
