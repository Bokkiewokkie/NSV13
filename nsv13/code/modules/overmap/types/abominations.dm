/obj/structure/overmap/abomination
    name = "unidentified ship"
    desc = "What happened to it?"
    icon = 'nsv13/icons/overmap/default.dmi'
    faction = "abomination"

/obj/structure/overmap/abomination/cultist
    name = "strange ship"
    desc = "This ship appears to be covered in runes and a strange metal... it's probably not a good idea to approach it."
    icon = 'nsv13/icons/overmap/abominations/cultist_small.dmi'

/obj/structure/overmap/abomination/cultist/initialize()
	. = ..()
	name = "[name] ([rand(0,999)])"

/obj/structure/overmap/abomination/cultist/ai
    icon_state = "cultist_small"
    mass = MASS_SMALL
	integrity_failure = 400
	armor = list("overmap_light" = 30, "overmap_heavy" = 10)
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
    ai_trait = 
    combat_dice_type = /datum/combat_dice/frigate

/obj/structure/overmap/abomination/cultist/pc 
    icon = 'nsv13/icons/overmap/abominations/cultist_medium.dmi'
    icon_state = "cultist_medium"
    mass = MASS_MEDIUM
    
