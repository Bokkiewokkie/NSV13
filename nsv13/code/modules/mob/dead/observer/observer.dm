/mob/dead/observer/Move(NewLoc, direct)
	. = ..()
	update_overmap()

/*
/mob/dead/observer/verb/restore_ghost_appearance()
	set name = "Return to Lobby"
	set desc = "Returns you to the lobby to play again as a different\
		character."
	set category = "Ghost"

	if(!isobserver(src)) //Commendation for managing that
		to_chat(usr, "<span class='notice'>You can only return to the lobby as a ghost.</span>")
		return

	if(alert(usr, "Send yourself back to the lobby?", "Message", "Yes", "No") != "Yes")
		return

	log_admin("[key_name(usr)] has sent themself back to the Lobby.")
	message_admins("[key_name(usr)] has sent themself back to the Lobby.")

	var/mob/dead/new_player/NP = new()
	NP.ckey = src.ckey
	qdel(src)
*/
