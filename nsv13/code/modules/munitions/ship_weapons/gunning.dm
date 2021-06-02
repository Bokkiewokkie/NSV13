//Gunning component for Gauss
/datum/component/overmap_gunning
	var/fire_mode = FIRE_MODE_GAUSS
	var/mob/living/holder = null
	var/atom/movable/autofire_target
	var/next_fire = 0
	var/fire_delay = 2 SECONDS
	var/obj/machinery/ship_weapon/fx_target = null
	var/special_fx = FALSE
    
/datum/component/overmap_gunning/Initialize(obj/machinery/ship_weapon/fx_target, special_fx=FALSE)
	. = ..()
	if(!istype(parent, /mob/living)) //Needs at least this base prototype.
		return COMPONENT_INCOMPATIBLE
	src.special_fx = special_fx
	src.fx_target = fx_target
	holder = parent
	start_gunning()

/datum/component/overmap_gunning/proc/start_gunning()
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	if(!OM)
		RemoveComponent() //Uh...OK?
		CRASH("Overmap gunning component created with no attached overmap.")
	OM.gauss_gunners.Add(holder)
	OM.start_piloting(holder, "secondary_gunner")
	START_PROCESSING(SSfastprocess, src)

/datum/component/overmap_gunning/proc/onClick(atom/movable/target)
	if(world.time < next_fire || !autofire_target)
		return FALSE
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	next_fire = world.time + fire_delay
	if(special_fx)
		fx_target.setDir(get_dir(OM, target))  //Makes the gun turn and shoot the target, wow!
	fx_target.fire(target)//You can only fire your gun, not someone else's.   //.fire_weapon(target, fire_mode)

/datum/component/overmap_gunning/process()
	if(!autofire_target)
		return
	onClick(autofire_target)

/datum/component/overmap_gunning/proc/onMouseUp(object, location, params, mob)
	autofire_target = null

/datum/component/overmap_gunning/proc/onMouseDown(object, location, params)
	if(!autofire_target)
		autofire_target = object //When we start firing, we start firing at whatever you clicked on initially. When the user drags their mouse, this shall change.

/datum/component/overmap_gunning/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	. = ..()
	autofire_target = over_object

/datum/component/overmap_gunning/proc/end_gunning()
	autofire_target = null
	var/obj/structure/overmap/OM = holder.loc.get_overmap()
	OM.gauss_gunners.Remove(holder)
	STOP_PROCESSING(SSfastprocess, src)
	var/obj/machinery/ship_weapon/gauss_gun/G = holder.loc
	if(istype(G))
		G.remove_gunner()
	RemoveComponent()
	return