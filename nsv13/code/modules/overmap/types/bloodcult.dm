
/* Cult ships still WIP
/obj/structure/overmap/cultist
    name = "strange ship"
    desc = "This ship appears to be covered in runes and a strange metal... it's probably not a good idea to approach it."
    icon = 'nsv13/icons/overmap/cult/cultist_small.dmi'

/obj/structure/overmap/cultist/initialize()
	. = ..()
	name = "[name] ([rand(0,999)])"

/obj/structure/overmap/cultist/ai
    icon_state = "cultist_small"
    mass = MASS_SMALL
	integrity_failure = 400
	armor = list("overmap_light" = 80, "overmap_heavy" = 10)
	ai_controlled = TRUE
	ai_behaviour = AI_AGGRESSIVE
    ai_trait = 
    combat_dice_type = /datum/combat_dice/frigate

/obj/structure/overmap/cultist/pc 
    icon = 'nsv13/icons/overmap/cult/cultist_medium.dmi'
    icon_state = "cultist_medium"
    mass = MASS_MEDIUM
*/ 