GLOBAL_LIST_EMPTY(loadout_items)

/datum/loadout_item
	var/name = "Parent loadout datum"
	var/desc
	var/path
	var/donoritem			//autoset on new if null
	var/list/ckeywhitelist
	var/hidden = FALSE     // If TRUE, this item won't show in regular loadout selection
	var/triumph_cost = 10 // Default cost, override per item

/datum/loadout_item/New()
	if(isnull(donoritem))
		if(ckeywhitelist)
			donoritem = TRUE

/datum/loadout_item/proc/donator_ckey_check(key)
	if(ckeywhitelist && ckeywhitelist.Find(key))
		return TRUE
	return

//Miscellaneous

/datum/loadout_item/card_deck
	name = "Card Deck"
	path = /obj/item/toy/cards/deck
	triumph_cost = 15

/datum/loadout_item/farkle_dice
	name = "Farkle Dice Container"
	path = /obj/item/storage/pill_bottle/dice/farkle
	triumph_cost = 15

//HATS
/datum/loadout_item/shalal
	name = "Keffiyeh"
	path = /obj/item/clothing/head/roguetown/roguehood/shalal
	triumph_cost = 24

/datum/loadout_item/archercap
	name = "Archer's cap"
	path = /obj/item/clothing/head/roguetown/archercap
	triumph_cost = 21

/datum/loadout_item/strawhat
	name = "Straw Hat"
	path = /obj/item/clothing/head/roguetown/strawhat
	triumph_cost = 18

/datum/loadout_item/witchhat
	name = "Witch Hat"
	path = /obj/item/clothing/head/roguetown/witchhat
	triumph_cost = 24

/datum/loadout_item/bardhat
	name = "Bard Hat"
	path = /obj/item/clothing/head/roguetown/bardhat
	triumph_cost = 21

/datum/loadout_item/fancyhat
	name = "Fancy Hat"
	path = /obj/item/clothing/head/roguetown/fancyhat
	triumph_cost = 24

/datum/loadout_item/smokingcap
	name = "Smoking Cap"
	path = /obj/item/clothing/head/roguetown/smokingcap
	triumph_cost = 18

/datum/loadout_item/headband
	name = "Headband"
	path = /obj/item/clothing/head/roguetown/headband
	triumph_cost = 15

/datum/loadout_item/buckled_hat
	name = "Buckled Hat"
	path = /obj/item/clothing/head/roguetown/puritan
	triumph_cost = 21

/datum/loadout_item/folded_hat
	name = "Folded Hat"
	path = /obj/item/clothing/head/roguetown/bucklehat
	triumph_cost = 18

/datum/loadout_item/duelist_hat
	name = "Duelist's Hat"
	path = /obj/item/clothing/head/roguetown/duelhat
	triumph_cost = 27

/datum/loadout_item/hood
	name = "Hood"
	path = /obj/item/clothing/head/roguetown/roguehood
	triumph_cost = 21

/datum/loadout_item/hijab
	name = "Hijab"
	path = /obj/item/clothing/head/roguetown/roguehood/shalal/hijab
	triumph_cost = 18

/datum/loadout_item/heavyhood
	name = "Heavy Hood"
	path = /obj/item/clothing/head/roguetown/roguehood/shalal/heavyhood
	triumph_cost = 24

/datum/loadout_item/nunveil
	name = "Nun Veil"
	path = /obj/item/clothing/head/roguetown/nun
	triumph_cost = 21

//CLOAKS
/datum/loadout_item/tabard
	name = "Tabard"
	path = /obj/item/clothing/cloak/tabard
	triumph_cost = 30

/datum/loadout_item/surcoat
	name = "Surcoat"
	path = /obj/item/clothing/cloak/stabard
	triumph_cost = 36

/datum/loadout_item/jupon
	name = "Jupon"
	path = /obj/item/clothing/cloak/stabard/surcoat
	triumph_cost = 39

/datum/loadout_item/cape
	name = "Cape"
	path = /obj/item/clothing/cloak/cape
	triumph_cost = 30

