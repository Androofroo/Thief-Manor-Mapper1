GLOBAL_LIST_EMPTY(active_alternate_appearances)

/atom/proc/remove_alt_appearance(key)
	if(alternate_appearances)
		for(var/K in alternate_appearances)
			var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[K]
			if(AA.appearance_key == key)
				AA.remove_from_hud(src)
				break

/atom/proc/add_alt_appearance(type, key, ...)
	if(!type || !key)
		return
	if(alternate_appearances && alternate_appearances[key])
		return
	var/list/arguments = args.Copy(2)
	new type(arglist(arguments))

/datum/atom_hud/alternate_appearance
	var/appearance_key
	var/transfer_overlays = FALSE

/datum/atom_hud/alternate_appearance/New(key)
	..()
	GLOB.active_alternate_appearances += src
	appearance_key = key

/datum/atom_hud/alternate_appearance/Destroy()
	GLOB.active_alternate_appearances -= src
	return ..()

/datum/atom_hud/alternate_appearance/proc/onNewMob(mob/M)
	if(mobShouldSee(M))
		add_hud_to(M)

/datum/atom_hud/alternate_appearance/proc/mobShouldSee(mob/M)
	return FALSE

/datum/atom_hud/alternate_appearance/add_to_hud(atom/A, image/I)
	. = ..()
	if(.)
		LAZYINITLIST(A.alternate_appearances)
		A.alternate_appearances[appearance_key] = src

/datum/atom_hud/alternate_appearance/remove_from_hud(atom/A)
	. = ..()
	if(.)
		LAZYREMOVE(A.alternate_appearances, appearance_key)

/datum/atom_hud/alternate_appearance/proc/copy_overlays(atom/other, cut_old)
	return

//an alternate appearance that attaches a single image to a single atom
/datum/atom_hud/alternate_appearance/basic
	var/atom/target
	var/image/theImage
	var/add_ghost_version = FALSE
	var/ghost_appearance

/datum/atom_hud/alternate_appearance/basic/New(key, image/I, options = AA_TARGET_SEE_APPEARANCE)
	..()
	transfer_overlays = options & AA_MATCH_TARGET_OVERLAYS
	theImage = I
	target = I.loc
	if(transfer_overlays)
		I.copy_overlays(target)

	hud_icons = list(appearance_key)
	add_to_hud(target, I)
	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)
	if(add_ghost_version)
		var/image/ghost_image = image(icon = I.icon , icon_state = I.icon_state, loc = I.loc)
		ghost_image.override = FALSE
		ghost_image.alpha = 128
		ghost_appearance = new /datum/atom_hud/alternate_appearance/basic/observers(key + "_observer", ghost_image, NONE)

/datum/atom_hud/alternate_appearance/basic/Destroy()
	. = ..()
	if(ghost_appearance)
		QDEL_NULL(ghost_appearance)

/datum/atom_hud/alternate_appearance/basic/add_to_hud(atom/A)
	LAZYINITLIST(A.hud_list)
	A.hud_list[appearance_key] = theImage
	. = ..()

/datum/atom_hud/alternate_appearance/basic/remove_from_hud(atom/A)
	. = ..()
	A.hud_list -= appearance_key
	if(. && !QDELETED(src))
		qdel(src)

/datum/atom_hud/alternate_appearance/basic/copy_overlays(atom/other, cut_old)
		theImage.copy_overlays(other, cut_old)

/datum/atom_hud/alternate_appearance/basic/everyone
	add_ghost_version = TRUE

