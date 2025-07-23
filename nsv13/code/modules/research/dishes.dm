/obj/machinery/astrometrics_dish
	name = "\improper Astrometrics antenna array"
	desc = "A large antenna array used to collect general astrometrics data."
	circuit = /obj/item/circuitboard/machine/astrometrics_dish
	var/dish_type = DISH_TYPE_GENERIC //type of data it collects
	var/obj/structure/overmap/linked

/obj/machinery/astrometrics_dish/neutrino
	name = "\improper Astrometrics neutrino detection chamber"
	desc = "A compacted version of traditional neutrino detection using compressed snow. Provides astrometric data about nearby stellar objects."
	dish_type = DISH_TYPE_NEUTRINO

/obj/machinery/astrometrics_dish/gravitic
	name = "\improper Astrometrics gravitic interferometer"
	desc = "An incredibly precise measuring instrument used to detect gravity waves for astrometric purposes about massive objects."
	dish_type = DISH_TYPE_GRAVITY

/obj/machinery/astrometrics_dish/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/astrometrics_dish/LateInitialize()
	. = ..()
	has_overmap()
	if(linked)
		linked.scanners |= src

/obj/machinery/astrometrics_dish/proc/has_overmap()
	linked = get_overmap()
	return linked
