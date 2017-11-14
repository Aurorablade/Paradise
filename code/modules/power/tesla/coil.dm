/obj/machinery/power/tesla_coil
	name = "tesla coil"
	desc = "For the union!"
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "coil0"
	anchored = 0
	density = 1

	var/power_loss = 2
	var/input_power_multiplier = 1
	var/zap_cooldown = 100
	var/last_zap = 0
	var/datum/wires/tesla_coil/wires = null

	// Executing a traitor caught releasing tesla was never this fun!
	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

/obj/machinery/power/tesla_coil/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/tesla_coil(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	wires = new(src)
	RefreshParts()

/obj/machinery/power/tesla_coil/Destroy()
	QDEL_NULL(wires)
	return ..()

/obj/machinery/power/tesla_coil/RefreshParts()
	var/power_multiplier = 0
	zap_cooldown = 100
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		power_multiplier += C.rating
		zap_cooldown -= (C.rating * 20)
	input_power_multiplier = power_multiplier

/obj/machinery/power/tesla_coil/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "coil_open[anchored]", "coil[anchored]", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_unfasten_wrench(user, W))
		if(!anchored)
			disconnect_from_network()
		else
			connect_to_network()
		return

	if(default_deconstruction_crowbar(W))
		return

	else if(iswirecutter(W) || ismultitool(W) || istype(W, /obj/item/device/assembly/signaler))
		if(panel_open)
			wires.Interact(user)
	else if(user.a_intent == INTENT_GRAB)
		if(istype(W, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = W
			if(isliving(G.affecting))
				if(do_mob(user, src, 120))
					var/mob/living/H = G.affecting
					H.forceMove(loc)
					buckle_mob(H)
					qdel(G)

	else
		..()


/obj/machinery/power/tesla_coil/tesla_act(var/power)
	if(anchored && !panel_open)
		being_shocked = 1
		//don't lose arc power when it's not connected to anything
		//please place tesla coils all around the station to maximize effectiveness
		var/power_produced = powernet ? power / power_loss : power
		add_avail(power_produced*input_power_multiplier)
		flick("coilhit", src)
		playsound(src.loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
		tesla_zap(src, 5, power_produced)
		addtimer(src, "reset_shocked", 10)
	else
		..()

/obj/machinery/power/tesla_coil/proc/zap()
	if((last_zap + zap_cooldown) > world.time || !powernet)
		return FALSE
	last_zap = world.time
	var/coeff = (20 - ((input_power_multiplier - 1) * 3))
	coeff = max(coeff, 10)
	var/power = (powernet.avail/2)
	draw_power(power)
	playsound(src.loc, 'sound/magic/LightningShock.ogg', 100, 1, extrarange = 5)
	tesla_zap(src, 10, power/(coeff/2))

/obj/machinery/power/grounding_rod
	name = "grounding rod"
	desc = "Keep an area from being fried from Edison's Bane."
	icon = 'icons/obj/tesla_engine/tesla_coil.dmi'
	icon_state = "grounding_rod0"
	anchored = 0
	density = 1

	can_buckle = TRUE
	buckle_lying = FALSE
	buckle_requires_restraints = TRUE

/obj/machinery/power/grounding_rod/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/grounding_rod(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	RefreshParts()

/obj/machinery/power/grounding_rod/attackby(obj/item/W, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grounding_rod_open[anchored]", "grounding_rod[anchored]", W))
		return

	if(exchange_parts(user, W))
		return

	if(default_unfasten_wrench(user, W))
		return

	if(default_deconstruction_crowbar(W))
		return

	if(user.a_intent == INTENT_GRAB)
		if(istype(W, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = W
			if(isliving(G.affecting))
				if(do_mob(user, src, 120))
					var/mob/living/H = G.affecting
					H.forceMove(loc)
					buckle_mob(H)
					qdel(G)

	return ..()

/obj/machinery/power/grounding_rod/tesla_act(var/power)
	if(anchored && !panel_open)
		flick("grounding_rodhit", src)
	else
		..()