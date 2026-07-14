//client proc to enable and disable fullscreen
/client/proc/toggle_fullscreen(value)
	if(value)
		winset(src, "mainwindow", "menu=;is-fullscreen=true")
		winset(src, "status_bar_wide", "is-visible=false")
		winset(src, "mainwindow", "on-status=\".winset \\\"\[\[*]]=\\\"\\\" ? status_bar.text=\[\[*]] status_bar.is-visible=true : status_bar.is-visible=false\\\"\"")
	else
		winset(src, "mainwindow", "menu=\"menu\";is-fullscreen=false")
		winset(src, "status_bar_wide", "is-visible=true")
		winset(src, "mainwindow", "on-status=\".winset \\\"status_bar_wide.text = \[\[*]]\\\"\"")
		winset(src, "status_bar", "is-visible=false")
	src.attempt_auto_fit_viewport()

/client/proc/fix_mapsize()
	var/windowsize = winget(src, "split", "size")
	if (!src || !windowsize)
		return
	var/split = findtext(windowsize, "x")
	winset(src, "split", "size=[copytext(windowsize, 1, split)]x[text2num(copytext(windowsize, split + 1)) - 16]")
	src.fit_viewport()

/client/verb/switch_fullscreen()
	set category = "OOC"
	set name = "Toggle Fullscreen"

	if(!src || !prefs)
		return
	src.prefs.toggles2 ^= PREFTOGGLE_2_FULLSCREEN
	src.toggle_fullscreen(src.prefs.toggles2 & PREFTOGGLE_2_FULLSCREEN)
	to_chat(usr, "<span class ='info'>Switched [src.prefs.toggles2 & PREFTOGGLE_2_FULLSCREEN ? "to fullscreen" : "off fullscreen"], press F11 to toggle.</span>")
