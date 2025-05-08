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
			var/obj/structure/trap/frosttrap/S = new /obj/structure/trap/frosttrap(T)
			S.fade_to_invisible()
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
			to_chat(L, span_danger("<B>You step on a frost trap and are frozen solid in a block of ice!</B>"))
			L.Paralyze(300)
			L.adjust_bodytemperature(-300)
			L.apply_status_effect(/datum/status_effect/freon)
			visible_message(span_danger("[L] is encased in ice by a frost trap!"), span_danger("I am encased in ice by a frost trap!"))
			invisibility = 0
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
			var/obj/structure/trap/tripwire_bell/S = new /obj/structure/trap/tripwire_bell(T)
			S.fade_to_invisible()
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
	flare()
	if(isliving(AM))
		playsound(src.loc, 'sound/misc/bell.ogg', 100, TRUE, -1)
		visible_message(span_warning("[src] rings loudly as someone trips over the wire!"))
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
			var/obj/structure/trap/firetrap/S = new /obj/structure/trap/firetrap(T)
			S.fade_to_invisible()
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
	flare()
	if(isliving(AM))
		var/mob/living/L = AM
		to_chat(L, span_danger("<B>You step on a fire trap and are engulfed in a burst of flames!</B>"))
		L.Paralyze(100)
		L.adjust_fire_stacks(3)
		L.IgniteMob()
		L.adjustFireLoss(20)
		visible_message(span_danger("[L] is engulfed in flames from a fire trap!"), span_danger("I am engulfed in flames from a fire trap!"))
		icon_state = "firetrap"
		playsound(src.loc, 'sound/magic/fireball.ogg', 100, TRUE, -1)
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
			var/obj/structure/trap/peppertrap/S = new /obj/structure/trap/peppertrap(T)
			S.fade_to_invisible()
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
	flare()
	if(isliving(AM))
		var/datum/effect_system/smoke_spread/chem/S = new
		var/obj/chemholder = new /obj()
		var/datum/reagents/R = new/datum/reagents(15)
		chemholder.reagents = R
		R.my_atom = chemholder
		R.add_reagent(/datum/reagent/consumable/condensedcapsaicin, 50)
		S.chemholder = chemholder
		S.set_up(R, 2, get_turf(src), 0)
		S.start()
		visible_message(span_danger("A cloud of irritating pepper spray erupts from [src]!"))
		playsound(src.loc, 'sound/items/smokebomb.ogg', 70, TRUE, -3)
	..()

// Trap Goggles - special eyewear that allows the wearer to see traps even when they've faded to invisible
/obj/item/clothing/glasses/trap_goggles
	name = "trap detection goggles"
	desc = "A special pair of goggles designed to reveal hidden traps. Perfect for disarming or avoiding them."
	resistance_flags = FIRE_PROOF
	slot_flags = ITEM_SLOT_MASK
	body_parts_covered = EYES
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/masks.dmi'
	icon = 'icons/roguetown/clothing/masks.dmi'
	icon_state = "goggles"
	item_state = "goggles"
	darkness_view = 8
	var/see_traps = TRUE
	var/static/list/active_users = list()
	var/refresh_timer_id = null

/obj/item/clothing/glasses/trap_goggles/equipped(mob/user, slot)
	. = ..()
	if(slot == 8)
		LAZYADD(active_users, user)
		enable_trap_vision(user)
		refresh_timer_id = addtimer(CALLBACK(src, PROC_REF(refresh_trap_vision), user), 50, TIMER_STOPPABLE|TIMER_LOOP)
		
/obj/item/clothing/glasses/trap_goggles/dropped(mob/user)
	LAZYREMOVE(active_users, user)
	disable_trap_vision(user)
	if(refresh_timer_id)
		deltimer(refresh_timer_id)
		refresh_timer_id = null
	return ..()

