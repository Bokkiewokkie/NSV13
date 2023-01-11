/client/var/last_ambience = null

/area
	ambient_buzz = 'nsv13/sound/ambience/shipambience.ogg' //If you want an ambient sound to play on loop while theyre in a specific area, set this. Defaults to the classic "engine rumble"

/area/space
	ambient_buzz = null

/area/space/instanced
	area_flags = HIDDEN_AREA

/area/maintenance
	ambient_buzz = 'nsv13/sound/ambience/maintenance.ogg'
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')

/area/medical
	ambient_buzz = 'nsv13/sound/ambience/medbay.ogg'
	ambientsounds = list()

/area/ai_monitored
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/bridge
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'
	ambientsounds = list()

/area/science
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'
	ambientsounds = list()

/area/crew_quarters/dorms/nsv/dorms_1
	name = "Deck 2 Fore Quarters"
	icon_state = "Sleep"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED

/area/crew_quarters/dorms/nsv/dorms_2
	name = "Deck 2 Aft Quarters"
	icon_state = "Sleep"
	area_flags = VALID_TERRITORY | BLOBS_ALLOWED

/area/crew_quarters/dorms/nsv/state_room
	name = "Corporate Stateroom"
	icon_state = "Sleep"

/area/medical/nsv/clinic
	name = "Deck 2 Medical Clinic"
	icon_state = "medbay"

/area/medical/nsv/psychology
	name = "Psychology Office"
	icon_state = "medbay"

/area/medical/nsv/plumbing
	name = "Chemical Manufacturing"
	icon_state = "chem"

/area/science/nsv/astronomy
	name = "Astrometrics Lab"
	icon = 'nsv13/icons/turf/custom_areas.dmi'
	icon_state = "astrometrics"

/area/maintenance/nsv/turbolift/abandonedshaft
	name = "Abandoned Elevator Shaft"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/port
	name = "Deck 1 Port Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/forward/starboard
	name = "Deck 1 Starboard Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/port
	name = "Deck 1 Port Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/airlock/aft/starboard
	name = "Deck 1 Starboard Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck1/port
	name = "Deck 1 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck1/central
	name = "Deck 1 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck1/starboard
	name = "Deck 1 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/starboard/aft
	name = "Deck 1 Starboard Aft Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck1/starboard/fore
	name = "Deck 1 Starboard Fore Maintenance"

/area/maintenance/nsv/deck1/aft
	name = "Deck 1 Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/deck1/port/aft
	name = "Deck 1 Port Aft Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck1/port/fore
	name = "Deck 1 Port Fore Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/port
	name = "Deck 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/starboard
	name = "Deck 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/airlock/forward/port
	name = "Deck 2 Port Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/forward/starboard
	name = "Deck 2 Starboard Forward Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/port
	name = "Deck 2 Port Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/airlock/aft/starboard
	name = "Deck 2 Starboard Aft Airlock"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/frame1/port
	name = "Deck 2 Frame 1 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame1/starboard
	name = "Deck 2 Frame 1 Starboard Maintenence"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame1/central
	name = "Deck 2 Frame 1 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame2/port
	name = "Deck 2 Frame 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame2/central
	name = "Deck 2 Frame 2 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame3/starboard
	name = "Deck 2 Frame 3 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame3/central
	name = "Deck 2 Frame 3 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame4/port
	name = "Deck 2 Frame 4 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame4/starboard
	name = "Deck 2 Frame 4 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame4/central
	name = "Deck 2 Frame 4 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck2/frame5/port
	name = "Deck 2 Frame 5 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/frame5/starboard
	name = "Deck 2 Frame 5 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/frame5/central
	name = "Deck 2 Frame 5 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck3/frame1/port
	name = "Deck 3 Frame 1 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame1/starboard
	name = "Deck 3 Frame 1 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame2/port
	name = "Deck 3 Frame 2 Port Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame2/starboard
	name = "Deck 3 Frame 2 Starboard Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/port
	name = "Deck 3 Frame 3 Port Maintenence"
	icon_state = "pmaint"

/area/maintenance/nsv/deck3/frame3/starboard
	name = "Deck 3 Frame 3 Starboard Maintenence"
	icon_state = "smaint"

/area/maintenance/nsv/deck3/frame3/central
	name = "Deck 3 Frame 3 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/deck3/frame4/central
	name = "Deck 3 Frame 4 Central Maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/bridge
	name = "Fore Bridge Maintenance"
	icon_state = "maint_bridge"

