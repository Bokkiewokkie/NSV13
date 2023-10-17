/*
Woe betide ye who tread here.

Been a mess since 2018, we'll fix it someday (probably)
*/

/obj/structure/overmap/small_craft
	name = "Space Fighter"
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	icon_state = "fighter"
	anchored = TRUE
	brakes = TRUE
	armor = list("melee" = 80, "bullet" = 50, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 80) //temp to stop easy destruction from small arms
	bound_width = 64 //Change this on a per ship basis
	bound_height = 64
	mass = MASS_TINY
	overmap_deletion_traits = DAMAGE_ALWAYS_DELETES
	deletion_teleports_occupants = TRUE
	sprite_size = 32
	damage_states = TRUE
	faction = "nanotrasen"
	max_integrity = 250 //Really really squishy!
	forward_maxthrust = 3.5
	backward_maxthrust = 3.5
	side_maxthrust = 4
	max_angular_acceleration = 180
	torpedoes = 0
	missiles = 0
	speed_limit = 7 //We want fighters to be way more maneuverable
	weapon_safety = TRUE //This happens wayy too much for my liking. Starts ON.
	pixel_w = -16
	pixel_z = -20
	var/flight_pixel_w = -30
	var/flight_pixel_z = -32
	pixel_collision_size_x = 32
	pixel_collision_size_y = 32 //Avoid center tile viewport jank
	req_one_access = list(ACCESS_COMBAT_PILOT)
	var/start_emagged = FALSE
	max_paints = 1 // Only one target per fighter
	var/max_passengers = 0 //Change this per fighter.
	//Component to handle the fighter's loadout, weapons, parts, the works.
	var/loadout_type = LOADOUT_DEFAULT_FIGHTER
	var/datum/component/ship_loadout/loadout = null
	var/obj/structure/fighter_launcher/mag_lock = null //Mag locked by a launch pad. Cheaper to use than locate()
	var/canopy_open = TRUE
	var/master_caution = FALSE //The big funny warning light on the dash.
	var/list/components = list() //What does this fighter start off with? Use this to set what engine tiers and whatever it gets.
	var/maintenance_mode = FALSE //Munitions level IDs can change this.
	var/dradis_type =/obj/machinery/computer/ship/dradis/internal
	autotarget = TRUE
	no_gun_cam = TRUE
	var/obj/machinery/computer/ship/navigation/starmap = null
	var/resize_factor = 1 //How far down should we scale when we fly onto the overmap?
	var/escape_pod_type = /obj/structure/overmap/small_craft/escapepod
	var/mutable_appearance/canopy
	var/random_name = TRUE
	overmap_verbs = list(.verb/toggle_brakes, .verb/toggle_inertia, .verb/toggle_safety, .verb/show_dradis, .verb/cycle_firemode, .verb/show_control_panel, .verb/change_name, .verb/countermeasure)
	var/busy = FALSE

/obj/structure/overmap/small_craft/Destroy()
	var/mob/last_pilot = pilot // Old pilot gets first shot
	for(var/mob/M as() in operators)
		stop_piloting(M, eject_mob=FALSE) // We'll handle kicking them out ourselves
	if(length(mobs_in_ship))
		var/obj/structure/overmap/small_craft/escapepod = null
		if(ispath(escape_pod_type))
			escapepod = create_escape_pod(escape_pod_type, last_pilot)
		if(!escapepod && deletion_teleports_occupants)
			var/list/copy_of_mobs_in_ship = mobs_in_ship.Copy() //Sometimes you really need to iterate on a list while it's getting modified
			for(var/mob/living/M in copy_of_mobs_in_ship)
				to_chat(M, "<span class='warning'>This ship is not equipped with an escape pod! Unable to eject.</span>")
				M.apply_damage(200)
				eject(M, force=TRUE)

	last_overmap?.overmaps_in_ship -= src
	return ..()

/obj/structure/overmap/small_craft/start_piloting(mob/living/carbon/user, position)
	. = ..()
	if(.)
		RegisterSignal(src, COMSIG_MOB_OVERMAP_CHANGE, PROC_REF(pilot_overmap_change))

/obj/structure/overmap/small_craft/key_down(key, client/user)
	if(disruption && prob(min(95, disruption)))
		to_chat(src, "The controls buzz angrily.")
		playsound(helm, 'sound/machines/buzz-sigh.ogg', 75, 1)
		return
	. = ..()

/obj/structure/overmap/small_craft/ui_state(mob/user)
	return GLOB.contained_state