/obj/item/clothing/glasses/trap_goggles/proc/enable_trap_vision(mob/user)
	if(!user || !user.client)
		return
	
	disable_trap_vision(user)
	
	if(!user.trap_highlight_list)
		user.trap_highlight_list = list()
	
	var/view_range = 7
	var/turf/user_turf = get_turf(user)
	
	for(var/obj/structure/trap/T in view(view_range, user_turf))
		var/obj/effect/trap_highlight/existing = null
		for(var/obj/effect/trap_highlight/H in get_turf(T))
			if(H.parent_trap == T)
				existing = H
				break
		
		if(!existing)
			existing = new /obj/effect/trap_highlight(get_turf(T), T)
			
		existing.visible_to |= user
		user.trap_highlight_list |= existing

/obj/item/clothing/glasses/trap_goggles/proc/disable_trap_vision(mob/user)
	if(!user)
		return
	
	if(!user.trap_highlight_list)
		return
		
	for(var/obj/effect/trap_highlight/H in user.trap_highlight_list)
		H.visible_to -= user
		if(!length(H.visible_to))
			qdel(H)
	
	user.trap_highlight_list.Cut()
	user.trap_highlight_list = null

/obj/item/clothing/glasses/trap_goggles/proc/refresh_trap_vision(mob/user)
	if(QDELETED(src) || QDELETED(user) || !user.client)
		if(refresh_timer_id)
			deltimer(refresh_timer_id)
			refresh_timer_id = null
		return
		
	enable_trap_vision(user)

/obj/structure/trap/proc/set_invisible()
	alpha = 0

/obj/structure/trap/proc/fade_to_invisible()
	// Properly fade the trap using animate() over 10 seconds
	// This is more reliable than using sleep()
	alpha = 255  // Ensure we start fully visible
	animate(src, alpha = 0, time = 10 SECONDS, easing = SINE_EASING)

/obj/structure/trap/flare()
	alpha = 255
	visible_message(flare_message)
	if(sparks)
		spark_system.start()
	last_trigger = world.time
	charges--
	if(charges <= 0)
		QDEL_IN(src, 10)
	else
		fade_to_invisible()

// Define the variable for mobs
/mob/var/list/trap_highlight_list = null

// Create a helper object to use with visibility
/obj/effect/trap_highlight
	name = "trap highlight"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"  // Invisible state
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = 100
	plane = 30
	
	// Store a reference to the original trap
	var/obj/structure/trap/parent_trap = null
	
	// Track which users can see it
	var/list/visible_to = list()
	
/obj/effect/trap_highlight/Initialize(mapload, obj/structure/trap/T)
	. = ..()
	if(T)
		parent_trap = T
		// Use the trap's icon and state
		icon = T.icon
		icon_state = T.icon_state
		// Set appearance for visibility
		alpha = 255
		appearance_flags = RESET_ALPHA|RESET_TRANSFORM|KEEP_APART|TILE_BOUND
		// Position exactly at the trap
		forceMove(get_turf(T))
		
		// Set up a timer to follow the trap if it moves
		START_PROCESSING(SSobj, src)
		
/obj/effect/trap_highlight/process()
	if(QDELETED(parent_trap))
		// Parent trap is gone, destroy self
		qdel(src)
		return
		
	// Only move if the parent trap exists and has a valid turf
	var/turf/trap_turf = get_turf(parent_trap)
	if(trap_turf && get_turf(src) != trap_turf)
		forceMove(trap_turf)

/obj/effect/trap_highlight/Destroy()
	STOP_PROCESSING(SSobj, src)
	parent_trap = null
	visible_to.Cut()
	return ..()

/obj/effect/trap_highlight/examine(mob/user)
	if(parent_trap)
		return parent_trap.examine(user)
	return ..()

// For each mob that can see the trap, we'll directly modify how their client perceives the trap
/obj/effect/trap_highlight/proc/hide_from_all_except(list/users)
	// Store the users who should be able to see this
	visible_to = users

// Override canSee to control visibility (if implemented in the codebase)
/obj/effect/trap_highlight/proc/can_be_seen_by(mob/M)
	return (M in visible_to)
