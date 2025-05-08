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

/obj/structure/trap/frosttrap/proc/fade_to_invisible()
	// Animate alpha from 200 to 30 over 10 seconds
	animate(src, alpha = 30, time = 100)

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

/obj/item/rogueweapon/engineers_wrench/afterattack(atom/target, mob/user, proximity, click_parameters)
	return ..()

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