/obj/structure/overmap/small_craft/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FighterControls")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/structure/overmap/small_craft/ui_data(mob/user)
	var/list/data = list()
	data["obj_integrity"] = obj_integrity
	data["max_integrity"] = max_integrity
	var/obj/item/fighter_component/armour_plating/A = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	data["armour_integrity"] = (A) ? A.obj_integrity : 0
	data["max_armour_integrity"] = (A) ? A.max_integrity : 100

	var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery_charge"] = B ? B.charge : 0
	data["battery_max_charge"] = B ? B.maxcharge : 0
	data["brakes"] = brakes
	data["inertial_dampeners"] = inertial_dampeners
	data["mag_locked"] = (mag_lock) ? TRUE : FALSE
	data["canopy_lock"] = canopy_open
	data["weapon_safety"] = weapon_safety
	data["master_caution"] = master_caution
	data["rwr"] = length(enemies) ? TRUE : FALSE
	data["target_lock"] = length(target_painted) ? TRUE : FALSE
	data["fuel_warning"] = get_fuel() <= get_max_fuel()*0.4
	data["fuel"] = get_fuel()
	data["max_fuel"] = get_max_fuel()
	data["hardpoints"] = list()
	data["maintenance_mode"] = maintenance_mode //Todo
	var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	data["docking_mode"] = DC && DC.docking_mode
	data["docking_cooldown"] = is_docking_on_cooldown()
	var/obj/item/fighter_component/countermeasure_dispenser/CD = loadout.get_slot(HARDPOINT_SLOT_COUNTERMEASURE)
	data["countermeasures"] = CD ? CD.charges : 0
	data["max_countermeasures"] = CD ? CD.max_charges : 0
	var/obj/item/fighter_component/primary/P = loadout.get_slot(HARDPOINT_SLOT_PRIMARY)
	data["primary_ammo"] = P ? P.get_ammo() : 0
	data["max_primary_ammo"] = P ? P.get_max_ammo() : 0
	var/obj/item/fighter_component/secondary/S = loadout.get_slot(HARDPOINT_SLOT_SECONDARY)
	data["secondary_ammo"] = S ? S.get_ammo() : 0
	data["max_secondary_ammo"] = S ? S.get_max_ammo() : 0

	var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
	data["fuel_pump"] = APU ? APU.fuel_line : FALSE

	var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	data["battery"] = battery? battery.active : battery

	data["apu"] = APU.active
	var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	data["ignition"] = engine ? engine.active() : FALSE
	data["rpm"] = engine? engine.rpm : 0

	var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
	if(ftl)
		data["ftl_capable"] = TRUE
		data["ftl_spool_progress"] = ftl.progress
		data["ftl_spool_time"] = ftl.spoolup_time
		data["jump_ready"] = ftl.progress >= ftl.spoolup_time
		data["ftl_active"] = ftl.active
		data["ftl_target"] = ftl.anchored_to?.name
	else
		data["ftl_capable"] = FALSE
		data["ftl_spool_progress"] = 0
		data["ftl_spool_time"] = 0
		data["jump_ready"] = FALSE
		data["ftl_active"] = FALSE
		data["ftl_target"] = FALSE

	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/weapon = loadout.hardpoint_slots[slot]
		//Look for any "primary" hardpoints, be those guns or utility slots
		if(!weapon)
			continue
		if(weapon.fire_mode == FIRE_MODE_ANTI_AIR)
			data["primary_ammo"] = weapon.get_ammo()
			data["max_primary_ammo"] = weapon.get_max_ammo()
		if(weapon.fire_mode == FIRE_MODE_TORPEDO)
			data["secondary_ammo"] = weapon.get_ammo()
			data["max_secondary_ammo"] = weapon.get_max_ammo()
	var/list/hardpoints_info = list()
	var/list/occupants_info = list()
	for(var/obj/item/fighter_component/FC in contents)
		if(isliving(FC))
			var/mob/living/L = FC
			var/list/occupant_info = list()
			occupant_info["name"] = L.name
			occupant_info["id"] = "\ref[L]"
			occupant_info["afk"] = (L.mind) ? "Active" : "Inactive (SSD)"
			occupants_info[++occupants_info.len] = occupant_info
			continue
		if(!istype(FC))
			continue
		var/list/hardpoint_info = list()
		hardpoint_info["name"] = FC.name
		hardpoint_info["desc"] = FC.desc
		hardpoint_info["id"] = "\ref[FC]"
		hardpoints_info[++hardpoints_info.len] = hardpoint_info
	data["hardpoints"] = hardpoints_info
	data["occupants_info"] = occupants_info
	return data

