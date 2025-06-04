/obj/machinery/munitions_forge
	name = "munitions forge"
	desc = "A large crucible used to create railgun ammunition out of alloys"

	var/list/material_contents = list()

	var/obj/machinery/forge_cast_basin/basin
	var/obj/machinery/forge_access/access
	var/obj/machinery/computer/forge_computer/computer

/obj/machinery/munitions_forge/link_machines()
	if(!anchored)
		unlink_machines()
		return
	for(var/obj/machinery/M in orange(1))
		switch(M.type)
			if(/obj/machinery/forge_cast_basin)
				if(!basin)
					basin = M
				continue
			if(/obj/machinery/forge_access)
				if(!access)
					access = M
				continue
			if(/obj/machinery/computer/forge_computer)
				if(!computer)
					computer = M
				continue

/obj/machinery/munitions_forge/load()


/obj/machinery/munitions_forge/unlink_machines()
	basin = null
	access = null
	computer = null

/obj/machinery/forge_cast_basin
	name = "munitions forge cast basin"
	desc = "A basin able to hold one ammo cast. Used to change the type of rounds created."

/obj/machinery/forge_access
	name = "munitions forge input"
	desc = "A mechanism used to load materials into the munitions forge. You probably shouldn't sit on this."

	var/list/loaded = list()

/obj/machinery/forge_access/examine(mob/user)
	. = ..()
	if(open)
		. += "<span class='notice'>It is lowered, and ready to be filled with materials.</span>"

/obj/machinery/forge_access/attackby(obj/item/W, mob/user, params)
	add_fingerprint(user)
	if(istype(W, /obj/item/stack) && W.materials)
		var/obj/item/stack/S = W
	else
		. = ..()

/obj/machinery/computer/forge_computer
	name = "munitions forge console"
	desc = "A computer used to control the munitions forge."
	icon_keyboard = "mining_key"
	icon_screen = "generic"

/obj/machinery/computer/forge_computer/link_machines()
	for(var/obj/machinery/munitions_forge/M in orange(1))
		if(istype(M)) //Just in case it isn't, somehow
			M.computer = src //We're already here anyway
			M.link_machines()


//The alloy rounds

/obj/item/ship_weapon/ammunition/railgun_ammo/alloy
	name = "\improper M4 NTRS 400mm alloy round"
	desc = "A gigantic slug that's designed to be fired out of a railgun. It's extremely heavy, and is made of various alloys."
	icon_state = "railgun_ammo"
	icon = 'nsv13/icons/obj/munitions.dmi'
	projectile_type = /obj/item/projectile/bullet/railgun_slug

	var/hardness
	var/density
	var/conductivity

/obj/item/projectile/bullet/railgun_slug/alloy
	icon_state = "mac"
	name = "alloy slug"
	icon = 'nsv13/icons/obj/projectiles_nsv.dmi'

	//These stats will be based on the materials of the round
	damage = 1
	speed = 1
	homing_turn_speed = 2
	flag = "overmap_heavy"
