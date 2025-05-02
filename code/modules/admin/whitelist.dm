#ifdef TESTSERVER
	#define WHITELISTFILE	"[global.config.directory]/roguetown/wl_test.txt"
#else
	#define WHITELISTFILE	"[global.config.directory]/roguetown/wl_mat.txt"
#endif

GLOBAL_LIST_EMPTY(whitelist)
GLOBAL_PROTECT(whitelist)

/proc/load_whitelist()
	GLOB.whitelist = list()
	for(var/line in world.file2list(WHITELISTFILE))
		if(!line)
			continue
		if(findtextEx(line,"#",1,2))
			continue
		GLOB.whitelist += ckey(line)

/proc/check_whitelist(ckey)
	if(!GLOB.whitelist || !GLOB.whitelist.len)
		load_whitelist()
#ifdef TESTSERVER
	var/plevel = check_patreon_lvl(ckey)
	if(plevel >= 3)
		return TRUE
#endif
	return (ckey in GLOB.whitelist)

/client/proc/add_to_whitelist()
	set category = "-GameMaster-"
	set name = "Add to Whitelist"
	
	if(!check_rights(R_ADMIN))
		return
	
	var/ckey_to_add = input("Enter the ckey to add to the whitelist:", "Add to Whitelist") as text|null
	if(!ckey_to_add)
		return
	
	ckey_to_add = ckey(ckey_to_add)
	
	if(ckey_to_add in GLOB.whitelist)
		to_chat(src, span_warning("[ckey_to_add] is already in the whitelist!"))
		return
	
	// Read existing whitelist content
	var/list/whitelist_content = world.file2list(WHITELISTFILE)
	
	// Add the new ckey to the whitelist file
	whitelist_content += ckey_to_add
	
	// Write the updated whitelist back to the file
	text2file(whitelist_content.Join("\n"), WHITELISTFILE)
	
	// Reload whitelist
	load_whitelist()
	
	log_admin("[key_name(src)] has added [ckey_to_add] to the whitelist.")
	message_admins("[key_name_admin(src)] has added [ckey_to_add] to the whitelist.")
	
#undef WHITELISTFILE