/obj/structure/overmap/small_craft/ui_act(action, params, datum/tgui/ui)
	if(..() || ((usr != pilot) && (!IsAdminGhost(usr))))
		return
	if(disruption && prob(min(95, disruption)))
		to_chat(src, "The controls buzz angrily.")
		relay('sound/machines/buzz-sigh.ogg')
		return
	var/atom/movable/target = locate(params["id"])
	switch(action)
		if("examine")
			if(!target)
				return
			to_chat(usr, "<span class='notice'>[target.desc]</span>")
		if("eject_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC))
				return
			to_chat(usr, "<span class='notice'>You start uninstalling [target.name] from [src].</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You uninstall [target.name] from [src].</span>")
			loadout.remove_hardpoint(FC, FALSE)
		if("dump_hardpoint")
			if(!target)
				return
			var/obj/item/fighter_component/FC = target
			if(!istype(FC) || !FC.contents?.len)
				return
			to_chat(usr, "<span class='notice'>You start to unload [target.name]'s stored contents...</span>")
			if(!do_after(usr, 5 SECONDS, target=src))
				return
			to_chat(usr, "<span class='notice>You dump [target.name]'s contents.</span>")
			loadout.dump_contents(FC)
		if("kick")
			if(!target)
				return
			if(!allowed(usr) || usr != pilot)
				return
			var/mob/living/L = target
			to_chat(L, "<span class='warning'>You have been kicked out of [src] by the pilot.</span>")
			canopy_open = FALSE
			toggle_canopy()
			stop_piloting(L)
		if("fuel_pump")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
				return
			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>You can't send fuel to an APU that isn't installed.</span>")
			APU.toggle_fuel_line()
			playsound(src, 'nsv13/sound/effects/fighters/warmup.ogg', 100, FALSE)
		if("battery")
			var/obj/item/fighter_component/battery/battery = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
			if(!battery)
				to_chat(usr, "<span class='warning'>[src] does not have a battery installed!</span>")
				return
			battery.toggle()
			to_chat(usr, "You flip the battery switch.</span>")
		if("apu")
			var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
			if(!APU)
				to_chat(usr, "<span class='warning'>[src] does not have an APU installed!</span>")
				return
			APU.toggle()
			playsound(src, 'nsv13/sound/effects/fighters/warmup.ogg', 100, FALSE)
		if("ignition")
			var/obj/item/fighter_component/engine/engine = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
			if(!engine)
				to_chat(usr, "<span class='warning'>[src] does not have an engine installed!</span>")
				return
			engine.try_start()
		if("canopy_lock")
			var/obj/item/fighter_component/canopy/canopy = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
			if(!canopy)
				return
			toggle_canopy()
		if("docking_mode")
			var/obj/item/fighter_component/docking_computer/DC = loadout.get_slot(HARDPOINT_SLOT_DOCKING)
			if(!DC || !istype(DC))
				to_chat(usr, "<span class='warning'>[src] does not have a docking computer installed!</span>")
				return
			to_chat(usr, "<span class='notice'>You [DC.docking_mode ? "disengage" : "engage"] [src]'s docking computer.</span>")
			DC.docking_mode = !DC.docking_mode
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("brakes")
			toggle_brakes()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("inertial_dampeners")
			toggle_inertia()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("weapon_safety")
			toggle_safety()
			relay('nsv13/sound/effects/fighters/switch.ogg')
			return
		if("target_lock")
			relay('nsv13/sound/effects/fighters/switch.ogg')
			dump_locks()
			return
		if("mag_release")
			if(!mag_lock)
				return
			mag_lock.abort_launch()
		if("master_caution")
			set_master_caution(FALSE)
			return
		if("show_dradis")
			dradis?.ui_interact(usr)
			return
		if("toggle_ftl")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				to_chat(usr, "<span class='warning'>FTL unit not properly installed.</span>")
				return
			ftl.toggle()
			relay('nsv13/sound/effects/fighters/switch.ogg')
		if("anchor_ftl")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				to_chat(usr, "<span class='warning'>FTL unit not properly installed.</span>")
				return
			var/obj/structure/overmap/new_target = get_overmap()
			if(new_target)
				ftl.anchored_to = new_target
			else
				to_chat(usr, "<span class='warning'>Unable to update telemetry. Ensure you are in proximity to a Seegson FTL drive.</span>")
			relay('nsv13/sound/effects/fighters/switch.ogg')
		if("return_jump")
			var/obj/item/fighter_component/ftl/ftl = loadout.get_slot(HARDPOINT_SLOT_FTL)
			if(!ftl)
				return
			if(ftl.ftl_state != FTL_STATE_READY)
				to_chat(usr, "<span class='warning'>Unable to comply. FTL vector calculation still in progress.</span>")
				return
			if(!ftl.anchored_to)
				to_chat(usr, "<span class='warning'>Unable to comply. FTL tether lost.</span>")
				return
			var/datum/star_system/dest = SSstar_system.ships[ftl.anchored_to]["current_system"]
			if(!dest)
				to_chat(usr, "<span class='warning'>Unable to comply. Target beacon is currently in FTL transit.</span>")
				return
			ftl.jump(dest)
			return
		if("set_name")
			var/new_name = stripped_input(usr, message="What do you want to name \
				your fighter? Keep in mind that particularly terrible names may be \
				rejected by your employers.", max_length=MAX_CHARTER_LEN)
			if(!new_name || length(new_name) <= 0)
				return
			message_admins("[key_name_admin(usr)] renamed a fighter to [new_name] [ADMIN_LOOKUPFLW(src)].")
			name = new_name
			return
		if("toggle_maintenance")
			maintenance_mode = !maintenance_mode
			return

	relay('nsv13/sound/effects/fighters/switch.ogg')

// Bypass the z level checks done by parent
/obj/structure/overmap/small_craft/forceMove(atom/destination)
	return doMove(destination)

/obj/structure/overmap/small_craft/combat/light
	name = "Su-818 Rapier"
	desc = "An Su-818 Rapier space superiorty fighter craft. Designed for high maneuvreability and maximum combat effectiveness against other similar weight classes."
	icon = 'nsv13/icons/overmap/nanotrasen/fighter.dmi'
	armor = list("melee" = 60, "bullet" = 60, "laser" = 60, "energy" = 30, "bomb" = 30, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 10, "overmap_medium" = 5, "overmap_heavy" = 90)
	sprite_size = 32
	damage_states = FALSE //temp
	max_integrity = 200 //Really really squishy!
	max_angular_acceleration = 200
	speed_limit = 10
	pixel_w = -16
	pixel_z = -20
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/secondary/ordnance_launcher,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon)

/obj/structure/overmap/small_craft/escapepod
	name = "Escape Pod"
	desc = "An escape pod launched from a space faring vessel. It only has very limited thrusters and is thus very slow."
	icon = 'nsv13/icons/overmap/nanotrasen/escape_pod.dmi'
	icon_state = "escape_pod"
	damage_states = FALSE
	bound_width = 32 //Change this on a per ship basis
	bound_height = 32
	pixel_z = 0
	pixel_w = 0
	max_integrity = 500 //Able to withstand more punishment so that people inside it don't get yeeted as hard
	canopy_open = FALSE
	essential = TRUE
	escape_pod_type = null // This would just be silly
	speed_limit = 2 //This, for reference, will feel suuuuper slow, but this is intentional
	loadout_type = LOADOUT_UTILITY_ONLY
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/countermeasure_dispenser)

/obj/structure/overmap/small_craft/escapepod/stop_piloting(mob/living/M, eject_mob=TRUE, force=FALSE)
	if(!force && !SSmapping.level_trait(z, ZTRAIT_BOARDABLE))
		return FALSE
	return ..()

