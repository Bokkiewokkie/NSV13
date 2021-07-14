/obj/structure/overmap/abomination
    name = "unidentified ship"
    desc = "What happened to it?"
    icon = 'nsv13/icons/overmap/default.dmi'
    faction = "abomination"

/obj/structure/overmap/abomination/ai
    . = ..()
    name = "[name] ([rand(0,999)])"

/obj/structure/overmap/abomination/ai/blob
