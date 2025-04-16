//For base code look in code/modules/flufftext


/obj/item/projectile/hallucination/bullet/mac
	fake_icon = 'nsv13/icons/obj/projectiles_nsv.dmi'
	hal_icon_state = "railgun"
	movement_type = FLYING
	projectile_piercing = ALL

/obj/item/projectile/hallucination/bullet/mac/fire()
	..()
	fake_icon = image('nsv13/icons/obj/projectiles_nsv.dmi', src, hal_icon_state, ABOVE_MOB_LAYER) //We have to override this to get our NSV projectile
	if(hal_target.client)
		hal_target.client.images += fake_icon
*