/area/maintenance/nsv/deck2/starboard/fore
	name = "Deck 2 Starboard Fore Maintenance"
	icon_state = "smaint"

/area/maintenance/nsv/deck2/starboard/aft
	name = "Deck 2 Starboard Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/deck2/port/fore
	name = "Deck 2 Port Fore Maintenance"
	icon_state = "pmaint"

/area/maintenance/nsv/deck2/port/aft
	name = "Deck 2 Port Aft Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/weapons
	name = "Weapons Bay Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/hangar
	name = "Hangar Bay Maintenance"
	icon_state = "amaint"

/area/maintenance/nsv/port_substation
	name = "Port Substation"
	icon_state = "amaint"

/area/maintenance/nsv/central_substation
	name = "Central Substation"
	icon_state = "amaint"

/area/maintenance/nsv/starboard_substation
	name = "Starboard Substation"
	icon_state = "amaint"

/area/hallway/nsv/deck2/forward
	name = "Deck 2 Forward Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/primary
	name = "Deck 2 Primary Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck1/aft
	name = "Deck 1 Aft Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/aft
	name = "Deck 2 Aft Hallway"
	icon_state = "hallP"

/area/maintenance/nsv/mining_ship
	has_gravity = TRUE
	ambient_buzz = 'nsv13/sound/ambience/maintenance.ogg'

/area/maintenance/nsv/mining_ship/central
	name = "Rocinante maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/forward
	name = "Rocinante forward maintenance"
	icon_state = "maintcentral"

/area/maintenance/nsv/mining_ship/aft
	name = "Rocinante aft maintenance"
	icon_state = "maintcentral"

/area/hallway/nsv/deck2/frame1/port
	name = "Deck 2 Frame 1 Port Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame1/central
	name = "Deck 2 Frame 1 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame1/starboard
	name = "Deck 2 Frame 1 Starboard Hallway"
	icon_state = "hallF"

/area/hallway/nsv/deck2/frame2/port
	name = "Deck 2 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame2/central
	name = "Deck 2 Frame 2 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame3/port
	name = "Deck 2 Frame 3 Port Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/central
	name = "Deck 2 Frame 3 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame3/starboard
	name = "Deck 2 Frame 3 Starboard Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame4/port
	name = "Deck 2 Frame 4 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame4/starboard
	name = "Deck 2 Frame 4 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame4/central
	name = "Deck 2 Frame 4 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck2/frame5/port
	name = "Deck 2 Frame 5 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck2/frame5/starboard
	name = "Deck 2 Frame 5 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck2/frame5/central
	name = "Deck 2 Frame 5 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame1/port
	name = "Deck 3 Frame 1 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame1/starboard
	name = "Deck 3 Frame 1 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame1/central
	name = "Deck 3 Frame 1 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame2/central
	name = "Deck 2 Frame 2 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame2/port
	name = "Deck 2 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame2/starboard
	name = "Deck 2 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/port
	name = "Deck 3 Frame 3 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame3/starboard
	name = "Deck 3 Frame 3 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck3/frame3/central
	name = "Deck 3 Frame 3 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame4/central
	name = "Deck 3 Frame 4 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck3/frame4/port
	name = "Deck 3 Frame 4 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck3/frame4/starboard
	name = "Deck 3 Frame 4 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/stairwell/lower
	name = "Lower Stairwell"
	icon_state = "hallS"

/area/hallway/nsv/stairwell/upper
	name = "Upper Stairwell"
	icon_state = "hallS"

/area/hallway/nsv/deck1/hallway
	name = "Deck 1 Primary Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/central
	name = "Deck 1 Frame 1 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame1/starboard
	name = "Deck 1 Frame 1 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame2/port
	name = "Deck 1 Frame 2 Port Hallway"
	icon_state = "hallP"

/area/hallway/nsv/deck1/frame2/central
	name = "Deck 1 Frame 2 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame2/starboard
	name = "Deck 1 Frame 2 Starboard Hallway"
	icon_state = "hallS"

/area/hallway/nsv/deck1/frame3/central
	name = "Deck 1 Frame 3 Central Hallway"
	icon_state = "hallC"

/area/hallway/nsv/deck1/frame4/central
	name = "Deck 1 Frame 4 Central Hallway"
	icon_state = "hallC"

/area/crew_quarters/nsv/observation
	name = "Observation Lounge"
	icon_state = "Sleep"