/datum/loadout_item/halfcloak
	name = "Halfcloak"
	path = /obj/item/clothing/cloak/half
	triumph_cost = 27

/datum/loadout_item/ridercloak
	name = "Rider Cloak"
	path = /obj/item/clothing/cloak/half/rider
	triumph_cost = 36

/datum/loadout_item/raincloak
	name = "Rain Cloak"
	path = /obj/item/clothing/cloak/raincloak
	triumph_cost = 33

/datum/loadout_item/furcloak
	name = "Fur Cloak"
	path = /obj/item/clothing/cloak/raincloak/furcloak
	triumph_cost = 42

/datum/loadout_item/direcloak
	name = "direbear cloak"
	path = /obj/item/clothing/cloak/darkcloak/bear
	triumph_cost = 48

/datum/loadout_item/lightdirecloak
	name = "light direbear cloak"
	path = /obj/item/clothing/cloak/darkcloak/bear/light
	triumph_cost = 45


//SHOES
/datum/loadout_item/darkboots
	name = "Dark Boots"
	path = /obj/item/clothing/shoes/roguetown/boots
	triumph_cost = 24

/datum/loadout_item/babouche
	name = "Babouche"
	path = /obj/item/clothing/shoes/roguetown/shalal
	triumph_cost = 21

/datum/loadout_item/nobleboots
	name = "Noble Boots"
	path = /obj/item/clothing/shoes/roguetown/boots/nobleboot
	triumph_cost = 30

/datum/loadout_item/sandals
	name = "Sandals"
	path = /obj/item/clothing/shoes/roguetown/sandals
	triumph_cost = 18

/datum/loadout_item/shortboots
	name = "Short Boots"
	path = /obj/item/clothing/shoes/roguetown/shortboots
	triumph_cost = 21

/datum/loadout_item/gladsandals
	name = "Gladiatorial Sandals"
	path = /obj/item/clothing/shoes/roguetown/gladiator
	triumph_cost = 24

/datum/loadout_item/ridingboots
	name = "Riding Boots"
	path = /obj/item/clothing/shoes/roguetown/ridingboots
	triumph_cost = 33

/datum/loadout_item/ankletscloth
	name = "Cloth Anklets"
	path = /obj/item/clothing/shoes/roguetown/boots/clothlinedanklets
	triumph_cost = 15

/datum/loadout_item/ankletsfur
	name = "Fur Anklets"
	path = /obj/item/clothing/shoes/roguetown/boots/furlinedanklets
	triumph_cost = 18

//SHIRTS
/datum/loadout_item/longcoat
	name = "Longcoat"
	path = /obj/item/clothing/suit/roguetown/armor/longcoat
	triumph_cost = 45

/datum/loadout_item/robe
	name = "Robe"
	path = /obj/item/clothing/suit/roguetown/shirt/robe
	triumph_cost = 36

/datum/loadout_item/formalsilks
	name = "Formal Silks"
	path = /obj/item/clothing/suit/roguetown/shirt/undershirt/puritan
	triumph_cost = 42

/datum/loadout_item/longshirt
	name = "Shirt"
	path = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	triumph_cost = 24

/datum/loadout_item/shortshirt
	name = "Short-sleeved Shirt"
	path = /obj/item/clothing/suit/roguetown/shirt/shortshirt
	triumph_cost = 21

/datum/loadout_item/sailorshirt
	name = "Striped Shirt"
	path = /obj/item/clothing/suit/roguetown/shirt/undershirt/sailor
	triumph_cost = 27

/datum/loadout_item/sailorjacket
	name = "Leather Jacket"
	path = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor
	triumph_cost = 39

/datum/loadout_item/priestrobe
	name = "Undervestments"
	path = /obj/item/clothing/suit/roguetown/shirt/undershirt/priest
	triumph_cost = 36

/datum/loadout_item/bottomtunic
	name = "Low-cut Tunic"
	path = /obj/item/clothing/suit/roguetown/shirt/undershirt/lowcut
	triumph_cost = 24