/obj/structure/overmap/small_craft/combat/heavy
	name = "Su-410 Scimitar"
	desc = "An Su-410 Scimitar heavy attack craft. It's a lot beefier than its Rapier cousin and is designed to take out capital ships, due to the weight of its modules however, it is extremely slow."
	icon = 'nsv13/icons/overmap/nanotrasen/heavy_fighter.dmi'
	icon_state = "heavy_fighter"
	armor = list("melee" = 80, "bullet" = 80, "laser" = 80, "energy" = 50, "bomb" = 50, "bio" = 100, "rad" = 90, "fire" = 90, "acid" = 80, "overmap_light" = 25, "overmap_medium" = 20, "overmap_heavy" = 90)
	sprite_size = 32
	damage_states = FALSE //TEMP
	max_integrity = 300 //Not so squishy!
	pixel_w = -16
	pixel_z = -20
	speed_limit = 8
	forward_maxthrust = 8
	backward_maxthrust = 8
	side_maxthrust = 7.75
	max_angular_acceleration = 80
	components = list(/obj/item/fighter_component/fuel_tank,
						/obj/item/fighter_component/avionics,
						/obj/item/fighter_component/apu,
						/obj/item/fighter_component/armour_plating,
						/obj/item/fighter_component/targeting_sensor,
						/obj/item/fighter_component/engine,
						/obj/item/fighter_component/countermeasure_dispenser,
						/obj/item/fighter_component/oxygenator,
						/obj/item/fighter_component/canopy,
						/obj/item/fighter_component/docking_computer,
						/obj/item/fighter_component/secondary/ordnance_launcher/torpedo,
						/obj/item/fighter_component/battery,
						/obj/item/fighter_component/primary/cannon/heavy)

//Syndie counterparts.
/obj/structure/overmap/small_craft/combat/light/syndicate //PVP MODE
	name = "Syndicate Light Fighter"
	desc = "The Syndicate's answer to Nanotrasen's light fighter craft, this fighter is designed to maintain aerial supremacy."
	icon = 'nsv13/icons/overmap/syndicate/syn_rapier.dmi'
	req_one_access = ACCESS_SYNDICATE
	faction = "syndicate"
	start_emagged = TRUE

/obj/structure/overmap/small_craft/Initialize(mapload, list/build_components=components)
	. = ..()
	if(random_name)
		name = generate_fighter_name()
	apply_weapons()
	loadout = AddComponent(loadout_type)
	if(dradis_type)
		dradis = new dradis_type(src) //Fighters need a way to find their way home.
		dradis.linked = src
	set_light(4)
	obj_integrity = max_integrity
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(handle_moved)) //Used to smoothly transition from ship to overmap
	var/obj/item/fighter_component/engine/engineGoesLast = null
	if(build_components.len)
		for(var/Ctype in build_components)
			var/obj/item/fighter_component/FC = new Ctype(get_turf(src), mapload)
			if(istype(FC, /obj/item/fighter_component/engine))
				engineGoesLast = FC
				continue
			loadout.install_hardpoint(FC)
	//Engines need to be the last thing that gets installed on init, or it'll cause bugs with drag.
	if(engineGoesLast)
		loadout.install_hardpoint(engineGoesLast)
	obj_integrity = max_integrity //Update our health to reflect how much armour we've been given.
	set_fuel(rand(500, 1000))
	if(start_emagged)
		obj_flags ^= EMAGGED
	canopy = mutable_appearance(icon = icon, icon_state = "canopy_open")
	add_overlay(canopy)
	update_visuals()

/obj/structure/overmap/small_craft/attackby(obj/item/W, mob/user, params)
	if(operators && LAZYFIND(operators, user))
		to_chat(user, "<span class='warning'>You can't reach [src]'s exterior from in here.</span>")
		return FALSE
	for(var/slot in loadout.equippable_slots)
		var/obj/item/fighter_component/FC = loadout.get_slot(slot)
		if(FC?.load(src, W))
			return FALSE
	if(istype(W, /obj/item/fighter_component))
		var/obj/item/fighter_component/FC = W
		loadout.install_hardpoint(FC)
		return FALSE
	..()