/datum/atom_hud/alternate_appearance/basic/everyone/New()
	..()
	for(var/mob in GLOB.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/everyone/mobShouldSee(mob/M)
	return !isobserver(M)

/datum/atom_hud/alternate_appearance/basic/observers
	add_ghost_version = FALSE //just in case, to prevent infinite loops

/datum/atom_hud/alternate_appearance/basic/observers/New()
	..()
	for(var/mob in GLOB.dead_mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/observers/mobShouldSee(mob/M)
	return isobserver(M)

/datum/atom_hud/alternate_appearance/basic/blessedAware

/datum/atom_hud/alternate_appearance/basic/blessedAware/New()
	..()
	for(var/mob in GLOB.mob_list)
		if(mobShouldSee(mob))
			add_hud_to(mob)

/datum/atom_hud/alternate_appearance/basic/blessedAware/mobShouldSee(mob/M)
	if(M.mind && (M.mind.assigned_role == "Chaplain"))
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/onePerson
	var/mob/seer

/datum/atom_hud/alternate_appearance/basic/onePerson/mobShouldSee(mob/M)
	if(M == seer)
		return TRUE
	return FALSE

/datum/atom_hud/alternate_appearance/basic/onePerson/New(key, image/I, mob/living/M)
	..(key, I, FALSE)
	seer = M
	add_hud_to(seer)

// A more comprehensive alternate appearance that copies all visual aspects
// including race features, hair, and customizer options
/datum/atom_hud/alternate_appearance/comprehensive
	var/atom/target
	var/atom/disguise_source
	var/mob/appearance_holder
	var/skip_updates = FALSE

/datum/atom_hud/alternate_appearance/comprehensive/New(key, atom/disguise_target, mob/living/carbon/human/holder, options = AA_TARGET_SEE_APPEARANCE)
	..()
	disguise_source = disguise_target
	appearance_holder = holder
	target = holder
	
	// Create a comprehensive image that copies all aspects
	var/image/I = image(disguise_source.appearance, loc = holder)
	I.override = TRUE
	I.appearance_flags = KEEP_TOGETHER | TILE_BOUND | PIXEL_SCALE | LONG_GLIDE
	
	// Add the image to the hud
	hud_icons = list(appearance_key)
	add_to_hud(target, I)
	
	// Make the target see this appearance
	if((options & AA_TARGET_SEE_APPEARANCE) && ismob(target))
		add_hud_to(target)
	
	// Add all observers to see this appearance too
	for(var/mob/dead/observer/observer in GLOB.dead_mob_list)
		add_hud_to(observer)
	
	// Add everyone in the world to see this
	for(var/mob/living/L in GLOB.mob_list)
		if(!isobserver(L))
			add_hud_to(L)

/datum/atom_hud/alternate_appearance/comprehensive/proc/update_appearance()
	if(skip_updates || !target || !disguise_source || !appearance_holder)
		return
	
	// Update the image with the current source appearance
	var/image/I = image(disguise_source.appearance, loc = appearance_holder)
	I.override = TRUE
	I.appearance_flags = KEEP_TOGETHER | TILE_BOUND | PIXEL_SCALE | LONG_GLIDE
	
	// Force the hud to update
	LAZYINITLIST(target.hud_list)
	target.hud_list[appearance_key] = I
	
	// Need to call process updates to ensure everyone sees the new appearance
	for(var/mob/M in get_all_huds())
		if(M.client)
			M.client.images -= target.hud_list[appearance_key]
			M.client.images += I

/datum/atom_hud/alternate_appearance/comprehensive/proc/get_all_huds()
	return hudusers

/datum/atom_hud/alternate_appearance/comprehensive/Destroy()
	skip_updates = TRUE
	target = null
	disguise_source = null
	appearance_holder = null
	return ..()

// Extension of standard atom proc to support the comprehensive system
/atom/proc/add_comprehensive_appearance(key, atom/disguise_source, options = AA_TARGET_SEE_APPEARANCE)
	if(!isliving(src))
		return FALSE
	
	if(!key || !disguise_source)
		return FALSE
		
	if(alternate_appearances && alternate_appearances[key])
		var/datum/atom_hud/alternate_appearance/AA = alternate_appearances[key]
		if(istype(AA, /datum/atom_hud/alternate_appearance/comprehensive))
			var/datum/atom_hud/alternate_appearance/comprehensive/CA = AA
			CA.disguise_source = disguise_source
			CA.update_appearance()
			return CA
			
	var/datum/atom_hud/alternate_appearance/comprehensive/AA = new(key, disguise_source, src, options)
	return AA
