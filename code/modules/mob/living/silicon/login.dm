/mob/living/silicon/Login()
	SetSleeping(0)
	if(mind && ticker && ticker.mode)
		ticker.mode.remove_revolutionary(mind, 1)
		ticker.mode.remove_cultist(mind, 1)
		ticker.mode.remove_wizard(mind)
		ticker.mode.remove_changeling(mind)
		remove_vampire(mind)
		ticker.mode.remove_thrall(mind, 0)
		ticker.mode.remove_shadowling(mind)
		ticker.mode.remove_abductor(mind)
	..()