/obj/structure/overmap/small_craft/MouseDrop_T(atom/movable/target, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE
	if(isobj(target))
		if(operators && LAZYFIND(operators, user))
			to_chat(user, "<span class='warning'>You can't reach [src]'s exterior from in here..</span>")
			return FALSE
		for(var/slot in loadout.equippable_slots)
			var/obj/item/fighter_component/FC = loadout.get_slot(slot)
			if(FC?.load(src, target))
				return FALSE
	else if(isliving(target))
		if(allowed(user))
			if(!canopy_open)
				playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
				user.visible_message("<span class='warning'>You bang on the canopy.</span>", "<span class='warning'>[user] bangs on [src]'s canopy.</span>")
				return FALSE
			if(operators.len >= max_passengers)
				to_chat(user, "<span class='warning'>[src]'s passenger compartment is full!")
				return FALSE
			to_chat(target, "[(user == target) ? "You start to climb into [src]'s passenger compartment" : "[user] starts to lift you into [src]'s passenger compartment"]")
			if(do_after(user, 2 SECONDS, target=src))
				start_piloting(user, OVERMAP_USER_ROLE_OBSERVER)
				enter(user)
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")

/obj/structure/overmap/small_craft/finish_lockon(obj/structure/overmap/target, data_link)
	if(disruption)
		to_chat(pilot, "<span class='warning'>ERROR: TGP NOT READY.</span>")
		return FALSE
	. = ..()

/obj/structure/overmap/small_craft/proc/enter(mob/user)
	var/obj/structure/overmap/OM = user.get_overmap()
	if(OM)
		OM.mobs_in_ship -= user
	user.forceMove(src)
	mobs_in_ship |= user
	user.last_overmap = src //Allows update_overmap to function properly when the pilot leaves their fighter
	if((user.client?.prefs.toggles & PREFTOGGLE_SOUND_AMBIENCE) && user.can_hear_ambience() && engines_active()) //Disable ambient sounds to shut up the noises.
		SEND_SOUND(user, sound('nsv13/sound/effects/fighters/cockpit.ogg', repeat = TRUE, wait = 0, volume = 50, channel=CHANNEL_SHIP_ALERT))

/obj/structure/overmap/small_craft/stop_piloting(mob/living/M, eject_mob=TRUE, force=FALSE)
	if(eject_mob && !eject(M, force))
		return FALSE
	UnregisterSignal(src, COMSIG_MOB_OVERMAP_CHANGE)
	M.stop_sound_channel(CHANNEL_SHIP_ALERT)
	M.remove_verb(overmap_verbs)
	return ..()

/obj/structure/overmap/small_craft/proc/eject(mob/living/M, force=FALSE)
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(!canopy_open && C && !force)
		to_chat(M, "<span class='warning'>[src]'s canopy isn't open.</span>")
		if(prob(50))
			playsound(src, 'sound/effects/glasshit.ogg', 75, 1)
			to_chat(M, "<span class='warning'>You bump your head on [src]'s canopy.</span>")
			visible_message("<span class='warning'>You hear a muffled thud.</span>")
		return FALSE

	if(!force && !SSmapping.level_trait(z, ZTRAIT_BOARDABLE) && !SSmapping.level_trait(z, ZTRAIT_RESERVED))
		to_chat(M, "<span class='warning'>[src] won't let you jump out of it mid flight.</span>")
		return FALSE

	SEND_SOUND(M, sound(null))
	mobs_in_ship -= M
	M.forceMove(get_turf(src))
	return TRUE

/obj/structure/overmap/small_craft/proc/pilot_overmap_change(mob/living/M, obj/structure/overmap/newOM) // in case we get forceMoved outside of the ship somehow
	SIGNAL_HANDLER
	if(newOM != src)
		INVOKE_ASYNC(src, PROC_REF(stop_piloting), M, FALSE, TRUE)

/obj/structure/overmap/small_craft/escapepod/eject(mob/living/M, force=FALSE)
	. = ..()
	if(. && !length(mobs_in_ship) && !(QDELETED(src) || QDESTROYING(src))) // Last one out means we don't need this anymore
		qdel(src)

/obj/structure/overmap/small_craft/proc/create_escape_pod(path, mob/last_pilot)
	// Create pod
	var/obj/structure/overmap/small_craft/escapepod/escape_pod = new path(get_turf(src))
	if(!istype(escape_pod))
		qdel(escape_pod)
		return
	escape_pod.name = "[name] - escape pod"
	escape_pod.faction = faction
	escape_pod.last_overmap = last_overmap
	escape_pod.current_system = current_system
	current_system.system_contents += escape_pod
	escape_pod.desired_angle = 0
	escape_pod.user_thrust_dir = NORTH
	var/obj/item/fighter_component/docking_computer/DC = escape_pod.loadout.get_slot(HARDPOINT_SLOT_DOCKING)
	DC.docking_mode = TRUE
	relay_to_nearby('nsv13/sound/effects/ship/fighter_launch_short.ogg')

	// Transfer occupants
	if(length(mobs_in_ship))
		relay('nsv13/sound/effects/computer/alarm_3.ogg', "<span class=userdanger>EJECT! EJECT! EJECT!</span>")
		visible_message("<span class=userdanger>Auto-Ejection Sequence Enabled! Escape Pod Launched!</span>")

		if(last_pilot && !last_pilot.incapacitated())
			last_pilot.doMove(escape_pod)
			escape_pod.start_piloting(last_pilot, OVERMAP_USER_ROLE_PILOT)
			escape_pod.attack_hand(last_pilot) // Bring up UI
			mobs_in_ship -= last_pilot
			escape_pod.mobs_in_ship |= last_pilot
			last_pilot.overmap_ship = escape_pod

		for(var/mob/M as() in mobs_in_ship)
			M.doMove(escape_pod)
			if(!escape_pod.pilot || escape_pod.pilot.incapacitated()) // Someone please drive this thing
				escape_pod.start_piloting(M, OVERMAP_USER_ROLE_PILOT)
				escape_pod.ui_interact(M)
			else
				escape_pod.start_piloting(M, OVERMAP_USER_ROLE_OBSERVER)
			escape_pod.mobs_in_ship |= M
			M.overmap_ship = escape_pod
	mobs_in_ship.Cut()

	return escape_pod

/obj/structure/overmap/small_craft/attack_hand(mob/user)
	. = ..()
	if(allowed(user))
		if(pilot)
			to_chat(user, "<span class='notice'>[src] already has a pilot.</span>")
			return FALSE
		if(do_after(user, 2 SECONDS, target=src))
			enter(user)
			start_piloting(user, (OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER))
			to_chat(user, "<span class='notice'>You climb into [src]'s cockpit.</span>")
			ui_interact(user)
			to_chat(user, "<span class='notice'>Small craft use directional keys (WASD in hotkey mode) to accelerate/decelerate in a given direction and the mouse to change the direction of craft.\
						Mouse 1 will fire the selected weapon (if applicable).</span>")
			to_chat(user, "<span class='warning'>=Hotkeys=</span>")
			to_chat(user, "<span class='notice'>Use <b>tab</b> to activate hotkey mode, then:</span>")
			to_chat(user, "<span class='notice'>Use the <b> Ctrl + Scroll Wheel</b> to zoom in / out. \
						Press <b>Space</b> to cycle fire modes. \
						Press <b>X</b> to cycle inertial dampners. \
						Press <b>Alt<b> to cycle the handbrake. \
						Press <b>C<b> to cycle mouse free movement.</span>")
			return TRUE

/obj/structure/overmap/small_craft/proc/force_eject(force = FALSE)
	. = list()
	brakes = TRUE
	if(!canopy_open)
		canopy_open = TRUE
		playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)
	for(var/mob/M in mobs_in_ship)
		stop_piloting(M, TRUE, force)
		M.forceMove(get_turf(src))
		to_chat(M, "<span class='warning'>You have been remotely ejected from [src]!.</span>")
		. += M

