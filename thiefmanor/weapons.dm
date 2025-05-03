//lamplighter's pole - a special tool to light rogue lights
/datum/intent/lamplight
	name = "light"
	icon_state = "inuse"
	attack_verb = list("touches")
	animname = "use"
	blade_class = BCLASS_BLUNT
	chargetime = 0
	noaa = TRUE
	misscost = 0
	no_attack = TRUE
	item_d_type = "blunt"

#define LAMPLIGHT_USE /datum/intent/lamplight

/obj/item/rogueweapon/lamplightpole
	name = "lamplighter's pole"
	desc = "A long pole with a small flame at the end, used to light various lamps and torches around the manor."
	icon = 'icons/roguetown/weapons/64.dmi'
	icon_state = "lamplighter"
	force = 5
	possible_item_intents = list(LAMPLIGHT_USE)
	gripped_intents = null // Not grippable
	wlength = WLENGTH_GREAT
	w_class = WEIGHT_CLASS_BULKY
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	bigboy = TRUE
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = FIRE_PROOF

/obj/item/rogueweapon/lamplightpole/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	
	if(istype(target, /obj/machinery/light/rogue))
		var/obj/machinery/light/rogue/light = target
		if(!light.on && ((light.fueluse > 0) || (initial(light.fueluse) == 0)))
			playsound(light.loc, 'sound/items/firelight.ogg', 100)
			light.on = TRUE
			light.update()
			light.update_icon()
			if(light.soundloop)
				light.soundloop.start()
			addtimer(CALLBACK(light, TYPE_PROC_REF(/obj/machinery/light/rogue, trigger_weather)), rand(5,20))
			user.visible_message("<span class='notice'>[user] lights [light] with [src].</span>", 
								"<span class='notice'>You light [light] with [src].</span>")
			return TRUE

/obj/item/rogueweapon/lamplightpole/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -6,"sy" = 6,"nx" = 6,"ny" = 7,"wx" = 0,"wy" = 5,"ex" = -1,"ey" = 7,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -50,"sturn" = 40,"wturn" = 50,"eturn" = -50,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("onbelt")
				return list("shrink" = 0.3,"sx" = -2,"sy" = -5,"nx" = 4,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = 2,"ey" = -5,"nturn" = 0,"sturn" = 0,"wturn" = 0,"eturn" = 0,"nflip" = 0,"sflip" = 0,"wflip" = 0,"eflip" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0)
