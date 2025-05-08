/client
	var/list/hidden_atoms = list()
	var/list/hidden_mobs = list()
	var/list/hidden_images = list()

/mob
	var/fovangle

/mob/living/carbon/human
	fovangle = FOV_DEFAULT

//Procs
/atom/proc/InCone(atom/center = usr, dir = NORTH)
	if(get_dist(center, src) == 0 || src == center) return 0
	var/d = get_dir(center, src)
	if(!d || d == dir) return 1
	if(dir & (dir-1))
		return (d & ~dir) ? 0 : 1
	if(!(d & dir)) return 0
	var/dx = abs(x - center.x)
	var/dy = abs(y - center.y)
	if(dx == dy) return 1
	if(dy > dx)
		return (dir & (NORTH|SOUTH)) ? 1 : 0
	return (dir & (EAST|WEST)) ? 1 : 0

/mob/dead/InCone(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/proc/cone(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.InCone(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list


/mob/dead/BehindAtom(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/atom/proc/BehindAtom(atom/center = usr, dir = NORTH) //Returns TRUE if center is behind src
	switch(dir)
		if(NORTH)
			if(y > center.y)
				return 1
		if(SOUTH)
			if(y < center.y)
				return 1
		if(EAST)
			if(x > center.x)
				return 1
		if(WEST)
			if(x < center.x)
				return 1

/proc/behind(atom/center = usr, dirs, list/list = oview(center))
	for(var/atom/A in list)
		var/fou
		for(var/D in dirs)
			if(A.BehindAtom(center, D))
				fou = TRUE
				break
		if(!fou)
			list -= A
	return list

/mob/proc/update_vision_cone()
	if(client)
		if(hud_used && hud_used.fov)
			hud_used.fov.dir = src.dir
			hud_used.fov_blocker.dir = src.dir
		START_PROCESSING(SSincone, client)

/mob/proc/update_cone(force = FALSE)
	return

/client/proc/update_cone(force = FALSE)
	if(mob)
		mob.update_cone(force)

/mob/living/update_cone(force = FALSE)
	if(!client)
		return

	// Create a new hidden image system that works more reliably
	// First, clear all hidden things
	for(var/image/I in client.images)
		if(I in client.hidden_images)
			client.images -= I
	client.hidden_images.Cut()
	client.hidden_atoms.Cut()
	client.hidden_mobs.Cut()
	
	if(hud_used?.fov && !force)
		if(hud_used.fov.alpha == 0)
			return
	
	// Handle self image
	var/image/I = image(src, src)
	I.override = 1
	I.plane = GAME_PLANE_UPPER
	I.layer = layer
	I.appearance_flags = RESET_TRANSFORM|KEEP_TOGETHER|PIXEL_SCALE
	client.hidden_images += I
	client.images += I
	
	// Handle buckled and pulling visibility (standard)
	if(buckled)
		var/image/IB = image(buckled, buckled)
		IB.override = 1
		IB.plane = GAME_PLANE_UPPER
		IB.layer = IB.layer
		IB.appearance_flags = RESET_TRANSFORM|KEEP_TOGETHER
		client.hidden_images += IB
		client.images += IB
	if(pulling)
		var/image/IP = image(pulling, pulling)
		IP.override = 1
		IP.plane = GAME_PLANE_UPPER
		IP.layer = IP.layer
		IP.appearance_flags = RESET_TRANSFORM|KEEP_TOGETHER
		client.hidden_images += IP
		client.images += IP
	
	// NEW APPROACH: Process all mobs in view and determine visibility
	var/list/all_visible_mobs = view(client.view, src)
	for(var/mob/living/L in all_visible_mobs)
		// Skip self
		if(L == src)
			continue
		
		var/should_hide = FALSE
		
		// Check if this mob is wallpressed
		if(L.wallpressed)
			var/turf/mob_turf = get_turf(L)
			var/turf/wall_turf = get_step(mob_turf, L.wallpressed)
			var/turf/my_turf = get_turf(src)
			
			// Only apply wallpress invisibility if it's actually against a closed turf
			if(istype(wall_turf, /turf/closed))
				// Check if we're on the opposite side
				if(get_dir(wall_turf, my_turf) & L.wallpressed)
					should_hide = TRUE

		// Remove any previous hiding image if we should NOT hide this mob
		if(!should_hide)
			for(var/image/img in client.images)
				if(img.override && img.loc == L && img.icon == null)
					client.images -= img
					client.hidden_atoms -= img
					break

		// If we determined this mob should be hidden, hide it
		if(should_hide)
			var/image/hiding = image(null, L)
			hiding.override = TRUE
			hiding.mouse_opacity = 0 // Explicitly set to not block mouseover
			client.images += hiding
			client.hidden_atoms += hiding
			// No longer adding to hidden_mobs list

/mob/proc/can_see_cone(mob/L)
	if(!isliving(src) || !isliving(L))
		return
	if(!client)
		return TRUE
		
	// First check if wall leaning blocks visibility
	if(isliving(L))
		var/mob/living/living_target = L
		if(living_target.wallpressed)
			var/turf/target_turf = get_turf(living_target)
			var/turf/wall_turf = get_step(target_turf, living_target.wallpressed)
			if(istype(wall_turf, /turf/closed))
				var/turf/my_turf = get_turf(src)
				
				// Get the opposite direction from the wallpress direction
				var/opposite_direction = turn(living_target.wallpressed, 180)
				
				// Check if we're on the opposite side of the wall
				// If we're NOT in the opposite direction, we are on the same
				// side of the wall as the target and can see them
				if(!(get_dir(wall_turf, my_turf) & opposite_direction))
					// If we're on the same side of the wall, we can see
					return TRUE
				else
					// If we're on opposite sides of the wall, can't see
					return FALSE
	
	if(hud_used && hud_used.fov)
		if(hud_used.fov.alpha != 0)
			var/list/mobs2hide = list()

			if(fovangle & FOV_RIGHT)
				if(fovangle & FOV_LEFT)
					var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90),turn(src.dir, 90))
					mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, -90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, -90))
						mobs2hide |= cone(src, dirlist, list(L))
			else
				if(fovangle & FOV_LEFT)
					if(fovangle & FOV_BEHIND)
						var/dirlist = list(turn(src.dir, 90))
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
						mobs2hide |= cone(src, dirlist, list(L))
					else
						var/dirlist = list(turn(src.dir, 180),turn(src.dir, 90))
						mobs2hide |= cone(src, dirlist, list(L))
				else
					if(fovangle & FOV_BEHIND)
						mobs2hide |= behind(src, list(turn(src.dir, 180)), list(L))
					else//default
						mobs2hide |= cone(src, list(turn(src.dir, 180)), list(L))

			if(L in mobs2hide)
				return FALSE
	return TRUE

