//Lazily shoving all donator fluff items in here for now. Feel free to make this a sub-folder or something, I think it's just easier to keep a list here and just modify as needed.

//Plexiant's donator item - rapier
/obj/item/rogueweapon/sword/rapier/aliseo
	name = "Rapier di Aliseo"
	desc = "A rapier of sporting a steel blade and decrotive silver-plating. Elaborately designed in classic intricate yet functional Etrucian style, the pummel appears to be embedded with a cut emerald with a family crest engraved in the fine leather grip of the handle." 
	icon_state = "plex"
	icon = 'modular_azurepeak/icons/obj/items/donor_weapons_64.dmi'

//Ryebread's donator item - estoc
/obj/item/rogueweapon/estoc/worttrager
	name = "Wortträger"
	desc = "An imported Grenzelhoftian panzerstecher, a superbly crafted implement devoid of armory marks- merely bearing a maker's mark and the Zenitstadt seal. This one has a grip of walnut wood, and a pale saffira set within the crossguard. The ricasso is engraved with Ravoxian scripture."
	icon_state = "mansa"
	icon = 'modular_azurepeak/icons/obj/items/donor_weapons_64.dmi'

//Srusu's donator item - dress
/obj/item/clothing/suit/roguetown/shirt/dress/emerald
	name = "emerald dress"
	desc = "A silky smooth emerald-green dress, only for the finest of ladies."
	slot_flags = ITEM_SLOT_SHIRT|ITEM_SLOT_ARMOR	//Goes either slot, no armor on it after all.
	icon_state = "laciedress"
	sleevetype = "laciedress"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'

//Strudles donator item - mage vest (same as base leather)
/obj/item/clothing/suit/roguetown/armor/leather/vest/sofiavest
	name = "grenzelhoftian mages vest"
	desc = "A vest often worn by those of the Grenzelhoftian mages college."
	icon_state = "sofiavest"
	item_state = "sofiavest"
	sleevetype = "sofiavest"
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'
	sleeved = 'modular_azurepeak/icons/clothing/onmob/donor_sleeves_armor.dmi'

//Bat's donator item - custom harp sprite
/obj/item/rogue/instrument/harp/handcarved
	name = "handcrafted harp"
	desc = "A handcrafted harp."
	icon_state = "batharp"
	icon = 'modular_azurepeak/icons/obj/items/donor_objects.dmi'

//Rebel0's donator item - visored sallet with a hood on under it. (Same as normal sallet)
/obj/item/clothing/head/roguetown/helmet/sallet/visored/gilded
	name = "gilded visored sallet"
	desc = "A steel helmet with gilded trim which protects the ears, nose, and eyes."
	icon_state = "gildedsallet_visor"
	item_state = "gildedsallet_visor"
	flags_inv = HIDEFACE|HIDESNOUT|HIDEHAIR		//Normal visored-sallet hides hair. This one doesn't.
	icon = 'modular_azurepeak/icons/clothing/donor_clothes.dmi'
	mob_overlay_icon = 'modular_azurepeak/icons/clothing/onmob/donor_clothes.dmi'

/obj/item/clothing/head/roguetown/helmet/sallet/visored/gilded/attackby(obj/item/W, mob/living/user, params)
	if(istype(W, /obj/item/natural/cloth) && !detail_tag)
		var/list/colors = list(		//Uses same colors as lord colors for simplicty & blending.
		"PURPLE"="#8747b1", 
		"RED"="#8b2323", 	
		"BLACK"="#2b292e", 
		"BROWN"="#61462c", 	
		"GREEN"="#264d26", 	
		"BLUE"="#173266", 	
		"YELLOW"="#ffcd43", 
		"TEAL"="#249589", 	
		"AZURE"="#007fff", 	
		"WHITE"="#ffffff",	
		"ORANGE"="#df8405",	
		"MAGENTA"="#962e5c")
		var/choice = input(user, "Choose a color.", "Orle") as anything in colors
		user.visible_message(span_warning("[user] adds [W] to [src]."))
		user.transferItemToLoc(W, src, FALSE, FALSE)
		detail_color = colors[choice]
		detail_tag = "_detail"
		update_icon()
		if(loc == user && ishuman(user))
			var/mob/living/carbon/H = user
			H.update_inv_head()

/obj/item/clothing/head/roguetown/helmet/sallet/visored/gilded/update_icon()
	cut_overlays()
	if(get_detail_tag())
		var/mutable_appearance/pic = mutable_appearance(icon(icon, "[icon_state][detail_tag]"))
		pic.appearance_flags = RESET_COLOR
		if(get_detail_color())
			pic.color = get_detail_color()
		add_overlay(pic)

/obj/item/clothing/head/roguetown/helmet/sallet/visored/gilded/AdjustClothes(mob/user)
	if(loc == user)
		playsound(user, "sound/items/visor.ogg", 100, TRUE, -1)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			icon_state = "[initial(icon_state)]_raised"
			body_parts_covered = HEAD|EARS|HAIR
			flags_cover = null
			flags_inv = HIDEHAIR
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			block2add = null
		else if(adjustable == CADJUSTED)
			ResetAdjust(user)
			flags_inv = HIDEFACE|HIDESNOUT|HIDEHAIR
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_head()
		user.update_fov_angles()
