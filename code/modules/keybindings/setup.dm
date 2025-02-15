/client
	/// A list of any keys held currently
	var/list/keys_held = list()
	// These next two vars are to apply movement for keypresses and releases made while move delayed.
	// Because discarding that input makes the game less responsive.
	var/next_move_dir_add // On next move, add this dir to the move that would otherwise be done
	var/next_move_dir_sub // On next move, subtract this dir from the move that would otherwise be done

// Set a client's focus to an object and override these procs on that object to let it handle keypresses

/datum/proc/key_down(key, client/user) // Called when a key is pressed down initially
	return
/datum/proc/key_up(key, client/user) // Called when a key is released
	return
/datum/proc/keyLoop(client/user) // Called once every frame
	set waitfor = FALSE
	return

// removes all the existing macros
/client/proc/erase_all_macros()
	var/list/macro_sets = params2list(winget(src, null, "macros"))
	var/erase_output = ""
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(copytext(setname, 1, 9) == "persist_") // Don't remove macro sets not handled by input. Used in input_box.dm by create_input_window
			continue
		var/list/macro_set = params2list(winget(src, "[setname].*", "command")) // The third arg doesnt matter here as we're just removing them all
		for(var/k in 1 to macro_set.len)
			var/list/split_name = splittext(macro_set[k], ".")
			var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
			erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)

/client/proc/set_macros()
	set waitfor = FALSE

	erase_all_macros()

	/// Is this client using Chat Relay/Legacy input mode. If so,
	/// we need to be **VERY CAREFUL** about what keys we bind,
	/// and we can't bind anything printable. -Francinum
	var/using_chat_relay = !(prefs.toggles2 & PREFTOGGLE_2_HOTKEYS)

	var/list/macro_sets = SSinput.macro_sets
	var/use_tgui_say = !prefs || (prefs.toggles2 & PREFTOGGLE_2_TGUI_SAY)
	var/say = use_tgui_say ? tgui_say_create_open_command(SAY_CHANNEL) : "\".winset \\\"command=\\\".start_typing say\\\";command=.init_say;saywindow.is-visible=true;saywindow.input.focus=true\\\"\""
	var/me = use_tgui_say ? tgui_say_create_open_command(ME_CHANNEL) : "\".winset \\\"command=\\\".start_typing me\\\";command=.init_me;mewindow.is-visible=true;mewindow.input.focus=true\\\"\""
	var/ooc = use_tgui_say ? tgui_say_create_open_command(OOC_CHANNEL) : "ooc"
	var/radio = tgui_say_create_open_command(RADIO_CHANNEL)
	var/looc = tgui_say_create_open_command(LOOC_CHANNEL)
	for(var/i in 1 to macro_sets.len)
		var/setname = macro_sets[i]
		if(setname != "default")
			winclone(src, "default", setname)
		var/list/macro_set = macro_sets[setname]
		for(var/k in 1 to macro_set.len)
			var/key = macro_set[k]
			var/command = macro_set[key]
			winset(src, "[setname]-[REF(key)]", "parent=[setname];name=[key];command=[command]")
		// If we bind these, we're going to break the default command bar input relay behaviour.
		// This *does* mean we outright ignore the tgui-say pref, but I doubt players who want to use this mode care. -Francinum
		if(!using_chat_relay)
			winset(src, "[setname]-say", "parent=[setname];name=T;command=[say]")
			winset(src, "[setname]-me", "parent=[setname];name=M;command=[me]")
			winset(src, "[setname]-ooc", "parent=[setname];name=O;command=[ooc]")
			if(use_tgui_say)
				winset(src, "[setname]-radio", "parent=[setname];name=Y;command=[radio]")
				winset(src, "[setname]-looc", "parent=[setname];name=L;command=[looc]") // NSV13 - Moves LOOC keybind to L from U
				winset(src, "[setname]-close-tgui-say", "parent=[setname];name=Escape;command=[tgui_say_create_close_command()]")

	if(prefs.toggles2 & PREFTOGGLE_2_HOTKEYS)
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=default")
	else
		winset(src, null, "input.focus=true input.background-color=[COLOR_INPUT_ENABLED] mainwindow.macro=old_default")