//Iconic proc.
/obj/structure/overmap/small_craft/proc/foo()
	set_fuel(1000)
	var/obj/item/fighter_component/apu/APU = loadout.get_slot(HARDPOINT_SLOT_APU)
	APU.fuel_line = TRUE
	var/obj/item/fighter_component/battery/B = loadout.get_slot(HARDPOINT_SLOT_BATTERY)
	B.active = TRUE
	B.charge = B.maxcharge
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)
	E.rpm = ENGINE_RPM_SPUN
	E.try_start()
	toggle_canopy()
	forceMove(locate(250, y, z))
	//check_overmap_elegibility(TRUE)

/obj/structure/overmap/small_craft/proc/throw_pilot(damage = 200) //Used when yeeting a pilot out of an exploding ship
	if(SSmapping.level_trait(z, ZTRAIT_OVERMAP)) //Check if we're on the overmap
		damage *= 2
	var/list/victims = force_eject(TRUE)
	for(var/mob/living/M as() in victims)
		M.apply_damage(damage)


/obj/structure/overmap/small_craft/attackby(obj/item/W, mob/user, params)   //fueling and changing equipment
	add_fingerprint(user)
	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/modular_computer/tablet/pda) && length(operators))
		if(!allowed(user))
			var/ersound = pick('nsv13/sound/effects/computer/error.ogg','nsv13/sound/effects/computer/error2.ogg','nsv13/sound/effects/computer/error3.ogg')
			playsound(src, ersound, 100, 1)
			to_chat(user, "<span class='warning'>Access denied</span>")
			return
		if(alert("What do you want to do?",name,"Eject Occupants","Maintenance Mode") == "Eject Occupants")
			if(!Adjacent(user))
				return
			to_chat(user, "<span class='warning'>Ejecting all current occupants from [src] and activating inertial dampeners...</span>")
			force_eject()
		else
			if(!Adjacent(user))
				return
			to_chat(user, "<span class='warning'>You swipe your card and [maintenance_mode ? "disable" : "enable"] maintenance protocols.</span>")
			maintenance_mode = !maintenance_mode

	if(istype(W, /obj/item/ship_weapon/ammunition/countermeasure_charge))
		var/obj/item/ship_weapon/ammunition/countermeasure_charge/CC = W
		var/obj/item/fighter_component/countermeasure_dispenser/CD = loadout.get_slot(HARDPOINT_SLOT_COUNTERMEASURE)
		if(CD)
			if(CD.charges == CD.max_charges)
				to_chat("<span class='warning'>You try to insert the countermeasure charge, but there's no space for more charges in the countermeasure dispenser!</span>")
			else
				var/ChargeChange = clamp(CC.restock_amount + CD.charges, CD.max_charges, 0) - CD.charges
				to_chat("<span>You successfully reload the countermeasure dispenser in [src]</span>")
				CC.restock_amount -= ChargeChange
				CD.charges += ChargeChange
				if(CC.restock_amount == 0)
					qdel(W)
		else
			to_chat("<span class='warning'>You try to insert the countermeasure charge, but there's nothing to put it in!</span>")
	return ..()


/obj/structure/overmap/small_craft/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, bypasses_shields = FALSE)
	var/obj/item/fighter_component/armour_plating/A = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
	if(A && istype(A))
		A.take_damage(damage_amount, damage_type, damage_flag, sound_effect)
		if(A.obj_integrity <= 0)
			loadout.remove_hardpoint(A, TRUE)
			qdel(A) //There goes your armour!
		relay(pick('nsv13/sound/effects/ship/freespace2/ding1.wav', 'nsv13/sound/effects/ship/freespace2/ding2.wav', 'nsv13/sound/effects/ship/freespace2/ding3.wav', 'nsv13/sound/effects/ship/freespace2/ding4.wav', 'nsv13/sound/effects/ship/freespace2/ding5.wav'))
	else
		. = ..()
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(!C) //Riding without a canopy is not without consequences
		if(prob(30)) //Ouch!
			for(var/mob/living/M in contents)
				to_chat(M , "<span class='warning'>You feel something hit you!</span>")
				M.take_overall_damage(damage_amount/2)
		return
	if(prob(50))
		relay('sound/effects/glasshit.ogg')
		C.take_damage(damage_amount/2, damage_type, damage_flag, sound_effect)
		if(C.obj_integrity <= 0)
			canopy_breach(C)

/obj/structure/overmap/small_craft/proc/canopy_breach(obj/item/fighter_component/canopy/C)
	set waitfor = FALSE
	relay('nsv13/sound/effects/ship/cockpit_breach.ogg') //We're leaking air!
	loadout.remove_hardpoint(HARDPOINT_SLOT_CANOPY, TRUE)
	qdel(C) //Pop off the canopy.
	update_visuals()
	sleep(2 SECONDS)
	relay('nsv13/sound/effects/ship/reactor/gasmask.ogg', "<span class='warning'>The air around you rushes out of the breached canopy!</span>", loop = FALSE, channel = CHANNEL_SHIP_ALERT)

