/****************************************************
				BLOOD SYSTEM
****************************************************/
/mob/living/carbon/human/proc/suppress_bloodloss(amount)
	if(bleedsuppress)
		return
	else
		bleedsuppress = 1
		spawn(amount)
			bleedsuppress = 0
			if(stat != DEAD && bleed_rate)
				src << "<span class='warning'>The blood soaks through your bandage.</span>"


/mob/living/carbon/human/var/datum/reagents/vessel	//Container for blood and BLOOD ONLY. Do not transfer other chems here.

// Takes care blood loss and regeneration
/mob/living/carbon/human/proc/handle_blood()
	var/blood_volume
	if(species && species.flags & NO_BLOOD)
		bleed_rate = 0
		return

	if(stat != DEAD && bodytemperature >= 170)	//Dead or cryosleep people do not pump the blood.
		if(species.exotic_blood)
			var/blood_reagent = species.exotic_blood // This is a string of the name of the species' blood reagent
			blood_volume = round(vessel.get_reagent_amount(blood_reagent))
			if(blood_volume < max_blood && blood_volume)
				blood_volume += 0.1 // regenerate blood VERY slowly
				//if(reagents.has_reagent(blood_reagent))
				//	vessel.add_reagent(blood_reagent, 0.4)
		else
		/*
			blood_volume = round(vessel.get_reagent_amount("blood"))
			//Blood regeneration if there is some space
			if(blood_volume < max_blood && blood_volume)
				var/datum/reagent/blood/B = locate() in vessel.reagent_list //Grab some blood
				if(B) // Make sure there's some blood at all
					if(mind) //Handles vampires "eating" blood that isn't their own.
						if(mind in ticker.mode.vampires)
							for(var/datum/reagent/blood/BL in vessel.reagent_list)
								if(nutrition >= 450)
									break //We don't want blood tranfusions making vampires fat.
								if(BL.data["donor"] != src)
									nutrition += (15 * REAGENTS_METABOLISM)
									BL.volume -= REAGENTS_METABOLISM
									if(BL.volume <= 0)
										qdel(BL)
									break //Only process one blood per tick, to maintain the same metabolism as nutriment for non-vampires.

					if(B.data["donor"] != src) //If it's not theirs, then we look for theirs
						for(var/datum/reagent/blood/D in vessel.reagent_list)
							if(D.data["donor"] == src)
								B = D
								break
			*/
			blood_volume += 0.1 // regenerate blood VERY slowly


		//Effects of bloodloss
		var/oxy_immune = species.flags & NO_BREATHE //Some species have blood, but don't breathe; they should still suffer the effects of bloodloss.

		switch(blood_volume)
			if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
				if(prob(5))
					to_chat(src, "<span class='warning'>You feel [pick("dizzy","woozy","faint")].</span>")
				if(oxy_immune)
					adjustToxLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1))
				else
					adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.01, 1))
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
				if(oxy_immune)
					adjustToxLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))
				else
					adjustOxyLoss(round((BLOOD_VOLUME_NORMAL - blood_volume) * 0.02, 1))
				if(prob(5))
					eye_blurry = max(eye_blurry, 6)
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, "<span class='warning'>You feel very [word].</span>")
			if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
				if(oxy_immune)
					adjustToxLoss(5)
				else
					adjustOxyLoss(5)
				if(prob(15))
					Paralyse(rand(1,3))
					var/word = pick("dizzy","woozy","faint")
					to_chat(src, "<span class='warning'>You feel extremely [word].</span>")
			if(0 to BLOOD_VOLUME_SURVIVE)
				death()

		//Bleeding out
		var/blood_max = 0
		for(var/obj/item/organ/external/temp in organs)
			if(!(temp.status & ORGAN_BLEEDING) || temp.status & ORGAN_ROBOT)
				continue
			for(var/datum/wound/W in temp.wounds)
				if(W.bleeding())
					blood_max += W.damage / 4
			if(temp.open)
				blood_max += 2  //Yer stomach is cut open

		bleed_rate = max(bleed_rate - 0.5, blood_max)//if no wounds, other bleed effects (heparin) naturally decreases

		if(bleed_rate && !bleedsuppress)
			bleed(bleed_rate)

//Makes a blood drop, leaking amt units of blood from the mob
/mob/living/carbon/proc/bleed(amt)
	if(blood_volume)
		blood_volume = max(blood_volume - amt, 0)
		if(isturf(src.loc)) //Blood loss still happens in locker, floor stays clean
			if(amt >= 10)
				add_splatter_floor(src.loc)
			else
				add_splatter_floor(src.loc, 1)

/mob/living/carbon/human/bleed(amt)
	if(!(species && species.flags & NO_BLOOD))
		..()



/mob/living/proc/restore_blood()
	blood_volume = initial(blood_volume)

/mob/living/carbon/human/restore_blood()
	blood_volume = BLOOD_VOLUME_NORMAL
	bleed_rate = 0


/****************************************************
				BLOOD TRANSFERS
****************************************************/

