
/datum/trait/nonviolent
	name = "Pacifist"
	desc = "The thought of violence makes you sick. So much so, in fact, that you can't hurt anyone."
	value = -2
	mob_trait = TRAIT_PACIFISM
	gain_text = "<span class='danger'>You feel repulsed by the thought of violence!</span>"
	lose_text = "<span class='notice'>You think you can defend yourself again.</span>"
	medical_record_text = "Patient is unusually pacifistic and cannot bring themselves to cause physical harm."

/datum/trait/nonviolent/on_process()
	if(isAntag(trait_holder))
		to_chat(trait_holder, "<span class='boldannounce'>Your antagonistic nature has caused you to renounce your pacifism.</span>")
		qdel(src)


/datum/trait/family_heirloom
	name = "Family Heirloom"
	desc = "You are the current owner of an heirloom. passed down for generations. You have to keep it safe!"
	value = -1
	//mood_trait = TRUE //Fethas:I know commented code but leave it here for when/if we add mood stuff
	var/obj/item/heirloom
	var/where_text

/datum/trait/family_heirloom/on_spawn()
	var/mob/living/carbon/human/H = trait_holder
	var/obj/item/heirloom_type
	var/list/heirlooms = subtypesof(/obj/item)
	for(var/V in heirlooms)
		var/obj/item/I = V
		if((!initial(I.icon_state)) || (!initial(I.item_state)) || (initial(I.flags) & ABSTRACT))
			heirlooms -= V
		heirloom_type = pick(heirlooms)
	heirloom = new heirloom_type(get_turf(trait_holder))
	var/list/slots = list(
		"in your backpack" = slot_in_backpack,
		"in your left pocket" = slot_l_store,
		"in your right pocket" = slot_r_store
	)
	var/where = H.equip_in_one_of_slots(heirloom, slots)
	if(!where)
		where = "at your feet"
	where_text = "<span class='boldnotice'>There is a precious family [heirloom.name] [where], passed down from generation to generation. Keep it safe!</span>"

/datum/trait/family_heirloom/post_add()
	to_chat(trait_holder, where_text)
	var/list/family_name = splittext(trait_holder.real_name, " ")
	heirloom.name = "\improper [family_name[family_name.len]] family [heirloom.name]"


/datum/trait/poor_aim
	name = "Poor Aim"
	desc = "You're terrible with guns and can't line up a straight shot to save your life. Dual-wielding is right out."
	value = -1
	mob_trait = TRAIT_POOR_AIM
	medical_record_text = "Patient possesses a strong tremor in both hands."



/datum/trait/prosopagnosia
	name = "Prosopagnosia"
	desc = "You have a mental disorder that prevents you from being able to recognize faces at all."
	value = -1
	mob_trait = TRAIT_PROSOPAGNOSIA
	medical_record_text = "Patient suffers from prosopagnosia and cannot recognize faces."
/datum/trait/insanity
	name = "Reality Dissociation Syndrome"
	desc = "You suffer from a severe disorder that causes very vivid hallucinations. Mindbreaker toxin can suppress its effects, and you are immune to mindbreaker's hallucinogenic properties. <b>This is not a license to grief.</b>"
	value = -2
	//no mob trait because it's handled uniquely
	gain_text = "<span class='userdanger'>...</span>"
	lose_text = "<span class='notice'>You feel in tune with the world again.</span>"
	medical_record_text = "Patient suffers from acute Reality Dissociation Syndrome and experiences vivid hallucinations."

/datum/trait/insanity/on_process()
	if(trait_holder.reagents.has_reagent("lsd"))
		trait_holder.hallucination = 0
		return
	if(prob(1)) //we'll all be mad soon enough
		madness()

/datum/trait/insanity/proc/madness(mad_fools)
	set waitfor = FALSE
	if(!mad_fools)
		mad_fools = prob(20)
	if(mad_fools)
		new /obj/effect/hallucination/rds (trait_holder)
	else
		trait_holder.hallucination += rand(10, 50)

/datum/trait/insanity/post_add() //I don't /think/ we'll need this but for newbies who think "roleplay as insane" = "license to kill" it's probably a good thing to have
	if(!trait_holder.mind || trait_holder.mind.special_role)
		return
	to_chat(trait_holder, "<span class='cultlarge'>Please note that your dissociation syndrome does NOT give you the right to attack people or otherwise cause any interference to \
	the round. You are not an antagonist, and the rules will treat you the same as other crewmembers.</span>")



datum/trait/social_anxiety
	name = "Social Anxiety"
	desc = "Talking to people is very difficult for you, and you often stutter or even lock up."
	value = -1
	gain_text = "<span class='danger'>You start worrying about what you're saying.</span>"
	lose_text = "<span class='notice'>You feel easier about talking again.</span>" //if only it were that easy!
	medical_record_text = "Patient is usually anxious in social encounters and prefers to avoid them."
	var/dumb_thing = TRUE

/datum/trait/social_anxiety/on_process()
	var/nearby_people = 0
	for(var/mob/living/carbon/human/H in view(5, trait_holder))
		if(H.client)
			nearby_people++
	var/mob/living/carbon/human/H = trait_holder
	if(prob(2 + nearby_people))
		H.stuttering = max(3, H.stuttering)
	else if(prob(min(3, nearby_people)) && !H.silent)
		to_chat(H, "<span class='danger'>You retreat into yourself. You <i>really</i> don't feel up to talking.</span>")
		H.silent = max(10, H.silent)
	else if(prob(0.5) && dumb_thing)
		to_chat(H, "<span class='userdanger'>You think of a dumb thing you said a long time ago and scream internally.</span>")
		dumb_thing = FALSE //only once per life