/datum/loadout_item/tunic
	name = "Tunic"
	path = /obj/item/clothing/suit/roguetown/shirt/tunic
	triumph_cost = 30

/datum/loadout_item/dress
	name = "Dress"
	path = /obj/item/clothing/suit/roguetown/shirt/dress/gen
	triumph_cost = 30

/datum/loadout_item/bardress
	name = "Bar Dress"
	path = /obj/item/clothing/suit/roguetown/shirt/dress
	triumph_cost = 33

/datum/loadout_item/chemise
	name = "Chemise"
	path = /obj/item/clothing/suit/roguetown/shirt/dress/silkdress
	triumph_cost = 27

/datum/loadout_item/sexydress
	name = "Sexy Dress"
	path = /obj/item/clothing/suit/roguetown/shirt/dress/gen/sexy
	triumph_cost = 36

/datum/loadout_item/straplessdress
	name = "Strapless Dress"
	path = /obj/item/clothing/suit/roguetown/shirt/dress/gen/strapless
	triumph_cost = 39

/datum/loadout_item/straplessdress/alt
	name = "Strapless Dress, alt"
	path = /obj/item/clothing/suit/roguetown/shirt/dress/gen/strapless/alt
	triumph_cost = 39

/datum/loadout_item/leathervest
	name = "Leather Vest"
	path = /obj/item/clothing/suit/roguetown/armor/leather/vest
	triumph_cost = 33

/datum/loadout_item/nun_habit
	name = "Nun Habit"
	path = /obj/item/clothing/suit/roguetown/shirt/robe/nun
	triumph_cost = 36

//PANTS
/datum/loadout_item/tights
	name = "Cloth Tights"
	path = /obj/item/clothing/under/roguetown/tights/black
	triumph_cost = 18

/datum/loadout_item/leathertights
	name = "Leather Tights"
	path = /obj/item/clothing/under/roguetown/trou/leathertights
	triumph_cost = 24

/datum/loadout_item/trou
	name = "Work Trousers"
	path = /obj/item/clothing/under/roguetown/trou
	triumph_cost = 21

/datum/loadout_item/leathertrou
	name = "Leather Trousers"
	path = /obj/item/clothing/under/roguetown/trou/leather
	triumph_cost = 27

/datum/loadout_item/sailorpants
	name = "Seafaring Pants"
	path = /obj/item/clothing/under/roguetown/tights/sailor
	triumph_cost = 24

/datum/loadout_item/skirt
	name = "Skirt"
	path = /obj/item/clothing/under/roguetown/skirt
	triumph_cost = 21

//ACCESSORIES
/datum/loadout_item/stockings
	name = "Stockings"
	path = /obj/item/clothing/under/roguetown/tights/stockings
	triumph_cost = 15

/datum/loadout_item/silkstockings
	name = "Silk Stockings"
	path = /obj/item/clothing/under/roguetown/tights/stockings/silk
	triumph_cost = 21

/datum/loadout_item/fishnet
	name = "Fishnet Stockings"
	path = /obj/item/clothing/under/roguetown/tights/stockings/fishnet
	triumph_cost = 18

/datum/loadout_item/wrappings
	name = "Handwraps"
	path = /obj/item/clothing/wrists/roguetown/wrappings
	triumph_cost = 15

/datum/loadout_item/loincloth
	name = "Loincloth"
	path = /obj/item/clothing/under/roguetown/loincloth
	triumph_cost = 15

/datum/loadout_item/spectacles
	name = "Spectacles"
	path = /obj/item/clothing/mask/rogue/spectacles
	triumph_cost = 18

/datum/loadout_item/fingerless
	name = "Fingerless Gloves"
	path = /obj/item/clothing/gloves/roguetown/fingerless
	triumph_cost = 18

/datum/loadout_item/ragmask
	name = "Rag Mask"
	path = /obj/item/clothing/mask/rogue/ragmask
	triumph_cost = 15

