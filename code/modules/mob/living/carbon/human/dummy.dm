/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH
	var/in_use = FALSE

INITIALIZE_IMMEDIATE(/mob/living/carbon/human/dummy)

/mob/living/carbon/human/dummy/Destroy()
	in_use = FALSE
	return ..()

/mob/living/carbon/human/dummy/Life()
	return

/mob/living/carbon/human/dummy/proc/wipe_state()
	for(var/slot in get_all_slots())
		qdel(slot)
	overlays.Cut()

//Inefficient pooling/caching way.
GLOBAL_LIST_EMPTY(human_dummy_list)

/proc/generate_or_wait_for_human_dummy(slotkey)
	if(!slotkey)
		return new /mob/living/carbon/human/dummy
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotkey]
	to_chat(world, "gowfhd - istype(D) ? [istype(D)]")
	if(istype(D))
		UNTIL(!D.in_use)
	to_chat(world, "gowfhd - while loop exited")
	if(QDELETED(D))
		D = new
		GLOB.human_dummy_list[slotkey] = D
	D.in_use = TRUE
	return D

/proc/unset_busy_human_dummy(slotnumber)
	if(!slotnumber)
		return
	var/mob/living/carbon/human/dummy/D = GLOB.human_dummy_list[slotnumber]
	if(istype(D))
		D.wipe_state()
		D.in_use = FALSE