/area/nsv/squad
	name = "Squad Equipment Room"
	icon_state = "shuttlegrn"

/area/ai_monitored/records
	name = "Records Room"
	icon_state = "nuke_storage"

/area/security/locker_room
	name = "Security Locker Room"
	icon_state = "checkpoint1"

/area/nsv/shuttle

/area/nsv/shuttle/bridge
	name = "Mining Shuttle Bridge"
	icon_state = "bridge"

/area/nsv/shuttle/central
	name = "Mining Shuttle"
	icon_state = "hallC"

/area/nsv/shuttle/storage
	name = "Mining Shuttle Equipment Storage"
	icon_state = "storage"

/area/nsv/shuttle/atmospherics
	name = "Mining Shuttle Maintenance"
	icon_state = "atmos"

/area/nsv/shuttle/airlock/aft
	name = "Mining Shuttle Aft Airlock"
	icon_state = "hallA"

/area/nsv/shuttle/airlock/port
	name = "Mining Shuttle Port Airlock"
	icon_state = "hallP"

/area/nsv/shuttle/airlock/starboard
	name = "Mining Shuttle Starboard Airlock"
	icon_state = "hallS"

//FOB
/area/nsv/shuttle/fob
	has_gravity = STANDARD_GRAVITY //good luck trying to fit a gen here.
	icon = 'nsv13/icons/turf/custom_areas.dmi'
	icon_state = "fobshuttle"

/area/nsv/shuttle/fob/bridge
	name = "Mining Shuttle Bridge"
	icon_state = "fobshuttlebridge"

/area/nsv/shuttle/fob/central
	name = "Mining Shuttle"

/area/nsv/shuttle/fob/storage
	name = "Mining Shuttle Equipment Storage"

/area/nsv/shuttle/fob/atmospherics
	name = "Mining Shuttle Maintenance"

/area/nsv/shuttle/fob/airlock/aft
	name = "Mining Shuttle Aft Airlock"

/area/nsv/shuttle/fob/airlock/port
	name = "Mining Shuttle Port Airlock"

/area/nsv/shuttle/fob/airlock/starboard
	name = "Mining Shuttle Starboard Airlock"

/area/nsv/shuttle/fob/quarters
	name = "Mining Shuttle Crew Quarters"

/area/nsv/shuttle/fob/lounge
	name = "Mining Shuttle Lounge"

//Nostromo (main mining ship)
/area/nostromo
	name = "DMC Rocinante"
	ambientsounds = list('nsv13/sound/ambience/leit_motif.ogg','nsv13/sound/ambience/wind.ogg','nsv13/sound/ambience/wind2.ogg','nsv13/sound/ambience/wind3.ogg','nsv13/sound/ambience/wind4.ogg','nsv13/sound/ambience/wind5.ogg','nsv13/sound/ambience/wind6.ogg')
	icon = 'nsv13/icons/turf/custom_areas.dmi'
	icon_state = "miningship"
	has_gravity = TRUE

/area/nostromo/maintenance/exterior
	name = "Rocinante exterior"
	icon = 'icons/turf/areas.dmi'
	icon_state = "space_near"

/area/nostromo/maintenance/hangar
	name = "Rocinante hangar bay"
	icon_state = "hallS"

/area/nostromo/medbay
	name = "Rocinante sickbay"
	ambient_buzz = 'nsv13/sound/ambience/medbay.ogg'

/area/nostromo/science
	name = "Rocinante science"
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'

/area/nostromo/tcomms
	name = "Rocinante TE/LE/COMM core"
	ambient_buzz = 'nsv13/sound/ambience/computer_core.ogg'

/area/nostromo/bridge
	name = "Rocinante flight deck"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/hangar/port
	name = "Rocinante port hangar deck"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/hangar/starboard
	name = "Rocinante starboard hangar deck"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/engineering
	name = "Rocinante engineering"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/engineering/atmospherics
	name = "Rocinante engineering"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/galley
	name = "Rocinante galley"
	ambient_buzz = 'nsv13/sound/ambience/bridge.ogg'

/area/nostromo/galley/coldroom
	name = "Rocinante cold room"

/area/nostromo/crew_quarters
	name = "Rocinante quarters"
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>There's no place like the dorms!\n</span>"

/area/nostromo/mining
	name = "Rocinante mining dock"

/area/nostromo/security
	name = "Rocinante security"
	ambience_index = AMBIENCE_DANGER
