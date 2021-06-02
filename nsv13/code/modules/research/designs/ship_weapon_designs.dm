//General weapons stuff
/datum/design/board/munitions_computer_circuit
	name = "Computer Design (Munitions Computer)"
	desc = "Allows for the construction of a munitions control console."
	id = "munitions_computer_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 1000)
	build_path = /obj/item/circuitboard/computer/ship/munitions_computer
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/ship_firing_electronics
	name = "Firing Electronics"
	desc = "Controls the firing mechanism for ship-sized weaponry."
	id = "ship_firing_electronics"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1000, /datum/material/diamond = 100, /datum/material/titanium = 300, /datum/material/copper = 100)
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/firing_electronics
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Missile system (factory parts in munitions_designs.dm)
/datum/design/board/vls_tube
	name = "Machine Design (VLS Tube)"
	desc = "Allows for the construction of a VLS launch tube (control computer not included)."
	id = "vls_tube"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/vls
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/ams_console
	name = "Machine Design (AMS Control Console)"
	desc = "Allows for the construction of an AMS control console."
	id = "ams_console"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/computer/ams
	category = list("Computer Boards")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

//Misc
/datum/design/railgun_rail
	name = "Railgun Rail"
	desc = "A reinforced electromagnetic rail for a railgun."
	id = "railgun_rail"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/silver = 1000, /datum/material/plasma = 1000) //Duranium ingredients
	construction_time=100
	build_path = /obj/item/ship_weapon/parts/railgun_rail
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS

/datum/design/board/gauss_dispenser_circuit
	name = "Machine Design (Gauss Dispenser)"
	desc = "Allows you to construct a machine that lets you access the ship's internal ammo stores to retrieve gauss gun ammunition."
	id = "gauss_dispenser_circuit"
	build_type = PROTOLATHE|IMPRINTER
	materials = list(/datum/material/glass = 2000, /datum/material/copper = 200, /datum/material/gold = 500)
	build_path = /obj/item/circuitboard/machine/gauss_dispenser
	category = list("Advanced Munitions")
	departmental_flags = DEPARTMENTAL_FLAG_MUNITIONS
