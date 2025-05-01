GLOBAL_DATUM_INIT(ssd_indicator, /mutable_appearance, mutable_appearance('icons/mob/ssd_indicator.dmi', "default0", FLY_LAYER))

/mob/living/proc/set_ssd_indicator(state)
	// Disabled SSD indicator to prevent "zzz" overlay from showing
	// Original code:
	// if(state && stat != DEAD)
	// 	add_overlay(GLOB.ssd_indicator)
	// else
	// 	cut_overlay(GLOB.ssd_indicator)
	// return state
	
	// Always remove the overlay in case it was added previously
	cut_overlay(GLOB.ssd_indicator)
	return state