/obj/structure/overmap/small_craft/welder_act(mob/living/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return FALSE
	if(obj_integrity >= max_integrity)
		to_chat(user, "<span class='notice'>[src] isn't in need of repairs.</span>")
		return TRUE
	if(busy)
		to_chat(user, "<span class='warning'>Someone's already repairing [src]!</span>")
		return TRUE
	busy = TRUE
	to_chat(user, "<span class='notice'>You start welding some dents out of [src]'s hull...</span>")
	while(obj_integrity < max_integrity)
		if(!I.use_tool(src, user, 1 SECONDS, volume=100))
			busy = FALSE
			return TRUE
		obj_integrity += 25
		if(obj_integrity >= max_integrity)
			obj_integrity = max_integrity
			break
	to_chat(user, "<span class='notice'>You finish welding[obj_integrity == max_integrity ? "" : " some of"] the dents out of [src]'s hull.</span>")
	busy = FALSE
	return TRUE

/obj/structure/overmap/small_craft/InterceptClickOn(mob/user, params, atom/target)
	if(user.incapacitated() || !isliving(user))
		return FALSE
	if(istype(target, /obj/machinery/button/door) || istype(target, /obj/machinery/turbolift_button))
		target.attack_hand(user)
		return FALSE
	if((target == src) && (user == pilot))
		helm?.ui_interact(user)
		return FALSE
	if((target == src) && (user == gunner))
		tactical?.ui_interact(user)
		return FALSE
	return ..()

/obj/structure/overmap/small_craft/can_friendly_fire()
	if(fire_mode == 1)
		var/obj/item/fighter_component/primary/P = loadout.get_slot(HARDPOINT_SLOT_UTILITY_PRIMARY)
		return (P && istype(P) && P.bypass_safety)
	else if(fire_mode == 2)
		var/obj/item/fighter_component/secondary/S = loadout.get_slot(HARDPOINT_SLOT_UTILITY_SECONDARY)
		return (S && istype(S) && S.bypass_safety)
	return FALSE

/obj/structure/overmap/small_craft/try_repair(amount)
	if(obj_integrity < max_integrity)
		..()
	else
		var/obj/item/fighter_component/armour_plating/armour = loadout.get_slot(HARDPOINT_SLOT_ARMOUR)
		armour.obj_integrity = CLAMP(armour.obj_integrity + amount, 0, armour.max_integrity)

/datum/component/ship_loadout
	can_transfer = FALSE
	var/list/equippable_slots = ALL_HARDPOINT_SLOTS //What slots does this loadout support? Want to allow a fighter to have multiple utility slots?
	var/list/hardpoint_slots = list()
	var/obj/structure/overmap/holder //To get overmap class vars.

/datum/component/ship_loadout/utility
	equippable_slots = HARDPOINT_SLOTS_UTILITY

/datum/component/ship_loadout/Initialize(source)
	. = ..()
	if(!istype(parent, /obj/structure/overmap))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSobj, src)
	holder = parent
	for(var/hardpoint in equippable_slots)
		hardpoint_slots[hardpoint] = null

/datum/component/ship_loadout/proc/get_slot(slot)
	RETURN_TYPE(/obj/item/fighter_component)
	return hardpoint_slots[slot]

/datum/component/ship_loadout/proc/install_hardpoint(obj/item/fighter_component/replacement)
	var/slot = replacement.slot
	if(slot && !(slot in equippable_slots))
		replacement.visible_message("<span class='warning'>[replacement] can't fit onto [parent]")
		return FALSE
	remove_hardpoint(slot, FALSE)
	replacement.on_install(holder)
	if(slot) //Not every component has a slot per se, as some are just used for construction and can't really be interacted with.
		hardpoint_slots[slot] = replacement

/**
Method to remove a hardpoint from the loadout. It can be passed a slot as a defined flag, or slot as a physical hardpoint (as not all hardpoints have a specific slot.)
args:
slot: Either a slot or a specific component
due_to_damage: Was this called voluntarily (FALSE) or due to damage / external causes (TRUE). Is given to the remove_from() proc and modifies specifics of the removal.
*/
/datum/component/ship_loadout/proc/remove_hardpoint(slot, due_to_damage)
	if(!slot)
		return FALSE

	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
		hardpoint_slots[component.slot] = null
	else
		component = get_slot(slot)
		hardpoint_slots[slot] = null

	if(component && istype(component))
		component.remove_from(holder, due_to_damage)

/datum/component/ship_loadout/proc/dump_contents(slot)
	var/obj/item/fighter_component/component = null
	if(istype(slot, /obj/item/fighter_component))
		component = slot
	else
		component = get_slot(slot)
	component.dump_contents()

/datum/component/ship_loadout/process(delta_time)
	for(var/slot in equippable_slots)
		var/obj/item/fighter_component/component = hardpoint_slots[slot]
		component?.process(delta_time)

//Fuel
/obj/structure/overmap/small_craft/proc/get_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	var/datum/reagent/cryogenic_fuel/F = locate() in ft?.reagents.reagent_list
	return F ? F.volume : 0

/obj/structure/overmap/small_craft/proc/set_fuel(amount)
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.add_reagent(/datum/reagent/cryogenic_fuel, amount, reagtemp = 40) //Assert that we have this reagent in the tank.
	for(var/datum/reagent/cryogenic_fuel/F in ft?.reagents.reagent_list)
		if(!istype(F))
			continue
		F.volume = amount
	return amount

/obj/structure/overmap/small_craft/proc/engines_active()
	var/obj/item/fighter_component/engine/E = loadout.get_slot(HARDPOINT_SLOT_ENGINE)//E's are good E's are good, he's ebeneezer goode.
	return E?.active() && get_fuel() > 0

/obj/structure/overmap/small_craft/proc/set_master_caution(state)
	var/master_caution_switch = state
	if(master_caution_switch)
		relay('nsv13/sound/effects/fighters/master_caution.ogg', null, loop=TRUE, channel=CHANNEL_HEARTBEAT)
		master_caution = TRUE
	else
		stop_relay(CHANNEL_HEARTBEAT) //CONSIDER MAKING OWN CHANNEL
		master_caution = FALSE

