/obj/machinery/computer/atmos_alert
	name = "atmospheric alert console"
	desc = "Used to monitor the station's air alarms."
	circuit = /obj/item/circuitboard/computer/atmos_alert


	icon_screen = "alert:0"
	icon_keyboard = "atmos_key"
	var/list/priority_alarms = list()
	var/list/minor_alarms = list()
	var/receive_frequency = FREQ_ATMOS_ALARMS
	var/datum/radio_frequency/radio_connection

	light_color = LIGHT_COLOR_CYAN

/obj/machinery/computer/atmos_alert/Initialize(mapload)
	. = ..()
	set_frequency(receive_frequency)

/obj/machinery/computer/atmos_alert/Destroy()
	SSradio.remove_object(src, receive_frequency)
	return ..()


/obj/machinery/computer/atmos_alert/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/atmos_alert/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosAlertConsole")
		ui.open()

/obj/machinery/computer/atmos_alert/ui_data(mob/user)
	var/list/data = list()

	data["priority"] = list()
	for(var/zone in priority_alarms)
		data["priority"] += zone
	data["minor"] = list()
	for(var/zone in minor_alarms)
		data["minor"] += zone

	return data

/obj/machinery/computer/atmos_alert/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("clear")
			var/zone = params["zone"]
			if(zone in priority_alarms)
				to_chat(usr, "<span class='notice'>Priority alarm for [zone] cleared.</span>")
				priority_alarms -= zone
				. = TRUE
			if(zone in minor_alarms)
				to_chat(usr, "<span class='notice'>Minor alarm for [zone] cleared.</span>")
				minor_alarms -= zone
				. = TRUE
	if(.)
		update_icon()

/obj/machinery/computer/atmos_alert/proc/set_frequency(new_frequency)
	SSradio.remove_object(src, receive_frequency)
	receive_frequency = new_frequency
	radio_connection = SSradio.add_object(src, receive_frequency, RADIO_ATMOSIA)

/obj/machinery/computer/atmos_alert/receive_signal(datum/signal/signal)
	if(!signal)
		return

	var/zone = signal.data["zone"]
	var/severity = signal.data["alert"]

	if(!zone || !severity)
		return

	minor_alarms -= zone
	priority_alarms -= zone
	if(severity == ATMOS_ALARM_SEVERE)
		priority_alarms += zone
	else if (severity == ATMOS_ALARM_MINOR)
		minor_alarms += zone
	update_icon()
	ui_update()
	return

/obj/machinery/computer/atmos_alert/update_icon()
	..()
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(priority_alarms.len)
		add_overlay("alert:2")
	else if(minor_alarms.len)
		add_overlay("alert:1")
