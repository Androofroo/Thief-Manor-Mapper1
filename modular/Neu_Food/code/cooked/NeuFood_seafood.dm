/* ............ Shellfish ................... */
/obj/item/reagent_containers/food/snacks/rogue/fryfish/lobster/meal
	list_reagents = list(/datum/reagent/consumable/nutriment = MEATSLAB_NUTRITION +BUTTERSLICE_NUTRITION + 1)
	tastes = list("lobster" = 1, "butter" = 1)
	name = "buttered lobster"
	desc = "A lobster, covered in butter. Delicious!"
	icon_state = "lobster_meal"
	icon = 'modular/Neu_Food/icons/food.dmi'
	list_reagents = list(/datum/reagent/consumable/nutriment = MEAL_GOOD)
	faretype = FARE_FINE // Idc lobster is not considered fine dining back then it is now since it use butter + rare fish.
	portable = FALSE
	warming = 5 MINUTES
	rotprocess = SHELFLIFE_DECENT
	eat_effect = /datum/status_effect/buff/foodbuff