/obj/structure/overmap/small_craft/proc/use_fuel(force=FALSE)
	if(!engines_active() && !force) //No fuel? don't spam them with master cautions / use any fuel
		return FALSE
	var/fuel_consumption = 0.5*(loadout.get_slot(HARDPOINT_SLOT_ENGINE)?.tier)
	var/amount = (user_thrust_dir) ? fuel_consumption+0.25 : fuel_consumption //When you're thrusting : fuel consumption doubles. Idling is cheap.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return FALSE
	ft.reagents.remove_reagent(/datum/reagent/cryogenic_fuel, amount)
	if(get_fuel() >= amount)
		return TRUE
	set_master_caution(TRUE)
	return FALSE

/obj/structure/overmap/small_craft/can_move()
	return engines_active()

/obj/structure/overmap/small_craft/escapepod/can_move()
	return TRUE

/obj/structure/overmap/small_craft/escapepod/engines_active()
	return TRUE

/obj/structure/overmap/small_craft/proc/empty_fuel_tank()//Debug purposes, for when you need to drain a fighter's tank entirely.
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	ft?.reagents.clear_reagents()

/obj/structure/overmap/small_craft/proc/get_max_fuel()
	var/obj/item/fighter_component/fuel_tank/ft = loadout.get_slot(HARDPOINT_SLOT_FUEL)
	if(!ft)
		return 0
	return ft.reagents.maximum_volume

//Weapons
//Ensure we get the genericised equipment mounts.
/obj/structure/overmap/small_craft/apply_weapons()
	if(!weapon_types[FIRE_MODE_ANTI_AIR])
		weapon_types[FIRE_MODE_ANTI_AIR] = new/datum/ship_weapon/fighter_primary(src)
	if(!weapon_types[FIRE_MODE_TORPEDO])
		weapon_types[FIRE_MODE_TORPEDO] = new/datum/ship_weapon/fighter_secondary(src)

//Burst arg currently unused for this proc.
/obj/structure/overmap/proc/primary_fire(obj/structure/overmap/target, ai_aim = FALSE, burst = 1)
	hardpoint_fire(target, FIRE_MODE_ANTI_AIR)

/obj/structure/overmap/proc/hardpoint_fire(obj/structure/overmap/target, fireMode)
	if(istype(src, /obj/structure/overmap/small_craft))
		var/obj/structure/overmap/small_craft/F = src
		for(var/slot in F.loadout.equippable_slots)
			var/obj/item/fighter_component/weapon = F.loadout.hardpoint_slots[slot]
			//Look for any "primary" hardpoints, be those guns or utility slots
			if(!weapon || weapon.fire_mode != fireMode)
				continue
			var/datum/ship_weapon/SW = weapon_types[weapon.fire_mode]
			spawn()
				for(var/I = 0; I < SW.burst_size; I++)
					weapon.fire(target)
					sleep(1)
			return TRUE
	return FALSE

//Burst arg currently unused for this proc.
/obj/structure/overmap/proc/secondary_fire(obj/structure/overmap/target, ai_aim = FALSE, burst = 1)
	hardpoint_fire(target, FIRE_MODE_TORPEDO)

/obj/structure/overmap/small_craft/proc/update_visuals()
	if(canopy)
		cut_overlay(canopy)
	else
		canopy = mutable_appearance(icon = icon, icon_state = "canopy_missing")
	var/obj/item/fighter_component/canopy/C = loadout?.get_slot(HARDPOINT_SLOT_CANOPY)
	if(QDELETED(C))
		canopy.icon_state = "canopy_missing"
	else if(C.obj_integrity <= 20)
		canopy.icon_state = "canopy_breach"
	else if(canopy_open)
		canopy.icon_state = "canopy_open"
	else
		return
	add_overlay(canopy)

/obj/structure/overmap/small_craft/slowprocess(delta_time)
	..()
	if(engines_active())
		use_fuel()
		loadout.process(delta_time)

	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)

	// Leak air if the canopy is missing or broken
	// and air is in the cabin
	// and the fighter's environment isn't pressurized

	if((!C || (C.obj_integrity <= 0)) && cabin_air.total_moles() > 0)
		var/datum/gas_mixture/outside_air = loc.return_air()
		var/outside_pressure = outside_air ? outside_air.return_pressure() : 0
		if(outside_pressure && (cabin_air.return_pressure() > outside_pressure))
			cabin_air.remove(min(cabin_air.total_moles(), 5))

	update_visuals()

/obj/structure/overmap/small_craft/return_air()
	var/obj/item/fighter_component/canopy/C = loadout.get_slot(HARDPOINT_SLOT_CANOPY)
	if(canopy_open || !C || (C.obj_integrity <= 0))
		return loc.return_air()
	return cabin_air

/obj/structure/overmap/small_craft/remove_air(amount)
	var/datum/gas_mixture/air = return_air()
	return air.remove(amount)

/obj/structure/overmap/small_craft/return_analyzable_air()
	return cabin_air

/obj/structure/overmap/small_craft/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	return t_air.return_temperature()

/obj/structure/overmap/small_craft/portableConnectorReturnAir()
	return return_air()

/obj/structure/overmap/small_craft/assume_air(datum/gas_mixture/giver)
	var/datum/gas_mixture/t_air = return_air()
	return t_air.merge(giver)

/obj/structure/overmap/small_craft/proc/toggle_canopy()
	canopy_open = !canopy_open
	playsound(src, 'nsv13/sound/effects/fighters/canopy.ogg', 100, 1)

