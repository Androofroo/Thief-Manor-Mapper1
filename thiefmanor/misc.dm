// Arcane Vault - an indestructible container that requires a special key
/obj/structure/arcane_vault
	name = "Arcyne Armor Display"
	desc = "An arcyne ornate display case with complex magical seals. It requires a special key to open, and is virtually indestructible."
	icon = 'thiefmanor/icons/misc.dmi'
	icon_state = "display0"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF | FREEZE_PROOF
	var/opened = FALSE
	var/locked = TRUE

/obj/structure/arcane_vault/Initialize()
	. = ..()
	// Apply scaling to reduce the sprite size by half
	transform = matrix().Scale(0.5, 0.5)
	// Center the sprite by adjusting pixel offsets
	pixel_x = -8
	pixel_y = -8  
	pixel_z = -8

/obj/structure/arcane_vault/examine(mob/user)
	. = ..()
	if(opened)
		. += span_notice("The display case stands open, its magical seals broken.")
	else if(locked)
		. += span_warning("The display case is firmly sealed with powerful magic. It requires a special key.")
	else
		. += span_notice("The display case is unlocked but still closed.")

/obj/structure/arcane_vault/attackby(obj/item/W, mob/user, params)
	if(opened)
		to_chat(user, span_warning("The display case is already open."))
		return

	if(istype(W, /obj/item/treasure/key))
		if(!locked)
			to_chat(user, span_warning("The display case is already unlocked."))
			return

		user.visible_message(
			span_notice("[user] inserts [W] into the keyhole of [src]."),
			span_notice("You insert [W] into the keyhole. The key begins to glow with an eerie light as magical symbols around the display case illuminate.")
		)
		
		// Play a sound effect and add visual effect
		playsound(src, 'sound/magic/churn.ogg', 70, TRUE)
		
		// Create visual effects
		var/number_of_sparkles = 5
		for(var/i in 1 to number_of_sparkles)
			var/obj/effect/temp_visual/parchment_reveal/spark = new(get_turf(src))
			spark.pixel_x = rand(-16, 16)
			spark.pixel_y = rand(-16, 16)
			spark.color = pick("#ffd700", "#8A2BE2", "#36C5F0") // Gold, purple, blue
		
		if(!do_after(user, 30, target = src))
			to_chat(user, span_warning("You need to hold the key steady!"))
			return
			
		locked = FALSE
		
		// Key is consumed
		to_chat(user, span_notice("The key dissolves into golden light as the vault's magical seals break."))
		qdel(W)
		
		// Open the vault
		open_vault()
		
		return TRUE
		
	// For any other interaction, just default behavior
	return ..()

/obj/structure/arcane_vault/attack_hand(mob/user)
	. = ..()
	if(.)
		return
		
	if(opened)
		to_chat(user, span_notice("The vault stands open, its magical contents already retrieved."))
		return
		
	if(locked)
		to_chat(user, span_warning("The vault is firmly sealed with powerful magic. You can't open it without the proper key."))
		playsound(src, 'sound/foley/doors/lockrattle.ogg', 25, TRUE)
		return
		
	// If it's unlocked but not opened yet
	open_vault()
	return TRUE

/obj/structure/arcane_vault/proc/open_vault()
	if(opened)
		return
		
	opened = TRUE
	icon_state = "display1"
	
	// Create visual and sound effects
	playsound(src, 'sound/magic/swap.ogg', 100, TRUE)
	
	// Spawn the armor
	new /obj/item/clothing/suit/roguetown/armor/plate/kassarmor(get_turf(src))
	
	// Create a special visual effect for the armor's appearance
	var/obj/effect/temp_visual/lens_shimmer/shimmer = new(get_turf(src))
	shimmer.color = "#FF6347" // Reddish shimmer for Kassidy's armor
	
	// Update the description
	desc = "An ancient, ornate vault with broken magical seals. It stands open, having yielded its treasure: Kassidy's armor."
	
	visible_message(span_notice("The [src] opens with a flash of light, revealing Kassidy's armor inside!"))
