//Base component

/obj/item/fighter_component
	name = "fighter component"
	desc = "It doesn't really do a whole lot"
	icon = 'nsv13/icons/obj/fighter_components.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	//Thanks to comxy on Discord for these lovely tiered sprites o7
	var/tier = 1 // used for multipliers
	var/slot = null //Change me!
	var/weight = 0 //Some more advanced modules will weigh your fighter down some.
	var/power_usage = 0 //Does this module require power to process()?
	var/fire_mode = null //Used if this is a weapon style hardpoint
	var/active = TRUE

/obj/item/fighter_component/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click it to unload its contents.</span>"

/obj/item/fighter_component/proc/toggle()
	active = !active

/obj/item/fighter_component/proc/dump_contents()
	if(!length(contents))
		return FALSE
	. = list()
	for(var/atom/movable/AM in contents)
		AM.forceMove(get_turf(loc))
		. += AM

/obj/item/fighter_component/proc/get_ammo()
	return FALSE

/obj/item/fighter_component/proc/get_max_ammo()
	return FALSE

/obj/item/fighter_component/Initialize(mapload)
	.=..()
	AddComponent(/datum/component/two_handed, require_twohands=TRUE) //These all require two hands to pick up

//Overload this method to apply stat benefits based on your module.
/obj/item/fighter_component/proc/on_install(obj/structure/overmap/target)
	forceMove(target)
	apply_drag(target)
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	target.visible_message("<span class='notice'>[src] mounts onto [target]")
	return TRUE

//Allows you to jumpstart a fighter with an inducer.
/obj/structure/overmap/small_craft/get_cell()
	return loadout.get_slot(HARDPOINT_SLOT_BATTERY)

/obj/item/fighter_component/proc/power_tick(dt = 1)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F) || !active)
		return FALSE
	var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	return B?.use_power(power_usage * dt)

/obj/item/fighter_component/process(delta_time)
	return power_tick(delta_time)

//Used for weapon style hardpoints
/obj/item/fighter_component/proc/fire(obj/structure/overmap/target)
	return FALSE

/*
If you need your hardpoint to be loaded with things by clicking the fighter
*/
/obj/item/fighter_component/proc/load(obj/structure/overmap/target, atom/movable/AM)
	return FALSE

/obj/item/fighter_component/proc/apply_drag(obj/structure/overmap/target)
	if(!weight)
		return FALSE
	target.speed_limit -= weight
	target.speed_limit = (target.speed_limit > 0) ? target.speed_limit : 0
	target.forward_maxthrust -= weight
	target.forward_maxthrust = (target.forward_maxthrust > 0) ? target.forward_maxthrust : 0
	target.backward_maxthrust -= weight
	target.backward_maxthrust = (target.backward_maxthrust > 0) ? target.backward_maxthrust : 0
	target.side_maxthrust -= 0.25*weight
	target.side_maxthrust = (target.side_maxthrust > 0) ? target.side_maxthrust : 0
	target.max_angular_acceleration -= weight*10
	target.max_angular_acceleration = (target.max_angular_acceleration > 0) ? target.max_angular_acceleration : 0

/*
Remove from(), a proc that forcemoves a component onto the target's tile and removes the weight penalties caused by the specific component. Usually used for removal, but doesn't actually check if it was on the target, use with care.
args:
target: The overmap structure getting the component's weight penalties removed, aswell as the component being moved to its tile.
due_to_damage: If the removal was caused voluntarily (FALSE), or if it was caused by external sources / damage (TRUE); generally influences some specifics of removal on some components.
*/
/obj/item/fighter_component/proc/remove_from(obj/structure/overmap/target, due_to_damage)
	forceMove(get_turf(target))
	if(!weight)
		return TRUE
	for(var/atom/movable/AM as() in contents)
		AM.forceMove(get_turf(target))
	target.speed_limit += weight
	target.forward_maxthrust += weight
	target.backward_maxthrust += weight
	target.side_maxthrust += 0.25 * weight
	target.max_angular_acceleration += weight*10
	return TRUE

//Armour plates

