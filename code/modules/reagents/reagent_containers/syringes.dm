////////////////////////////////////////////////////////////////////////////////
/// Syringes.
////////////////////////////////////////////////////////////////////////////////
#define SYRINGE_DRAW 0
#define SYRINGE_INJECT 1
#define SYRINGE_BROKEN 2

/obj/item/weapon/reagent_containers/syringe
	name = "Syringe"
	desc = "A syringe."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = null //list(5,10,15)
	volume = 15
	w_class = 1
	sharp = 1
	var/mode = SYRINGE_DRAW
	var/projectile_type = /obj/item/projectile/bullet/dart/syringe

/obj/item/weapon/reagent_containers/syringe/New()
	..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/weapon/reagent_containers/syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_self(mob/user)
	switch(mode)
		if(SYRINGE_DRAW)
			mode = SYRINGE_INJECT
		if(SYRINGE_INJECT)
			mode = SYRINGE_DRAW
		if(SYRINGE_BROKEN)
			return
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/syringe/attack(mob/living/M, mob/living/user, def_zone)
	return

/obj/item/weapon/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	if(istype(I,/obj/item/weapon/storage/bag))
		..()
	return

/obj/item/weapon/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, 1))
			return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				user << "<span class='notice'>The syringe is full.</span>"
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message("<span class='danger'>[user] is trying to take a blood sample from [target]!</span>", \
									"<span class='userdanger'>[user] is trying to take a blood sample from [target]!</span>")
					if(!do_mob(user, target))
						return
					if(reagents.total_volume >= reagents.maximum_volume)
						return
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("[user] takes a blood sample from [L].")
				else
					user << "<span class='warning'>You are unable to draw any blood from [L]!</span>"

			else //if not mob
				if(!target.reagents.total_volume)
					user << "<span class='warning'>[target] is empty!</span>"
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers) && !istype(target,/obj/item/slime_extract))
					user << "<span class='warning'>You cannot directly remove reagents from [target]!</span>"
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				user << "<span class='notice'>You fill [src] with [trans] units of the solution.</span>"
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				user << "<span class='notice'>[src] is empty.</span>"
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/slime_extract) && !istype(target, /obj/item/clothing/mask/cigarette) && !istype(target, /obj/item/weapon/storage/fancy/cigarettes))
				user << "<span class='warning'>You cannot directly fill [target]!</span>"
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "<span class='notice'>[target] is full.</span>"
				return

			if(L) //living mob
				if(L != user)
					L.visible_message("<span class='danger'>[user] is trying to inject [L]!</span>", \
											"<span class='userdanger'>[user] is trying to inject [L]!</span>")
					if(!do_mob(user, L))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return

					L.visible_message("<span class='danger'>[user] injects [L] with the syringe!", \
									"<span class='userdanger'>[user] injects [L] with the syringe!")

				var/list/rinject = list()
				for(var/datum/reagent/R in reagents.reagent_list)
					rinject += R.name
				var/contained = english_list(rinject)

				if(L != user)
					add_logs(user, L, "injected", src, addition="which had [contained]")
				else
					log_attack("<font color='red'>[user.name] ([user.ckey]) injected [L.name] ([L.ckey]) with [src.name], which had [contained] (INTENT: [uppertext(user.a_intent)])</font>")
					L.attack_log += "\[[time_stamp()]\] <font color='orange'>Injected themselves ([contained]) with [src.name].</font>"

			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
			reagents.reaction(L, INGEST, fraction)//to fix
			reagents.trans_to(target, amount_per_transfer_from_this)
			user << "<span class='notice'>You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units.</span>"
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/weapon/reagent_containers/syringe/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.Cut()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if(SYRINGE_DRAW)
				injoverlay = "draw"
			if(SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

/obj/item/weapon/reagent_containers/ld50_syringe
	name = "Lethal Injection Syringe"
	desc = "A syringe used for lethal injections."
	icon = 'icons/goonstation/objects/syringe.dmi'
	item_state = "syringe_0"
	icon_state = "0"
	amount_per_transfer_from_this = 50
	possible_transfer_amounts = null //list(5,10,15)
	volume = 50
	var/mode = SYRINGE_DRAW

/obj/item/weapon/reagent_containers/ld50_syringe/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/attackby(obj/item/I, mob/user)
	return

/obj/item/weapon/reagent_containers/ld50_syringe/afterattack(obj/target, mob/user , flag)
	if(!target.reagents)
		return

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, "\red The syringe is full.")
				return

			if(ismob(target))
				if(istype(target, /mob/living/carbon))//I Do not want it to suck 50 units out of people
					to_chat(usr, "This needle isn't designed for drawing blood.")
					return
			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, "\red [target] is empty.")
					return

				if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
					to_chat(user, "\red You cannot directly remove reagents from this object.")
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				to_chat(user, "\blue You fill the syringe with [trans] units of the solution.")
			if(reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, "\red The Syringe is empty.")
				return
			if(istype(target, /obj/item/weapon/implantcase/chem))
				return
			if(!target.is_open_container() && !ismob(target) && !istype(target, /obj/item/weapon/reagent_containers/food))
				to_chat(user, "\red You cannot directly fill this object.")
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, "\red [target] is full.")
				return

			if(ismob(target) && target != user)
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red <B>[] is trying to inject [] with a giant syringe!</B>", user, target), 1)
				if(!do_mob(user, target, 300)) return
				for(var/mob/O in viewers(world.view, user))
					O.show_message(text("\red [] injects [] with a giant syringe!", user, target), 1)
				reagents.reaction(target, INGEST)
			if(ismob(target) && target == user)
				reagents.reaction(target, INGEST)
			spawn(5)
				var/trans = reagents.trans_to(target, amount_per_transfer_from_this)
				to_chat(user, "\blue You inject [trans] units of the solution. The syringe now contains [reagents.total_volume] units.")
				if(reagents.total_volume >= reagents.maximum_volume && mode==SYRINGE_INJECT)
					mode = SYRINGE_DRAW
					update_icon()

/obj/item/weapon/reagent_containers/ld50_syringe/update_icon()
	var/rounded_vol = round(reagents.total_volume,50)
	if(ismob(loc))
		var/mode_t
		switch(mode)
			if(SYRINGE_DRAW)
				mode_t = "d"
			if(SYRINGE_INJECT)
				mode_t = "i"
		icon_state = "[mode_t][rounded_vol]"
	else
		icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"


////////////////////////////////////////////////////////////////////////////////
/// Syringes. END
////////////////////////////////////////////////////////////////////////////////


/obj/item/weapon/reagent_containers/syringe/antiviral
	name = "Syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list("spaceacillin" = 15)

/obj/item/weapon/reagent_containers/ld50_syringe/lethal
	list_reagents = list("cyanide" = 10, "neurotoxin2" = 40)

/obj/item/weapon/reagent_containers/syringe/charcoal
	name = "Syringe (charcoal)"
	desc = "Contains charcoal - used to treat toxins and damage from toxins."
	list_reagents = list("charcoal" = 15)

/obj/item/weapon/reagent_containers/syringe/epinephrine
	name = "Syringe (Epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list("epinephrine" = 15)

/obj/item/weapon/reagent_containers/syringe/insulin
	name = "Syringe (insulin)"
	desc = "Contains insulin - used to treat diabetes."
	list_reagents = list("insulin" = 15)

/obj/item/weapon/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list("neurotoxin" = 5, "capulettium_plus" = 5, "sodium_thiopental" = 5)