//Gets blood from mob to a container or other mob, preserving all data in it.
/mob/living/proc/transfer_blood_to(atom/movable/AM, amount, forced)
	if(!blood_volume || !AM.reagents)
		return 0
	if(blood_volume < BLOOD_VOLUME_BAD && !forced)
		return 0

	if(blood_volume < amount)
		amount = blood_volume

	var/blood_id = get_blood_id()
	if(!blood_id)
		return 0

	blood_volume -= amount

	var/list/blood_data = get_blood_data(blood_id)

	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		if(blood_id == C.get_blood_id())//both mobs have the same blood substance
			if(blood_id == "blood") //normal blood
				if(blood_data["viruses"])
					for(var/datum/disease/D in blood_data["viruses"])
						if((D.spread_flags & SPECIAL) || (D.spread_flags & NON_CONTAGIOUS))
							continue
						C.ForceContractDisease(D)
				if(!(blood_data["blood_type"] in get_safe_blood(C.dna.blood_type)))//xif ot
					C.reagents.add_reagent("toxin", amount * 0.5)
					return 1

			C.blood_volume = min(C.blood_volume + round(amount, 0.1), BLOOD_VOLUME_MAXIMUM)
			return 1

	AM.reagents.add_reagent(blood_id, amount, blood_data, bodytemperature)
	return 1


/mob/living/proc/get_blood_data(blood_id)
	return

/mob/living/carbon/get_blood_data(blood_id)
	if(blood_id == "blood") //actual blood reagent
		var/blood_data = list()
		//set the blood data
		blood_data["donor"] = src
		blood_data["viruses"] = list()

		for(var/datum/disease/D in viruses)
			blood_data["viruses"] += D.Copy()

		blood_data["blood_DNA"] = copytext(dna.unique_enzymes,1,0)
		if(resistances && resistances.len)
			blood_data["resistances"] = resistances.Copy()
		var/list/temp_chem = list()
		for(var/datum/reagent/R in reagents.reagent_list)
			temp_chem[R.id] = R.volume
		blood_data["trace_chem"] = list2params(temp_chem)
		if(mind)
			blood_data["mind"] = mind
		if(ckey)
			blood_data["ckey"] = ckey
		if(!suiciding)
			blood_data["cloneable"] = 1
		blood_data["blood_type"] = copytext(dna.blood_type,1,0)//to dix
		blood_data["gender"] = gender
		blood_data["real_name"] = real_name
		blood_data["features"] = dna.features
		blood_data["factions"] = faction
		return blood_data

//get the id of the substance this mob use as blood.
/mob/proc/get_blood_id()
	return

/mob/living/simple_animal/get_blood_id()
	if(blood_volume)
		return "blood"

/mob/living/carbon/human/get_blood_id()
	if(dna.species.exotic_blood)//tofix
		return dna.species.exotic_blood
	else if((species && species.flags & NO_BLOOD) || (disabilities & NOCLONE))
		return
	return "blood"

// This is has more potential uses, and is probably faster than the old proc.
/proc/get_safe_blood(bloodtype)
	. = list()
	if(!bloodtype)
		return
	switch(bloodtype)
		if("A-")
			return list("A-", "O-")
		if("A+")
			return list("A-", "A+", "O-", "O+")
		if("B-")
			return list("B-", "O-")
		if("B+")
			return list("B-", "B+", "O-", "O+")
		if("AB-")
			return list("A-", "B-", "O-", "AB-")
		if("AB+")
			return list("A-", "A+", "B-", "B+", "O-", "O+", "AB-", "AB+")
		if("O-")
			return list("O-")
		if("O+")
			return list("O-", "O+")

//to add a splatter of blood or other mob liquid.
/mob/living/proc/add_splatter_floor(turf/T, small_drip)
	if(get_blood_id() != "blood")
		return
	if(!T)
		T = get_turf(src)

	var/list/temp_blood_DNA
	if(small_drip)
		// Only a certain number of drips (or one large splatter) can be on a given turf.
		var/obj/effect/decal/cleanable/blood/drip/drop = locate() in T
		if(drop)
			if(drop.drips < 3)
				drop.drips++
				drop.overlays |= pick(drop.random_icon_states)
				drop.transfer_mob_blood_dna(src)
				return
			else
				temp_blood_DNA = list()
				temp_blood_DNA |= drop.blood_DNA.Copy() //we transfer the dna from the drip to the splatter
				qdel(drop)//the drip is replaced by a bigger splatter
		else
			drop = new(T)
			drop.transfer_mob_blood_dna(src)
			return

	// Find a blood decal or create a new one.
	var/obj/effect/decal/cleanable/blood/B = locate() in T
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(T)
	B.transfer_mob_blood_dna(src) //give blood info to the blood decal.
	if(temp_blood_DNA)
		B.blood_DNA |= temp_blood_DNA

/mob/living/carbon/human/add_splatter_floor(turf/T, small_drip)
	if(!(species && species.flags & NO_BLOOD))
		..()

/mob/living/carbon/alien/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/xenoblood/B = locate() in T.contents
	if(!B)
		B = new(T)
	B.blood_DNA["UNKNOWN DNA"] = "X*"

/mob/living/silicon/robot/add_splatter_floor(turf/T, small_drip)
	if(!T)
		T = get_turf(src)
	var/obj/effect/decal/cleanable/oil/B = locate() in T.contents
	if(!B)//I DEFINED YOUR TYPE JACKASS
		B = new(T)
