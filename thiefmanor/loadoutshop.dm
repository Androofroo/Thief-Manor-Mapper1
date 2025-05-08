// Loadout Shop System

/proc/show_loadout_shop(mob/user, list/href_list = null)
	if(!user || !user.client || !user.client.prefs)
		return
	var/datum/preferences/prefs = user.client.prefs
	if(!href_list)
		href_list = list()

	// Confirmation dialog (must be first)
	if(href_list["preference"] == "loadoutshop" && href_list["buy"] && !href_list["confirm"])
		var/typepath = text2path(href_list["buy"])
		var/datum/loadout_item/item = GLOB.loadout_items[typepath]
		if(!item)
			show_loadout_shop(user)
			return
		var/icon_html = icon2html(item.path, user) || ""
		var/confirm_html = "<center><h2>Confirm Purchase</h2>"
		confirm_html += "Are you sure you want to buy [icon_html] <b>[item.name]</b> for <span style='color:gold'>[item.triumph_cost] TRIUMPHS</span>?<br><br>"
		confirm_html += "<a href='?_src_=prefs;preference=loadoutshop;buy=[item.type];confirm=1'>Confirm</a> | <a href='?_src_=prefs;preference=loadoutshop'>Cancel</a>"
		confirm_html += "</center>"
		var/datum/browser/popup = new(user, "loadoutshop", "<div align='center'>Loadout Shop</div>", 400, 200)
		popup.set_content(confirm_html)
		popup.open(FALSE)
		return

	var/list/shop_items = list()
	for(var/path as anything in GLOB.loadout_items)
		var/datum/loadout_item/item = GLOB.loadout_items[path]
		if(!item.name || item.hidden) continue
		if(item.type == /datum/loadout_item/thief_kit) continue // skip thief kit
		if(item.ckeywhitelist) continue // skip donator kits
		shop_items += item

	var/html = "<center><h2>Loadout Shop</h2>"
	html += "<b>Your TRIUMPHS:</b> [user.get_triumphs() ? "<span style='color:gold'>[user.get_triumphs()]</span>" : "None"]<br><br>"
	html += "<table border=1 cellpadding=4><tr><th>Item</th><th>Cost</th><th>Status</th><th>Action</th></tr>"
	for(var/datum/loadout_item/I in shop_items)
		var/unlocked = prefs.is_loadout_item_unlocked(I.type)
		var/icon_html = icon2html(I.path, user)
		html += "<tr>"
		html += "<td>" + icon_html + " [I.name]</td>"
		html += "<td>[I.triumph_cost]</td>"
		html += "<td>[(unlocked ? "<span style='color:green'>Unlocked</span>" : "<span style='color:red'>Locked</span>")]</td>"
		if(unlocked)
			html += "<td>--</td>"
		else if(user.get_triumphs() >= I.triumph_cost)
			html += "<td><a href='?_src_=prefs;preference=loadoutshop;buy=[I.type]'>Buy</a></td>"
		else
			html += "<td><span style='color:gray'>Not enough</span></td>"
		html += "</tr>"
	html += "</table>"
	html += "<br><a href='?_src_=prefs;preference=loadoutshop;close=1'>Close</a></center>"

	var/datum/browser/popup = new(user, "loadoutshop", "<div align='center'>Loadout Shop</div>", 700, 500)
	popup.set_content(html)
	popup.open(FALSE)

// Helper proc to check if a loadout item is unlocked
/datum/preferences/proc/is_loadout_item_unlocked(typepath)
	if(!unlocked_loadout_items)
		unlocked_loadout_items = list()
	return (typepath in unlocked_loadout_items)

// Proc to unlock a loadout item
/datum/preferences/proc/unlock_loadout_item(typepath)
	if(!unlocked_loadout_items)
		unlocked_loadout_items = list()
	if(!(typepath in unlocked_loadout_items))
		unlocked_loadout_items += typepath
		save_preferences()