/datum/loadout_item/halfmask
	name = "Halfmask"
	path = /obj/item/clothing/mask/rogue/shepherd
	triumph_cost = 18

/datum/loadout_item/pipe
	name = "Pipe"
	path = /obj/item/clothing/mask/cigarette/pipe
	triumph_cost = 21

/datum/loadout_item/pipewestman
	name = "Westman Pipe"
	path = /obj/item/clothing/mask/cigarette/pipe/westman
	triumph_cost = 24

/datum/loadout_item/feather
	name = "Feather"
	path = /obj/item/natural/feather
	triumph_cost = 15

/datum/loadout_item/collar
	name = "Collar"
	path = /obj/item/clothing/neck/roguetown/collar
	triumph_cost = 18

/datum/loadout_item/bell_collar
	name = "Bell Collar"
	path = /obj/item/clothing/neck/roguetown/collar/bell_collar
	triumph_cost = 21

/datum/loadout_item/cursed_collar
	name = "Cursed Collar"
	path = /obj/item/clothing/neck/roguetown/gorget/cursed_collar
	triumph_cost = 30

/datum/loadout_item/cloth_blindfold
	name = "Cloth Blindfold"
	path = /obj/item/clothing/mask/rogue/blindfold
	triumph_cost = 15

/datum/loadout_item/duelmask
	name = "Duelist's Mask"
	path = /obj/item/clothing/mask/rogue/duelmask
	triumph_cost = 24

/datum/loadout_item/psicross
	name = "Psydonian Cross"
	path = /obj/item/clothing/neck/roguetown/psicross
	triumph_cost = 27


//Donator Section
//All these items are stored in the donator_fluff.dm in the azure modular folder for simplicity.
//All should be subtypes of existing weapons/clothes/armor/gear, whatever, to avoid balance issues I guess. Idk, I'm not your boss.

/datum/loadout_item/donator_plex
	name = "Donator Kit - Rapier di Aliseo"
	path = /obj/item/enchantingkit/plexiant
	name = "Donator Kit - Rapier di Aliseo"
	path = /obj/item/enchantingkit/plexiant
	ckeywhitelist = list("plexiant")

/datum/loadout_item/donator_sru
	name = "Donator Kit - Emerald Dress"
	path = /obj/item/enchantingkit/srusu
	name = "Donator Kit - Emerald Dress"
	path = /obj/item/enchantingkit/srusu
	ckeywhitelist = list("cheekycrenando")


/datum/loadout_item/donator_bat
	name = "Donator Kit - Handcarved Harp"
	path = /obj/item/enchantingkit/bat
	name = "Donator Kit - Handcarved Harp"
	path = /obj/item/enchantingkit/bat
	ckeywhitelist = list("kitchifox")

/datum/loadout_item/donator_mansa
	name = "Donator Kit - Wortträger"
	path = /obj/item/enchantingkit/ryebread
	ckeywhitelist = list("pepperoniplayboy")	//Byond maybe doesn't like spaces. If a name has a space, do it as one continious name.

/datum/loadout_item/donator_rebel
	name = "Donator Kit - Gilded Sallet"
	path = /obj/item/enchantingkit/rebel
	ckeywhitelist = list("rebel0")
	name = "Donator Kit - Wortträger"
	path = /obj/item/enchantingkit/ryebread
	ckeywhitelist = list("pepperoniplayboy")	//Byond maybe doesn't like spaces. If a name has a space, do it as one continious name.

/datum/loadout_item/donator_rebel
	name = "Donator Kit - Gilded Sallet"
	path = /obj/item/enchantingkit/rebel
	ckeywhitelist = list("rebel0")

/datum/loadout_item/thief_kit
	name = "thief kit"
	desc = "A small dark pouch containing essential tools of the trade for aspiring thieves. Only thieves can see this option."
	path = /obj/item/storage/thief_kit
	hidden = TRUE  // Hide this item from normal loadout selection
	// This will be restricted to thieves in the antagonist code
