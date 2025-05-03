// Color key constants for genitals
#define PENIS_COLOR "penis_color" 
#define PENIS_SKIN_COLOR "penis_skin_color"
#define TESTICLES_COLOR "testicles_color"
#define BREASTS_COLOR "breasts_color"

// Utility defines for skin tone conversion
// Key is already defined elsewhere in the codebase
#define SKINTONE2HEX(tone) (GLOB.skin_tones[tone] || "#a57d50")

/datum/sprite_accessory/penis
	icon = 'icons/mob/sprite_accessory/genitals/pintle.dmi'
	// Disabled color customization but will use skin color by default
	color_keys = 2
	color_key_names = list("Member", "Skin")
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER) //Vrell - Yes I know this is hacky but it works for now

/datum/sprite_accessory/penis/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_BELT, OFFSET_BELT_F)
	// Force colors to match skin tone
	var/list/colors = list()
	// Use species skin color or default
	colors += get_organ_color(owner, organ)
	colors += get_organ_color(owner, organ)
	appearance_list[PENIS_COLOR] = colors[1]
	appearance_list[PENIS_SKIN_COLOR] = colors[2]

// Helper function to get appropriate color based on character species
/proc/get_organ_color(mob/living/carbon/human/H, obj/item/organ/O)
	if(!istype(H) || !istype(O))
		return "#a57d50" // Default skin tone
	
	// Try to get skin tone from species
	var/skin_color = "#a57d50"
	if(H.dna && H.dna.species)
		if(H.dna.species.use_skintones && H.skin_tone)
			skin_color = SKINTONE2HEX(H.skin_tone)
		else if(length(H.dna.species.species_traits) > 0 && H.dna.features["mcolor"])
			// For non-human species that use mutant colors
			skin_color = "#[H.dna.features["mcolor"]]"
	return skin_color

/datum/sprite_accessory/penis/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/penis/pp = organ
	if(pp.sheath_type != SHEATH_TYPE_NONE && pp.erect_state != ERECT_STATE_HARD)
		switch(pp.sheath_type)
			if(SHEATH_TYPE_NORMAL)
				if(pp.erect_state == ERECT_STATE_NONE)
					return "sheath_1"
				else
					return "sheath_2"
			if(SHEATH_TYPE_SLIT)
				if(pp.erect_state == ERECT_STATE_NONE)
					return "slit_1"
				else
					return "slit_2"
	if(pp.erect_state == ERECT_STATE_HARD)
		return "[icon_state]_[min(3,pp.penis_size+1)]"
	else
		return "[icon_state]_[pp.penis_size]"

/datum/sprite_accessory/penis/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(owner.underwear)
		return FALSE
	return is_human_part_visible(owner, HIDEJUMPSUIT|HIDECROTCH)

/datum/sprite_accessory/penis/human
	icon_state = "human"
	name = "Plain"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/knotted
	icon_state = "knotted"
	name = "Knotted"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/knotted2
	name = "Knotted 2"
	icon_state = "knotted2"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/flared
	icon_state = "flared"
	name = "Flared"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/barbknot
	icon_state = "barbknot"
	name = "Barbed, Knotted"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/tapered
	icon_state = "tapered"
	name = "Tapered"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/tapered_mammal
	icon_state = "tapered"
	name = "Tapered"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/tentacle
	icon_state = "tentacle"
	name = "Tentacled"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/hemi
	icon_state = "hemi"
	name = "Hemi"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/penis/hemiknot
	icon_state = "hemiknot"
	name = "Knotted Hemi"
	color_key_defaults = list(KEY_SKIN_COLOR, KEY_SKIN_COLOR)

/datum/sprite_accessory/testicles
	icon = 'icons/mob/sprite_accessory/genitals/gonads.dmi'
	// Disabled color customization but will use skin color
	color_key_name = "Sack"
	relevant_layers = list(BODY_BEHIND_LAYER, BODY_FRONT_LAYER)

