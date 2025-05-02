// Antagonist verbs that can be used by all antagonists

/**
 * Verb that lets antagonists remind themselves of their objectives
 *
 * Shows the antagonist their current objectives in chat
 * Only visible to players with antagonist datums
 */
/mob/proc/remember_objectives()
	set name = "Remember Objectives"
	set category = "Memory"
	set desc = "View your antagonist objectives"

	// Check if the mob has a mind and if they're an antagonist
	if(!mind || !mind.antag_datums || !mind.antag_datums.len)
		to_chat(src, span_warning("You have no special objectives to remember."))
		return
	
	// Use the mind's announce_objectives function to show objectives
	mind.announce_objectives() 
