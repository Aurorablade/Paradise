/datum/preferences
	//The mob should have a gender you want before running this proc. Will run fine without H
/datum/preferences/proc/random_character(gender_override)
	var/datum/robolimb/robohead
	if(species == "Machine")
		var/head_model = "[!rlimb_data["head"] ? "Morpheus Cyberkinetics" : rlimb_data["head"]]"
		robohead = all_robolimbs[head_model]
	if(gender_override)
		gender = gender_override
	else
		gender = pick(MALE, FEMALE)
	underwear = random_underwear(gender, species)
	undershirt = random_undershirt(gender, species)
	socks = random_socks(gender, species)
	if(species == "Vulpkanin")
		body_accessory = random_body_accessory(species)
		if(body_accessory == "None") //Required to prevent a bug where the information/icons in the character preferences screen wouldn't update despite the data being changed.
			body_accessory = null
	if(species in list("Human", "Drask", "Vox"))
		s_tone = random_skin_tone(species)
	h_style = random_hair_style(gender, species, robohead)
	f_style = random_facial_hair_style(gender, species, robohead)
	if(species in list("Human", "Unathi", "Tajaran", "Skrell", "Machine", "Vulpkanin", "Vox"))
		randomize_hair_color("hair")
		randomize_hair_color("facial")
	if(species in list("Unathi", "Vulpkanin", "Tajaran", "Machine"))
		ha_style = random_head_accessory(species)
		var/list/colours = randomize_skin_color(1)
		r_headacc = colours["red"]
		g_headacc = colours["green"]
		b_headacc = colours["blue"]
	if(species in list("Machine", "Tajaran", "Unathi", "Vulpkanin"))
		m_styles["head"] = random_marking_style("head", species, robohead, null, alt_head)
		var/list/colours = randomize_skin_color(1)
		m_colours["head"] = rgb(colours["red"], colours["green"], colours["blue"])
	if(species in list("Human", "Unathi", "Grey", "Vulpkanin", "Tajaran", "Skrell", "Vox", "Drask"))
		m_styles["body"] = random_marking_style("body", species)
		var/list/colours = randomize_skin_color(1)
		m_colours["body"] = rgb(colours["red"], colours["green"], colours["blue"])
	if(species in list("Vox", "Vulpkanin")) //Species with tail markings.
		m_styles["tail"] = random_marking_style("tail", species, null, body_accessory)
		var/list/colours = randomize_skin_color(1)
		m_colours["tail"] = rgb(colours["red"], colours["green"], colours["blue"])
	if(species != "Machine")
		randomize_eyes_color()
	if(species in list("Unathi", "Tajaran", "Skrell", "Vulpkanin"))
		randomize_skin_color()
	backbag = 2
	age = rand(AGE_MIN, AGE_MAX)


/datum/preferences/proc/randomize_hair_color(var/target = "hair")
	if(prob (75) && target == "facial") // Chance to inherit hair color
		r_facial = r_hair
		g_facial = g_hair
		b_facial = b_hair
		return

	var/red
	var/green
	var/blue

	var/col = pick ("blonde", "black", "chestnut", "copper", "brown", "wheat", "old", "punk")
	switch(col)
		if("blonde")
			red = 255
			green = 255
			blue = 0
		if("black")
			red = 0
			green = 0
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 51
		if("copper")
			red = 255
			green = 153
			blue = 0
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("wheat")
			red = 255
			green = 255
			blue = 153
		if("old")
			red = rand (100, 255)
			green = red
			blue = red
		if("punk")
			red = rand (0, 255)
			green = rand (0, 255)
			blue = rand (0, 255)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	switch(target)
		if("hair")
			r_hair = red
			g_hair = green
			b_hair = blue
		if("facial")
			r_facial = red
			g_facial = green
			b_facial = blue

/datum/preferences/proc/randomize_eyes_color()
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	r_eyes = red
	g_eyes = green
	b_eyes = blue

/datum/preferences/proc/randomize_skin_color(var/pass_to_list)
	var/red
	var/green
	var/blue

	var/col = pick ("black", "grey", "brown", "chestnut", "blue", "lightblue", "green", "albino")
	switch(col)
		if("black")
			red = 0
			green = 0
			blue = 0
		if("grey")
			red = rand (100, 200)
			green = red
			blue = red
		if("brown")
			red = 102
			green = 51
			blue = 0
		if("chestnut")
			red = 153
			green = 102
			blue = 0
		if("blue")
			red = 51
			green = 102
			blue = 204
		if("lightblue")
			red = 102
			green = 204
			blue = 255
		if("green")
			red = 0
			green = 102
			blue = 0
		if("albino")
			red = rand (200, 255)
			green = rand (0, 150)
			blue = rand (0, 150)

	red = max(min(red + rand (-25, 25), 255), 0)
	green = max(min(green + rand (-25, 25), 255), 0)
	blue = max(min(blue + rand (-25, 25), 255), 0)

	if(pass_to_list)
		var/list/colours = list(
			"red" = red,
			"blue" = blue,
			"green" = green
			)
		return colours
	else
		r_skin = red
		g_skin = green
		b_skin = blue

/datum/preferences/proc/blend_backpack(var/icon/clothes_s,var/backbag,var/satchel,var/backpack="backpack")
	switch(backbag)
		if(2)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', backpack), ICON_OVERLAY)
		if(3)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', satchel), ICON_OVERLAY)
		if(4)
			clothes_s.Blend(new /icon('icons/mob/back.dmi', "satchel"), ICON_OVERLAY)
	return clothes_s

/datum/preferences/proc/update_preview_icon()
	// Silicons only need a very basic preview since there is no customization for them.
	if(job_engsec_high)
		switch(job_engsec_high)
			if(AI)
				preview_icon = icon('icons/mob/AI.dmi', "AI", SOUTH)
				preview_icon.Scale(64, 64)
				return
			if(CYBORG)
				preview_icon = icon('icons/mob/robots.dmi', "robot", SOUTH)
				preview_icon.Scale(64, 64)
				return

	// Set up the dummy for its photoshoot
	var/mob/living/carbon/human/dummy/mannequin = new()
	mannequin.status_flags |= GODMODE // Why not?
	copy_to(mannequin)

	// Determine what job is marked as 'High' priority, and dress them up as such.
	var/datum/job/previewJob
	var/highRankFlag = job_support_high | job_medsci_high | job_engsec_high

	if(job_support_low & SUPPORT)
		previewJob = job_master.GetJob("Civilian")
	else if(highRankFlag)
		var/highDeptFlag
		if(job_support_high)
			highDeptFlag = SUPPORT
		else if(job_medsci_high)
			highDeptFlag = MEDSCI
		else if(job_engsec_high)
			highDeptFlag = ENGSEC
		else if(job_karma_high)
			highDeptFlag = KARMA

		for(var/datum/job/job in job_master.occupations)
			if(job.flag == highRankFlag && job.department_flag == highDeptFlag)
				previewJob = job
				break

	if(previewJob)
		mannequin.job = previewJob.title
		previewJob.equip(mannequin)

	preview_icon = icon('icons/effects/effects.dmi', "nothing")
	preview_icon.Scale(48+32, 16+32)

	mannequin.dir = NORTH
	var/icon/stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 25, 17)

	mannequin.dir = WEST
	stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 1, 9)

	mannequin.dir = SOUTH
	stamp = getFlatIcon(mannequin)
	preview_icon.Blend(stamp, ICON_OVERLAY, 49, 1)

	preview_icon.Scale(preview_icon.Width() * 2, preview_icon.Height() * 2) // Scaling here to prevent blurring in the browser.
	qdel(mannequin)