/datum/sprite_accessory/testicles/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_BELT, OFFSET_BELT_F)
	// Force color to match skin tone
	appearance_list[TESTICLES_COLOR] = get_organ_color(owner, organ)

/datum/sprite_accessory/testicles/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/testicles/testes = organ
	return "[icon_state]_[testes.ball_size]"

/datum/sprite_accessory/testicles/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(owner.underwear)
		return FALSE
	var/obj/item/organ/penis/pp = owner.getorganslot(ORGAN_SLOT_PENIS)
	if(pp && pp.sheath_type == SHEATH_TYPE_SLIT)
		return FALSE
	return is_human_part_visible(owner, HIDEJUMPSUIT|HIDECROTCH)

/datum/sprite_accessory/testicles/pair
	name = "Pair"
	icon_state = "pair"
	color_key_defaults = list(KEY_SKIN_COLOR)

/datum/sprite_accessory/breasts
	icon = 'icons/mob/sprite_accessory/genitals/breasts.dmi'
	// Disabled color customization but will use skin color
	color_key_name = "Breasts"
	relevant_layers = list(BODY_ADJ_LAYER)

/datum/sprite_accessory/breasts/get_icon_state(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	var/obj/item/organ/breasts/badonkers = organ
	return "[icon_state]_[badonkers.breast_size]"

/datum/sprite_accessory/breasts/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_ID, OFFSET_ID_F)
	// Force color to match skin tone
	appearance_list[BREASTS_COLOR] = get_organ_color(owner, organ)

/datum/sprite_accessory/breasts/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(owner.underwear && owner.underwear.covers_breasts)
		return FALSE
	return is_human_part_visible(owner, HIDEBOOB|HIDEJUMPSUIT)

/datum/sprite_accessory/breasts/pair
	icon_state = "pair"
	name = "Pair"
	color_key_defaults = list(KEY_SKIN_COLOR)

/datum/sprite_accessory/breasts/quad
	icon_state = "quad"
	name = "Quad"
	color_key_defaults = list(KEY_SKIN_COLOR)

/datum/sprite_accessory/breasts/sextuple
	icon_state = "sextuple"
	name = "Sextuple"
	color_key_defaults = list(KEY_SKIN_COLOR)

/datum/sprite_accessory/vagina
	icon = 'icons/mob/sprite_accessory/genitals/nethers.dmi'
	// Disabled custom color selection
	// color_key_name = "Nethers"
	relevant_layers = list(BODY_FRONT_LAYER)

/datum/sprite_accessory/vagina/adjust_appearance_list(list/appearance_list, obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	generic_gender_feature_adjust(appearance_list, organ, bodypart, owner, OFFSET_BELT, OFFSET_BELT_F)

/datum/sprite_accessory/vagina/is_visible(obj/item/organ/organ, obj/item/bodypart/bodypart, mob/living/carbon/owner)
	if(owner.underwear)
		return FALSE
	return is_human_part_visible(owner, HIDECROTCH|HIDEJUMPSUIT)

/datum/sprite_accessory/vagina/human
	icon_state = "human"
	name = "Plain"
	default_colors = list("ea6767") // Set fixed color

/datum/sprite_accessory/vagina/hairy
	icon_state = "hairy"
	name = "Hairy"
	// Using fixed color instead of hair color reference
	default_colors = list("ea6767")

/datum/sprite_accessory/vagina/spade
	icon_state = "spade"
	name = "Spade"
	default_colors = list("C52828") // Fixed color

/datum/sprite_accessory/vagina/furred
	icon_state = "furred"
	name = "Furred"
	// Using fixed color instead of mut color reference
	default_colors = list("C52828")

/datum/sprite_accessory/vagina/gaping
	icon_state = "gaping"
	name = "Gaping"
	default_colors = list("f99696") // Fixed color

/datum/sprite_accessory/vagina/cloaca
	icon_state = "cloaca"
	name = "Cloaca"
	default_colors = list("f99696") // Fixed color