/obj/item/fighter_component/armour_plating
	name = "durasteel armour plates"
	desc = "A set of armour plates which can afford basic protection to a fighter, however heavier plates may slow you down"
	icon_state = "armour_tier1"
	slot = HARDPOINT_SLOT_ARMOUR
	weight = 1
	obj_integrity = 250
	max_integrity = 250
	armor = list("melee" = 50, "bullet" = 40, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //Armour's pretty tough.
	var/repair_speed = 25 // How much integrity you can repair per second
	var/busy = FALSE

//Sometimes you need to repair your physical armour plates.
/obj/item/fighter_component/armour_plating/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return TRUE
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already repairing [src]!</span>")
		return TRUE
	busy = TRUE
	to_chat(user, "<span class='notice'>You start welding some dents out of [src]...</span>")
	while(obj_integrity < max_integrity)
		if(!I.use_tool(src, user, 1 SECONDS, volume=100))
			busy = FALSE
			return TRUE
		obj_integrity += 25
		if(obj_integrity >= max_integrity)
			obj_integrity = max_integrity
			break
	to_chat(user, "<span class='notice'>You finish welding[obj_integrity == max_integrity ? "" : " some of"] the dents out of [src].</span>")
	busy = FALSE

/obj/item/fighter_component/armour_plating/on_install(obj/structure/overmap/target)
	..()
	target.max_integrity = initial(target.max_integrity)*tier

/obj/item/fighter_component/armour_plating/remove_from(obj/structure/overmap/target, due_to_damage)
	..()
	if(due_to_damage)
		return //We don't reset our health if the plating was destroyed due to hits, or the increase would be useless. It DOES get reset once we install new armor, though.
	target.max_integrity = initial(target.max_integrity)
	//Remove any overheal.
	target.obj_integrity = CLAMP(target.obj_integrity, 0, target.max_integrity)

/obj/item/fighter_component/armour_plating/tier2
	name = "ultra heavy fighter armour"
	desc = "An extremely thick and heavy set of armour plates. Guaranteed to weigh you down, but it'll keep you flying through brasil itself."
	icon_state = "armour_tier2"
	tier = 2
	weight = 2
	obj_integrity = 450
	max_integrity = 450

/obj/item/fighter_component/armour_plating/tier3
	name = "nanocarbon armour plates"
	desc = "A lightweight set of ablative armour which balances speed and protection at the cost of the average GDP of most third world countries."
	icon_state = "armour_tier3"
	tier = 3
	weight = 1.25
	obj_integrity = 300
	max_integrity = 300

//Canopy

/obj/item/fighter_component/canopy
	name = "glass canopy"
	desc = "A fighter canopy made of standard glass, it's extremely fragile and is so cheaply produced that it serves as little less than a windshield."
	icon_state = "canopy_tier0.5"
	obj_integrity = 100 //Pretty fragile, don't break it you dumblet
	max_integrity = 100
	slot = HARDPOINT_SLOT_CANOPY
	weight = 0.25 //Real pilots just wear pilot goggles and strip out their canopy.
	tier = 0.5

/obj/item/fighter_component/canopy/reinforced
	name = "reinforced glass canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's pretty robust."
	icon_state = "canopy_tier1"
	obj_integrity = 200
	max_integrity = 200
	tier = 1
	weight = 0.5

/obj/item/fighter_component/canopy/tier2
	name = "nanocarbon glass canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's very robust."
	icon_state = "canopy_tier2"
	obj_integrity = 350
	max_integrity = 350
	tier = 2
	weight = 0.35

/obj/item/fighter_component/canopy/tier3
	name = "plasma glass canopy"
	desc = "A glass fighter canopy that's designed to maintain atmospheric pressure inside of a fighter, this one's exceptionally robust."
	icon_state = "canopy_tier3"
	obj_integrity = 450
	max_integrity = 450
	tier = 3
	weight = 0.55

//Battery

/obj/item/fighter_component/battery
	name = "fighter battery"
	icon_state = "battery"
	slot = HARDPOINT_SLOT_BATTERY
	active = FALSE
	var/charge = 10000
	var/maxcharge = 10000
	var/self_charge = FALSE //TODO! Engine powers this.

/obj/item/fighter_component/battery/process()
	if(self_charge)
		give(1000)

/obj/item/fighter_component/battery/proc/give(amount)
	if(charge >= maxcharge)
		return FALSE
	charge += amount
	charge = CLAMP(charge, 0, maxcharge)

/obj/item/fighter_component/battery/proc/use_power(amount)
	if(!active)
		return FALSE
	charge -= amount
	charge = CLAMP(charge, 0, maxcharge)
	if(charge <= 0)
		var/obj/structure/overmap/small_craft/F = loc
		if(!istype(F))
			return FALSE
		if(active)
			F.set_master_caution(TRUE)
			active = FALSE
	return charge > 0

/obj/item/fighter_component/battery/tier2
	name = "upgraded fighter battery"
	icon_state = "battery_tier2"
	tier = 2
	charge = 20000
	maxcharge = 20000

/obj/item/fighter_component/battery/tier3
	name = "mega fighter battery"
	icon_state = "battery_tier3"
	desc = "An electrochemical cell capable of holding a good amount of charge for keeping the fighter's radio on for longer periods without an engine."
	tier = 3
	charge = 40000
	maxcharge = 40000

//Fuel tank

/obj/item/fighter_component/fuel_tank
	name = "Fighter Fuel Tank"
	desc = "The fuel tank of a fighter, upgrading this lets your fighter hold more fuel."
	icon_state = "fueltank_tier1"
	var/fuel_capacity = 1000
	slot = HARDPOINT_SLOT_FUEL

/obj/item/fighter_component/fuel_tank/Initialize(mapload)
	. = ..()
	create_reagents(fuel_capacity, DRAINABLE | AMOUNT_VISIBLE)
	reagents.chem_temp = 40

/obj/item/fighter_component/fuel_tank/tier2
	name = "fighter extended fuel tank"
	desc = "A larger fuel tank which allows fighters to stay in combat for much longer"
	icon_state = "fueltank_tier2"
	fuel_capacity = 2500
	tier = 2

/obj/item/fighter_component/fuel_tank/tier3
	name = "massive fighter fuel tank"
	desc = "A super extended capacity fuel tank, allowing fighters to stay in a warzone for hours on end."
	icon_state = "fueltank_tier3"
	fuel_capacity = 4000
	tier = 3

//Engine

/obj/item/fighter_component/engine
	name = "fighter engine"
	desc = "A mighty engine capable of propelling small spacecraft to high speeds."
	icon_state = "engine_tier1"
	slot = HARDPOINT_SLOT_ENGINE
	active = FALSE
	var/rpm = 0
	var/flooded = FALSE

/obj/item/fighter_component/engine/flooded //made just so I can put it in pilot-specific mail
	desc = "A mighty engine capable of propelling small spacecraft to high speeds. Something doesn't seem right, though..."
	flooded = TRUE

/obj/item/fighter_component/engine/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(!flooded)
		return
	to_chat(user, "<span class='notice'>You start to purge [src] of its flooded fuel.</span>")
	if(do_after(user, 10 SECONDS, target=src))
		flooded = FALSE
		shake_animation()

/obj/item/fighter_component/engine/proc/active()
	return (active && obj_integrity > 0 && rpm >= ENGINE_RPM_SPUN && !flooded)

/obj/item/fighter_component/engine/process()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	var/obj/item/fighter_component/apu/APU = F.loadout.get_slot(HARDPOINT_SLOT_APU)
	if(!APU?.fuel_line && rpm > 0)
		rpm -= 1000 //Spool down the engine.
		if(rpm <= 0)
			playsound(loc, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] fizzles out!</span>")
			rpm = 0
			F.stop_relay(CHANNEL_SHIP_ALERT)
			active = FALSE
			return FALSE
	if(rpm > 3000)
		var/obj/item/fighter_component/battery/B = F.loadout.get_slot(HARDPOINT_SLOT_BATTERY)
		B.give(500  *tier)
	if(!active())
		return FALSE

/obj/item/fighter_component/engine/proc/apu_spin(amount)
	if(flooded)
		loc.visible_message("<span class='warning'>[src] sputters uselessly.</span>")
		return
	rpm += amount
	rpm = CLAMP(rpm, 0, ENGINE_RPM_SPUN)

/obj/item/fighter_component/engine/proc/try_start()
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	if(rpm >= ENGINE_RPM_SPUN-200) //You get a small bit of leeway.
		active = TRUE
		rpm = ENGINE_RPM_SPUN
		playsound(loc, 'nsv13/sound/effects/fighters/startup.ogg', 100, FALSE)
		F.relay('nsv13/sound/effects/fighters/cockpit.ogg', "<span class='warning'>You hear a loud noise as [F]'s engine kicks in.</span>", loop=TRUE, channel = CHANNEL_SHIP_ALERT)
		return
	else
		playsound(loc, 'sound/machines/clockcult/steam_whoosh.ogg', 100, TRUE)
		loc.visible_message("<span class='warning'>[src] sputters slightly.</span>")
		if(prob(20)) //Don't try and start a not spun engine, flyboys.
			playsound(loc, 'nsv13/sound/effects/ship/rcs.ogg', 100, TRUE)
			loc.visible_message("<span class='userdanger'>[src] violently fizzles out!.</span>")
			F.set_master_caution(TRUE)
			rpm = 0
			flooded = TRUE
			active = FALSE

/obj/item/fighter_component/engine/on_install(obj/structure/overmap/small_craft/target)
	..()
	target.speed_limit = initial(target.speed_limit)*tier
	target.forward_maxthrust = initial(target.forward_maxthrust)*tier
	target.backward_maxthrust = initial(target.backward_maxthrust)*tier
	target.side_maxthrust = initial(target.side_maxthrust)*tier
	target.max_angular_acceleration = initial(target.max_angular_acceleration)*tier
	for(var/slot in target.loadout.equippable_slots)
		var/obj/item/fighter_component/FC = target.loadout.get_slot(slot)
		FC?.apply_drag(target)

/obj/item/fighter_component/engine/remove_from(obj/structure/overmap/target)
	..()
	//No engines? No movement.
	target.speed_limit = 0
	target.forward_maxthrust = 0
	target.backward_maxthrust = 0
	target.side_maxthrust = 0
	target.max_angular_acceleration = 0

/obj/item/fighter_component/engine/tier2
	name = "souped up fighter engine"
	desc = "Born to zoom, forced to oom"
	icon_state = "engine_tier2"
	tier = 2

/obj/item/fighter_component/engine/tier3
	name = "\improper Boringheed Marty V12 Super Giga Turbofan Space Engine"
	desc = "An engine which allows a fighter to exceed the legal speed limit in most jurisdictions."
	icon_state = "engine_tier3"
	tier = 3

//Oxygenator (cabin atmos generator)

/obj/item/fighter_component/oxygenator
	name = "atmospheric regulator"
	desc = "A device which moderates the conditions inside a fighter, it requires fuel to run."
	icon_state = "oxygenator_tier1"
	var/refill_amount = 1 //Starts off really terrible.
	slot = HARDPOINT_SLOT_OXYGENATOR
	weight = 0.5 //Wanna go REALLY FAST? Pack your own O2.
	power_usage = 200

/obj/item/fighter_component/oxygenator/tier2
	name = "upgraded atmospheric regulator"
	icon_state = "oxygenator_tier2"
	tier = 2
	refill_amount = 3
	power_usage = 300

/obj/item/fighter_component/oxygenator/tier3
	name = "super oxygenator"
	desc = "A finely tuned atmospheric regulator to be fitted into a fighter which seems to be able to almost magically create oxygen out of nowhere."
	icon_state = "oxygenator_tier3"
	tier = 3
	refill_amount = 10
	power_usage = 400

/obj/item/fighter_component/oxygenator/plasmaman
	name = "plasmaman atmospheric regulator"
	desc = "An atmospheric regulator to be used in fighters, it's been rigged to fill the cabin with a hospitable environment for plasmamen instead of standard oxygen."
	refill_amount = 3
	tier = 4 //unique! but it has to have a sprite to make it obvious that, yknow, this is for plasmemes.

/obj/item/fighter_component/oxygenator/process()
	//Don't waste power on already fine atmos.
	var/obj/structure/overmap/OM = loc
	if(!istype(OM))
		return FALSE
	if(!..())
		return FALSE
	if(OM.cabin_air.return_pressure()+refill_amount >= WARNING_HIGH_PRESSURE-(2*refill_amount))
		return FALSE //No need to add more air to an already pressurized environment

	//Oxygenator just makes sure you have atmosphere. It doesn't care where it comes from.
	OM.cabin_air.set_temperature(T20C)
	//Gives you a little bit of air.
	refill(OM)
	return TRUE

/obj/item/fighter_component/oxygenator/proc/refill(obj/structure/overmap/OM)
	OM.cabin_air.adjust_moles(GAS_O2, refill_amount*O2STANDARD)
	OM.cabin_air.adjust_moles(GAS_N2, refill_amount*N2STANDARD)
	OM.cabin_air.adjust_moles(GAS_CO2, -refill_amount)

/obj/item/fighter_component/oxygenator/plasmaman/refill(obj/structure/overmap/OM)
	OM.cabin_air.adjust_moles(GAS_PLASMA, refill_amount*N2STANDARD)
	OM.cabin_air.adjust_moles(GAS_O2, -refill_amount)
	OM.cabin_air.adjust_moles(GAS_N2, -refill_amount)

//APU

/obj/item/fighter_component/apu
	name = "fighter auxiliary power unit"
	desc = "An Auxiliary Power Unit for a fighter"
	icon_state = "apu_tier1"
	slot = HARDPOINT_SLOT_APU
	active = FALSE
	var/fuel_line = FALSE
	var/next_process = 0

/obj/item/fighter_component/apu/tier2
	name = "upgraded fighter APU"
	icon_state = "apu_tier2"
	tier = 2

/obj/item/fighter_component/apu/tier3
	name = "super fighter APU"
	desc = "A small engine capable of rapidly starting a fighter."
	icon_state = "apu_tier3"
	tier = 3

/obj/item/fighter_component/apu/proc/toggle_fuel_line()
	fuel_line = !fuel_line

/obj/item/fighter_component/apu/process()
	if(!..())
		return
	if(world.time < next_process)
		return
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	next_process = world.time + 4 SECONDS
	if(!fuel_line)
		return //APU needs fuel to drink
	F.relay('nsv13/sound/effects/fighters/apu_loop.ogg')
	var/obj/item/fighter_component/engine/engine = F.loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	F.use_fuel(2, TRUE) //APUs take fuel to run.
	if(engine.active())
		return
	engine.apu_spin(500*tier)

//Docking computer

/obj/item/fighter_component/docking_computer
	name = "docking computer"
	desc = "A computer that allows fighters to easily dock to a ship"
	icon_state = "docking_computer"
	slot = HARDPOINT_SLOT_DOCKING
	tier = null //Not upgradable right now.
	var/docking_mode = FALSE
	var/docking_cooldown = FALSE

//Avionics

/obj/item/fighter_component/avionics
	name = "fighter avionics"
	desc = "Avionics for a fighter"
	icon_state = "avionics"
	tier = null

/obj/item/fighter_component/avionics/mining
	name = "mining avionics"
	desc = "Avionics built for a mining ship, contains a mining scanner and ore pick-up system."

//Targeting Sensors

/obj/item/fighter_component/targeting_sensor
	name = "fighter targeting sensors"
	icon = 'icons/obj/crates.dmi' //real crate hours
	icon_state = "weapon_crate"
	tier = null

//Countermeasures

/obj/item/fighter_component/countermeasure_dispenser
	name = "fighter countermeasure dispenser"
	desc = "A device which allows a fighter to deploy countermeasures."
	icon_state = "countermeasure_tier1"
	slot = HARDPOINT_SLOT_COUNTERMEASURE
	var/max_charges = 3
	var/charges = 3

/*Weaponry!
As a rule of thumb, primaries are small guns that take ammo boxes, secondaries are big guns that require big bulky objects to be loaded into them.
Utility modules can be either one of these types, just ensure you set its slot to HARDPOINT_SLOT_UTILITY
*/
/obj/item/fighter_component/primary
	name = "\improper Fuck you"
	slot = HARDPOINT_SLOT_PRIMARY
	fire_mode = FIRE_MODE_ANTI_AIR
	var/overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	var/overmap_firing_sounds = list('nsv13/sound/effects/fighters/autocannon.ogg')
	var/accepted_ammo = /obj/item/ammo_box/magazine
	var/obj/item/ammo_box/magazine/magazine = null
	var/list/ammo = list()
	var/burst_size = 1
	var/fire_delay = 0
	var/allowed_roles = OVERMAP_USER_ROLE_GUNNER
	var/bypass_safety = FALSE

/obj/item/fighter_component/primary/dump_contents()
	. = ..()
	for(var/atom/movable/AM as() in .)
		if(AM == magazine)
			magazine = null
			ammo = list()
			playsound(loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/primary/get_ammo()
	return length(ammo)

/obj/item/fighter_component/primary/get_max_ammo()
	return magazine ? magazine.max_ammo : 500 //Default.

/obj/item/fighter_component/primary/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	if(magazine)
		if(magazine.ammo_count() >= magazine.max_ammo)
			return FALSE
		else
			magazine.forceMove(get_turf(target))
			if(!SSmapping.level_trait(loc.z, ZTRAIT_BOARDABLE))
				QDEL_NULL(magazine) //So bullets don't drop onto the overmap.
	AM.forceMove(src)
	magazine = AM
	ammo = magazine.stored_ammo
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/primary/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	if(!ammo.len)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE
	var/obj/item/ammo_casing/chambered = ammo[ammo.len]
	var/datum/ship_weapon/SW = F.weapon_types[fire_mode]
	SW.default_projectile_type = chambered.projectile_type
	SW.fire_fx_only(target)
	ammo -= chambered
	qdel(chambered)
	return TRUE

/obj/item/fighter_component/primary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE
	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay
	SW.allowed_roles = allowed_roles

/obj/item/fighter_component/primary/remove_from(obj/structure/overmap/target)
	. = ..()
	magazine = null
	ammo = list()

/obj/item/fighter_component/primary/cannon
	name = "20mm Vulcan Cannon"
	icon_state = "lightcannon"
	accepted_ammo = /obj/item/ammo_box/magazine/nsv/light_cannon
	burst_size = 2
	fire_delay = 0.25 SECONDS

/obj/item/fighter_component/primary/cannon/heavy
	name = "30mm BRRRRTT Cannon"
	icon_state = "heavycannon"
	accepted_ammo = /obj/item/ammo_box/magazine/nsv/heavy_cannon
	weight = 2 //Sloooow down there.
	overmap_select_sound = 'nsv13/sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('nsv13/sound/effects/fighters/BRRTTTTTT.ogg')
	burst_size = 3
	fire_delay = 0.5 SECONDS

/obj/item/fighter_component/secondary
	name = "Fuck you"
	slot = HARDPOINT_SLOT_SECONDARY
	fire_mode = FIRE_MODE_TORPEDO
	var/overmap_firing_sounds = list(
		'nsv13/sound/effects/ship/torpedo.ogg',
		'nsv13/sound/effects/ship/freespace2/m_shrike.wav',
		'nsv13/sound/effects/ship/freespace2/m_stiletto.wav',
		'nsv13/sound/effects/ship/freespace2/m_tsunami.wav',
		'nsv13/sound/effects/ship/freespace2/m_wasp.wav')
	var/overmap_select_sound = 'nsv13/sound/effects/ship/reload.ogg'
	var/accepted_ammo = /obj/item/ship_weapon/ammunition/missile
	var/list/ammo = list()
	var/max_ammo = 5
	var/burst_size = 1 //Cluster torps...UNLESS?
	var/fire_delay = 0.25 SECONDS
	var/allowed_roles = OVERMAP_USER_ROLE_GUNNER
	var/bypass_safety = FALSE

/obj/item/fighter_component/secondary/dump_contents()
	. = ..()
	for(var/atom/movable/AM in .)
		if(AM in ammo)
			ammo -= AM
			playsound(loc, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)

/obj/item/fighter_component/secondary/get_ammo()
	return ammo.len

/obj/item/fighter_component/secondary/get_max_ammo()
	return max_ammo

/obj/item/fighter_component/secondary/on_install(obj/structure/overmap/target)
	. = ..()
	if(!fire_mode)
		return FALSE
	var/datum/ship_weapon/SW = target.weapon_types[fire_mode]
	SW.overmap_firing_sounds = overmap_firing_sounds
	SW.overmap_select_sound = overmap_select_sound
	SW.burst_size = burst_size
	SW.fire_delay = fire_delay
	SW.allowed_roles = allowed_roles

/obj/item/fighter_component/secondary/remove_from(obj/structure/overmap/target)
	. = ..()
	ammo = list()

//Todo: make fighters use these.
/obj/item/fighter_component/secondary/ordnance_launcher
	name = "fighter missile rack"
	desc = "A huge fighter missile rack capable of deploying missile based weaponry."
	icon_state = "missilerack_tier1"

/obj/item/fighter_component/secondary/ordnance_launcher/tier2
	name = "upgraded fighter missile rack"
	icon_state = "missilerack_tier2"
	tier = 2
	max_ammo = 10

/obj/item/fighter_component/secondary/ordnance_launcher/tier3
	name = "\improper A-11 'Spacehog' Cluster-Freedom Launcher"
	icon_state = "missilerack_tier3"
	tier = 3
	max_ammo = 15
	weight = 1
	burst_size = 2
	fire_delay = 0.10 SECONDS

//Specialist item for the superiority fighter.
/obj/item/fighter_component/secondary/ordnance_launcher/railgun
	name = "fighter railgun"
	desc = "A scaled down railgun designed for use in fighters."
	icon_state = "railgun"
	weight = 1
	accepted_ammo = /obj/item/ship_weapon/ammunition/railgun_ammo
	overmap_firing_sounds = list('nsv13/sound/effects/ship/railgun_fire.ogg')
	burst_size = 1
	fire_delay = 0.2 SECONDS
	max_ammo = 10
	tier = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo
	name = "fighter torpedo launcher"
	desc = "A heavy torpedo rack which allows fighters to fire torpedoes at targets"
	icon_state = "torpedorack"
	accepted_ammo = /obj/item/ship_weapon/ammunition/torpedo
	max_ammo = 2
	weight = 1

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier2
	name = "enhanced torpedo launcher"
	icon_state = "torpedorack_tier2"
	tier = 2
	max_ammo = 4

/obj/item/fighter_component/secondary/ordnance_launcher/torpedo/tier3
	name = "\improper FR33-8IRD torpedo launcher"
	icon_state = "torpedorack_tier3"
	desc = "A massive torpedo launcher capable of deploying enough ordnance to level several small, oil-rich nations."
	tier = 3
	max_ammo = 10
	weight = 2
	burst_size = 2

/obj/item/fighter_component/secondary/ordnance_launcher/load(obj/structure/overmap/target, atom/movable/AM)
	if(!istype(AM, accepted_ammo))
		return FALSE
	if(ammo.len >= max_ammo)
		return FALSE
	AM.forceMove(src)
	ammo += AM
	playsound(target, 'nsv13/sound/effects/ship/mac_load.ogg', 100, 1)
	return TRUE

/obj/item/fighter_component/secondary/ordnance_launcher/fire(obj/structure/overmap/target)
	var/obj/structure/overmap/small_craft/F = loc
	if(!istype(F))
		return FALSE
	if(!ammo.len)
		F.relay('sound/weapons/gun_dry_fire.ogg')
		return FALSE
	var/proj_type = null //If this is true, we've got a launcher shipside that's been able to fire.
	var/proj_speed = 1
	var/obj/item/ship_weapon/ammunition/americagobrr = pick_n_take(ammo)
	proj_type = americagobrr.projectile_type
	proj_speed = istype(americagobrr.projectile_type, /obj/item/projectile/guided_munition/missile) ? 5 : 1
	qdel(americagobrr)
	if(proj_type)
		var/sound/chosen = pick('nsv13/sound/effects/ship/torpedo.ogg','nsv13/sound/effects/ship/freespace2/m_shrike.wav','nsv13/sound/effects/ship/freespace2/m_stiletto.wav','nsv13/sound/effects/ship/freespace2/m_tsunami.wav','nsv13/sound/effects/ship/freespace2/m_wasp.wav')
		F.relay_to_nearby(chosen)
		F.fire_projectile(proj_type, target, speed=proj_speed, lateral = FALSE)
	return TRUE

//Utility modules.

/obj/item/fighter_component/primary/utility
	name = "No :)"
	slot = HARDPOINT_SLOT_UTILITY_PRIMARY
	allowed_roles = OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER

/obj/item/fighter_component/primary/utility/fire(obj/structure/overmap/target)
	return FALSE

/obj/item/fighter_component/secondary/utility
	name = "Utility Module"
	slot = HARDPOINT_SLOT_UTILITY_SECONDARY
	power_usage = 200
	allowed_roles = OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER
