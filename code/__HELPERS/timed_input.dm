/**
 * Displays an input list to a user with a timeout
 *
 * Shows a list of inputs to a player, allowing them to select one within a specified timeframe
 * If the player doesn't respond in time, returns null (allowing for random selection logic in the caller)
 *
 * @param mob/user The mob who we're showing the input list to
 * @param message The message to display alongside the input
 * @param title The title of the input dialog
 * @param list/list_to_display The list of options to display
 * @param timeout The timeout period in deciseconds (default: 30 seconds)
 * @return The selected item from the list, or null if nothing was selected in time
 */
/proc/timed_input_list(mob/user, message, title, list/list_to_display, timeout = 30 SECONDS)
	if(!user || !list_to_display || !list_to_display.len)
		return null
	
	// Clone the list so we don't modify the original
	var/list/available_options = list_to_display.Copy()
	
	// Create and start the timer
	var/datum/timedevent/input_timer
	var/result = null
	
	// Set up the timer callback to trigger timeout
	input_timer = addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(timed_input_timeout_handler), user, title), timeout, TIMER_STOPPABLE)
	
	// Show the input dialog
	result = input(user, message, title, null) as null|anything in available_options
	
	// Clean up the timer if it's still active
	if(input_timer)
		deltimer(input_timer)
	
	return result

/**
 * Handles timeout for timed_input_list
 *
 * Internal proc that sends a message to the user when the input times out
 * 
 * @param mob/user The mob who was shown the input
 * @param title The title of the input dialog for identification
 */
/proc/timed_input_timeout_handler(mob/user, title)
	if(!user || user.stat == DEAD)
		return
	
	// Notify the user that time's up
	to_chat(user, "<span class='warning'>You took too long to decide!</span>")
	// Attempt to cancel the input dialog
	winset(user, null, "command=.cancel") 