/mob/proc/update_cone_show()
	if(!client)
		return
	if(client.perspective != MOB_PERSPECTIVE)
		return hide_cone()
	if(client.eye != src)
		return hide_cone()
	if(client.pixel_x || client.pixel_y)
		return hide_cone()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(!(H.mobility_flags & MOBILITY_STAND))
			return hide_cone()
		if(!H.client && (H.mode != AI_OFF))
			return hide_cone()
	return show_cone()

/mob/proc/update_fov_angles()
	fovangle = initial(fovangle)
	if(ishuman(src) && fovangle)
		var/mob/living/carbon/human/H = src
		if(H.head)
			if(H.head.block2add)
				fovangle |= H.head.block2add
		if(H.wear_mask)
			if(H.wear_mask.block2add)
				fovangle |= H.wear_mask.block2add
		if(H.STAPER < 5)
			fovangle |= FOV_LEFT
			fovangle |= FOV_RIGHT
		else
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_LEFT))
				fovangle |= FOV_LEFT
			if(HAS_TRAIT(src, TRAIT_CYCLOPS_RIGHT))
				fovangle |= FOV_RIGHT

	if(!hud_used)
		return
	if(!hud_used.fov)
		return
	if(!hud_used.fov_blocker)
		return
	if(fovangle & FOV_DEFAULT)
		if(fovangle & FOV_RIGHT)
			if(fovangle & FOV_LEFT)
				hud_used.fov.icon_state = "both"
				hud_used.fov_blocker.icon_state = "both_v"
				return
			hud_used.fov.icon_state = "right"
			hud_used.fov_blocker.icon_state = "right_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_r"
				hud_used.fov_blocker.icon_state = "behind_r_v"
			return
		else if(fovangle & FOV_LEFT)
			hud_used.fov.icon_state = "left"
			hud_used.fov_blocker.icon_state = "left_v"
			if(fovangle & FOV_BEHIND)
				hud_used.fov.icon_state = "behind_l"
				hud_used.fov_blocker.icon_state = "behind_l_v"
			return
		if(fovangle & FOV_BEHIND)
			hud_used.fov.icon_state = "behind"
			hud_used.fov_blocker.icon_state = "behind_v"
		else
			hud_used.fov.icon_state = "combat"
			hud_used.fov_blocker.icon_state = "combat_v"
	else
		hud_used.fov.icon_state = null
		hud_used.fov_blocker.icon_state = null
		return

//Making these generic procs so you can call them anywhere.
/mob/proc/show_cone()
	if(!client)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 255
		hud_used.fov_blocker.alpha = 255
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	PM.backdrop(src)

/mob/proc/hide_cone()
	if(!client)
		return
	if(hud_used?.fov)
		hud_used.fov.alpha = 0
		hud_used.fov_blocker.alpha = 0
	var/atom/movable/screen/plane_master/game_world_fov_hidden/PM = locate(/atom/movable/screen/plane_master/game_world_fov_hidden) in client.screen
	PM.backdrop(src)

/atom/movable/screen/fov_blocker
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat_v"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FIELD_OF_VISION_BLOCKER_PLANE
	screen_loc = "1,1"

/atom/movable/screen/fov
	icon = 'icons/mob/vision_cone.dmi'
	icon_state = "combat"
	name = " "
	screen_loc = "1,1"
	mouse_opacity = 0
	layer = HUD_LAYER
	plane = HUD_PLANE-2
