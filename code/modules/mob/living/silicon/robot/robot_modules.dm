/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_module"
	w_class = 100
	item_state = "electronic"
	flags = CONDUCT

	var/module_type = "NoMod" // For icon usage

	var/sprite_override = FALSE
	var/list/sprites = list()
	var/custom_icon = null

	var/list/modules = list()
	var/list/module_actions = list()
	var/list/channels = list()
	var/list/subsystems = list()
	var/list/stacktypes = list()

	var/obj/item/emag = null

	var/can_be_pushed = TRUE
	var/clean_on_walk = FALSE


/obj/item/weapon/robot_module/emp_act(severity)
	if(modules)
		for(var/obj/O in modules)
			O.emp_act(severity)
	if(emag)
		emag.emp_act(severity)
	..()


/obj/item/weapon/robot_module/New()
	modules += new /obj/item/device/flash/cyborg(src)
	emag = new /obj/item/toy/sword(src)
	emag.name = "Placeholder Emag Item"

/obj/item/weapon/robot_module/proc/init(mob/living/silicon/robot/R)
	if(!can_be_pushed)
		R.status_flags &= ~CANPUSH

	//languages
	add_languages(R)
	//subsystems
	add_subsystems_and_actions(R)

/obj/item/weapon/robot_module/proc/override_sprite(mob/living/silicon/robot/R)
	return

/obj/item/weapon/robot_module/Destroy()
	QDEL_LIST(modules)
	QDEL_NULL(emag)
	return ..()

/obj/item/weapon/robot_module/proc/fix_modules()
	for(var/obj/item/I in modules)
		I.flags |= NODROP
		I.mouse_opacity = 2
	if(emag)
		emag.flags |= NODROP
		emag.mouse_opacity = 2

/obj/item/weapon/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R)
	if(!stacktypes || !stacktypes.len)
		return

	var/stack_respawned = 0
	for(var/T in stacktypes)
		var/O = locate(T) in modules
		var/obj/item/stack/S = O

		if(!S)
			modules -= null
			S = new T(src)
			modules += S
			S.amount = 1
			stack_respawned = 1

		if(S && S.amount < stacktypes[T])
			S.amount++
	if(stack_respawned && istype(R) && R.hud_used)
		R.hud_used.update_robot_modules_display()

/obj/item/weapon/robot_module/proc/rebuild()//Rebuilds the list so it's possible to add/remove items from the module
	var/list/temp_list = modules
	modules = list()
	for(var/obj/O in temp_list)
		if(O)
			modules += O

/obj/item/weapon/robot_module/proc/add_languages(mob/living/silicon/robot/R)
	//full set of languages
	R.add_language("Galactic Common", 1)
	R.add_language("Sol Common", 1)
	R.add_language("Tradeband", 1)
	R.add_language("Gutter", 0)
	R.add_language("Sinta'unathi", 0)
	R.add_language("Siik'tajr", 0)
	R.add_language("Canilunzt", 0)
	R.add_language("Skrellian", 0)
	R.add_language("Vox-pidgin", 0)
	R.add_language("Rootspeak", 0)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 0)
	R.add_language("Bubblish", 0)
	R.add_language("Orluum", 0)
	R.add_language("Clownish",0)

/obj/item/weapon/robot_module/proc/add_subsystems_and_actions(mob/living/silicon/robot/R)
	R.verbs |= subsystems
	for(var/A in module_actions)
		var/datum/action/act = new A()
		act.Grant(R)
		R.module_actions += act

/obj/item/weapon/robot_module/proc/remove_subsystems_and_actions(mob/living/silicon/robot/R)
	R.verbs -= subsystems
	for(var/datum/action/A in R.module_actions)
		A.Remove(R)
		qdel(A)
	R.module_actions.Cut()

/obj/item/weapon/robot_module/proc/get_standard_pixel_x_offset(mob/living/silicon/robot/R)
	return 0
/obj/item/weapon/robot_module/proc/get_standard_pixel_y_offset(mob/living/silicon/robot/R)
	return 0

/obj/item/weapon/robot_module/standard
	name = "standard robot module"
	module_type = "Standard"
	channels = list("Service" = 1)
	sprites = list(
		"Basic" = "robot_old",
		"Android" = "droid",
		"Default" = "robot",
		"Noble-STD" = "Noble-STD"
	)

/obj/item/weapon/robot_module/standard/New()
	..()
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/device/healthanalyzer(src)
	emag = new /obj/item/weapon/melee/energy/sword/cyborg(src)

	fix_modules()

/obj/item/weapon/robot_module/medical
	name = "medical robot module"
	module_type = "Medical"
	channels = list("Medical" = 1)
	sprites = list(
		"Basic" = "Medbot",
		"Surgeon" = "surgeon",
		"Advanced Droid" = "droid-medical",
		"Needles" = "medicalrobot",
		"Standard" = "robotMedi",
		"Noble-MED" = "Noble-MED"
	)
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	stacktypes = list(
		/obj/item/stack/medical/bruise_pack/advanced = 5,
		/obj/item/stack/medical/ointment/advanced = 5,
		/obj/item/stack/medical/splint = 5,
		/obj/item/stack/nanopaste = 5
		)
	can_be_pushed = FALSE

/obj/item/weapon/robot_module/medical/New()
	..()
	modules += new /obj/item/device/healthanalyzer/advanced(src)
	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/weapon/borg_defib(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo(src)
	modules += new /obj/item/weapon/reagent_containers/glass/beaker/large(src)
	modules += new /obj/item/weapon/reagent_containers/dropper(src)
	modules += new /obj/item/weapon/reagent_containers/syringe(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced(src)
	modules += new /obj/item/stack/medical/ointment/advanced(src)
	modules += new /obj/item/stack/medical/splint(src)
	modules += new /obj/item/stack/nanopaste(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/bonegel(src)
	modules += new /obj/item/weapon/FixOVein(src)
	modules += new /obj/item/weapon/bonesetter(src)
	modules += new /obj/item/weapon/circular_saw(src)
	modules += new /obj/item/weapon/surgicaldrill(src)

	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("facid", 250)
	emag.name = "Polyacid spray"

	fix_modules()

/obj/item/weapon/robot_module/medical/init(mob/living/silicon/robot/R)
	. = ..()
	if(R.camera && "Robots" in R.camera.network)
		R.camera.network.Add("Medical")

/obj/item/weapon/robot_module/medical/respawn_consumable(mob/living/silicon/robot/R)
	if(emag)
		var/obj/item/weapon/reagent_containers/spray/PS = emag
		PS.reagents.add_reagent("facid", 2)
	..()

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"
	module_type = "Engineer"
	channels = list("Engineering" = 1)
	sprites = list(
		"Basic" = "Engineering",
		"Antique" = "engineerrobot",
		"Landmate" = "landmate",
		"Standard" = "robotEngi",
		"Noble-ENG" = "Noble-ENG"
	)
	subsystems = list(/mob/living/silicon/proc/subsystem_power_monitor)
	module_actions = list(
		/datum/action/innate/robot_sight/meson,
	)

	stacktypes = list(
		/obj/item/stack/sheet/metal/cyborg = 50,
		/obj/item/stack/sheet/glass/cyborg = 50,
		/obj/item/stack/sheet/rglass/cyborg = 50,
		/obj/item/stack/cable_coil/cyborg = 50,
		/obj/item/stack/rods/cyborg = 60,
		/obj/item/stack/tile/plasteel = 20
		)

/obj/item/weapon/robot_module/engineering/New()
	..()
	modules += new /obj/item/weapon/rcd/borg(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/weapon/screwdriver/cyborg(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/wirecutters/cyborg(src)
	modules += new /obj/item/device/multitool/cyborg(src)
	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/taperoll/engineering(src)
	modules += new /obj/item/weapon/gripper(src)
	modules += new /obj/item/weapon/matter_decompiler(src)
	modules += new /obj/item/device/floor_painter(src)
	modules += new /obj/item/areaeditor/blueprints/cyborg(src)
	emag = new /obj/item/borg/stun(src)

	for(var/G in stacktypes) //Attempt to unify Engi-Borg material stacks into fewer lines. See Line 492 for example. Variables changed out of paranoia.
		var/obj/item/stack/sheet/M = new G(src)
		M.amount = stacktypes[G]
		modules += M

	fix_modules()

/obj/item/weapon/robot_module/engineering/init(mob/living/silicon/robot/R)
	. = ..()
	if(R.camera && "Robots" in R.camera.network)
		R.camera.network.Add("Engineering")
	R.magpulse = 1

/obj/item/weapon/robot_module/security
	name = "security robot module"
	module_type = "Security"
	channels = list("Security" = 1)
	sprites = list(
		"Basic" = "secborg",
		"Red Knight" = "Security",
		"Black Knight" = "securityrobot",
		"Bloodhound" = "bloodhound",
		"Standard" = "robotSecy",
		"Noble-SEC" = "Noble-SEC"
	)
	subsystems = list(/mob/living/silicon/proc/subsystem_crew_monitor)
	can_be_pushed = FALSE

/obj/item/weapon/robot_module/security/New()
	..()
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)
	modules += new /obj/item/weapon/melee/baton/loaded(src)
	modules += new /obj/item/weapon/gun/energy/disabler/cyborg(src)
	modules += new /obj/item/taperoll/police(src)
	modules += new /obj/item/clothing/mask/gas/sechailer/cyborg(src)
	emag = new /obj/item/weapon/gun/energy/laser/cyborg(src)

	fix_modules()

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"
	module_type = "Janitor"
	channels = list("Service" = 1)
	sprites = list(
		"Basic" = "JanBot2",
		"Mopbot"  = "janitorrobot",
		"Mop Gear Rex" = "mopgearrex",
		"Standard" = "robotJani",
		"Noble-CLN" = "Noble-CLN"
	)
	clean_on_walk = TRUE

/obj/item/weapon/robot_module/janitor/New()
	..()
	modules += new /obj/item/weapon/soap/nanotrasen(src)
	modules += new /obj/item/weapon/storage/bag/trash/cyborg(src)
	modules += new /obj/item/weapon/mop/advanced/cyborg(src)
	modules += new /obj/item/device/lightreplacer(src)
	modules += new /obj/item/weapon/holosign_creator(src)
	emag = new /obj/item/weapon/reagent_containers/spray(src)

	emag.reagents.add_reagent("lube", 250)
	emag.name = "Lube spray"

	fix_modules()

/obj/item/weapon/robot_module/butler
	name = "service robot module"
	module_type = "Service"
	channels = list("Service" = 1)
	sprites = list(
		"Waitress" = "Service",
		"Kent" = "toiletbot",
		"Bro" = "Brobot",
		"Rich" = "maximillion",
		"Default" = "Service2",
		"Standard" = "robotServ",
		"Noble-SRV" = "Noble-SRV"
	)

/obj/item/weapon/robot_module/butler/New()
	..()
	modules += new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/condiment/enzyme(src)
	modules += new /obj/item/weapon/pen(src)
	modules += new /obj/item/weapon/razor(src)
	modules += new /obj/item/device/violin(src)
	modules += new /obj/item/device/guitar(src)

	var/obj/item/weapon/rsf/M = new /obj/item/weapon/rsf(src)
	M.matter = 30
	modules += M

	modules += new /obj/item/weapon/reagent_containers/dropper/cyborg(src)
	modules += new /obj/item/weapon/lighter/zippo(src)
	modules += new /obj/item/weapon/storage/bag/tray/cyborg(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/shaker(src)
	emag = new /obj/item/weapon/reagent_containers/food/drinks/cans/beer(src)

	var/datum/reagents/R = new/datum/reagents(50)
	emag.reagents = R
	R.my_atom = emag
	R.add_reagent("beer2", 50)
	emag.name = "Mickey Finn's Special Brew"

	fix_modules()

/obj/item/weapon/robot_module/butler/respawn_consumable(var/mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/food/condiment/enzyme/E = locate() in modules
	E.reagents.add_reagent("enzyme", 2)
	if(emag)
		var/obj/item/weapon/reagent_containers/food/drinks/cans/beer/B = emag
		B.reagents.add_reagent("beer2", 2)
	..()

/obj/item/weapon/robot_module/butler/add_languages(var/mob/living/silicon/robot/R)
	//full set of languages
	R.add_language("Galactic Common", 1)
	R.add_language("Sol Common", 1)
	R.add_language("Tradeband", 1)
	R.add_language("Gutter", 1)
	R.add_language("Sinta'unathi", 1)
	R.add_language("Siik'tajr", 1)
	R.add_language("Canilunzt", 1)
	R.add_language("Skrellian", 1)
	R.add_language("Vox-pidgin", 1)
	R.add_language("Rootspeak", 1)
	R.add_language("Trinary", 1)
	R.add_language("Chittin", 1)
	R.add_language("Bubblish", 1)
	R.add_language("Clownish",1)


/obj/item/weapon/robot_module/miner
	name = "miner robot module"
	module_type = "Miner"
	channels = list("Supply" = 1)
	sprites = list(
		"Basic" = "Miner_old",
		"Advanced Droid" = "droid-miner",
		"Treadhead" = "Miner",
		"Standard" = "robotMine",
		"Noble-DIG" = "Noble-DIG"
	)
	module_actions = list(
		/datum/action/innate/robot_sight/meson,
	)

/obj/item/weapon/robot_module/miner/New()
	..()
	modules += new /obj/item/weapon/storage/bag/ore/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/drill/cyborg(src)
	modules += new /obj/item/weapon/shovel(src)
	modules += new /obj/item/weapon/weldingtool/mini(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/weapon/storage/bag/sheetsnatcher/borg(src)
	modules += new /obj/item/device/t_scanner/adv_mining_scanner/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/kinetic_accelerator/cyborg(src)
	modules += new /obj/item/device/gps/cyborg(src)
	emag = new /obj/item/borg/stun(src)

	fix_modules()

/obj/item/weapon/robot_module/miner/init(mob/living/silicon/robot/R)
	. = ..()
	if(R.camera && "Robots" in R.camera.network)
		R.camera.network.Add("Mining Outpost")

/obj/item/weapon/robot_module/deathsquad
	name = "NT advanced combat module"
	module_type = "Malf"
	module_actions = list(
		/datum/action/innate/robot_sight/thermal,
	)

/obj/item/weapon/robot_module/deathsquad/New()
	..()
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/pulse/cyborg(src)
	modules += new /obj/item/weapon/crowbar(src)
	emag = null

	fix_modules()

/obj/item/weapon/robot_module/syndicate
	name = "syndicate assault robot module"
	module_type = "Malf" // cuz it looks cool

/obj/item/weapon/robot_module/syndicate/New()
	..()
	modules += new /obj/item/weapon/melee/energy/sword/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/printer(src)
	modules += new /obj/item/weapon/gun/projectile/revolver/grenadelauncher/multi/cyborg(src)
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/pinpointer/operative(src)
	emag = null

	fix_modules()

/obj/item/weapon/robot_module/syndicate_medical
	name = "syndicate medical robot module"
	module_type = "Malf"
	stacktypes = list(
		/obj/item/stack/medical/bruise_pack/advanced = 25,
		/obj/item/stack/medical/ointment/advanced = 25,
		/obj/item/stack/medical/splint = 25,
		/obj/item/stack/nanopaste = 25
	)

/obj/item/weapon/robot_module/syndicate_medical/New()
	..()
	modules += new /obj/item/device/healthanalyzer/advanced(src)
	modules += new /obj/item/device/reagent_scanner/adv(src)
	modules += new /obj/item/weapon/borg_defib(src)
	modules += new /obj/item/roller_holder(src)
	modules += new /obj/item/weapon/reagent_containers/borghypo/syndicate(src)
	modules += new /obj/item/weapon/extinguisher/mini(src)
	modules += new /obj/item/stack/medical/bruise_pack/advanced(src)
	modules += new /obj/item/stack/medical/ointment/advanced(src)
	modules += new /obj/item/stack/medical/splint(src)
	modules += new /obj/item/stack/nanopaste(src)
	modules += new /obj/item/weapon/scalpel(src)
	modules += new /obj/item/weapon/hemostat(src)
	modules += new /obj/item/weapon/retractor(src)
	modules += new /obj/item/weapon/cautery(src)
	modules += new /obj/item/weapon/bonegel(src)
	modules += new /obj/item/weapon/FixOVein(src)
	modules += new /obj/item/weapon/bonesetter(src)
	modules += new /obj/item/weapon/surgicaldrill(src)
	modules += new /obj/item/weapon/melee/energy/sword/cyborg/saw(src) //Energy saw -- primary weapon
	modules += new /obj/item/weapon/card/emag(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/pinpointer/operative(src)
	emag = null

	fix_modules()

/obj/item/weapon/robot_module/combat
	name = "combat robot module"
	module_type = "Malf"
	channels = list("Security" = 1)
	sprite_override = TRUE
	module_actions = list(
		/datum/action/innate/robot_sight/thermal,
	)
	can_be_pushed = FALSE

/obj/item/weapon/robot_module/combat/New()
	..()
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/gun/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/drill/jackhammer(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)

	fix_modules()

/obj/item/weapon/robot_module/combat/override_sprite(mob/living/silicon/robot/R)
	R.icon_state = "droidcombat"

/obj/item/weapon/robot_module/peacekeeper
	name = "peacekeeper robot module"
	module_type = "Malf"
	sprite_override = TRUE
	can_be_pushed = FALSE

/obj/item/weapon/robot_module/peacekeeper/New()
	..()
	modules += new /obj/item/weapon/restraints/handcuffs/cable/zipties/cyborg(src)
	modules += new /obj/item/weapon/gun/energy/gun/cyborg(src)
	modules += new /obj/item/weapon/pickaxe/drill/jackhammer(src)
	modules += new /obj/item/borg/combat/shield(src)
	modules += new /obj/item/borg/combat/mobility(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	emag = new /obj/item/weapon/gun/energy/lasercannon/cyborg(src)

	fix_modules()

/obj/item/weapon/robot_module/peacekeeper/override_sprite(mob/living/silicon/robot/R)
	R.icon_state = "droidpeace"

/obj/item/weapon/robot_module/alien/hunter
	name = "alien hunter module"
	module_type = "Standard"
	sprite_override = TRUE
	module_actions = list(
		/datum/action/innate/robot_sight/thermal/alien,
	)


/obj/item/weapon/robot_module/alien/hunter/New()
	modules += new /obj/item/weapon/melee/energy/alien/claws(src)
	modules += new /obj/item/device/flash/cyborg/alien(src)
	var/obj/item/weapon/reagent_containers/spray/alien/stun/S = new /obj/item/weapon/reagent_containers/spray/alien/stun(src)
	S.reagents.add_reagent("ether",250) //nerfed to sleeptoxin to make it less instant drop.
	modules += S
	var/obj/item/weapon/reagent_containers/spray/alien/smoke/A = new /obj/item/weapon/reagent_containers/spray/alien/smoke(src)
	S.reagents.add_reagent("water",50) //Water is used as a dummy reagent for the smoke bombs. More of an ammo counter.
	modules += A
	emag = new /obj/item/weapon/reagent_containers/spray/alien/acid(src)
	emag.reagents.add_reagent("facid", 125)
	emag.reagents.add_reagent("sacid", 125)

	fix_modules()

/obj/item/weapon/robot_module/alien/hunter/add_languages(var/mob/living/silicon/robot/R)
	..()
	R.add_language("xenocommon", 1)

/obj/item/weapon/robot_module/alien/hunter/override_sprite(mob/living/silicon/robot/R)
	R.icon = 'icons/mob/alien.dmi'
	R.icon_state = "xenoborg-state-a"
	R.modtype = "Xeno-Hu"
	feedback_inc("xeborg_hunter",1)

/obj/item/weapon/robot_module/drone
	name = "drone module"
	module_type = "Engineer"
	stacktypes = list(
		/obj/item/stack/sheet/wood = 10,
		/obj/item/stack/sheet/rglass/cyborg = 50,
		/obj/item/stack/tile/wood = 20,
		/obj/item/stack/rods/cyborg = 60,
		/obj/item/stack/tile/plasteel = 20,
		/obj/item/stack/sheet/metal/cyborg = 50,
		/obj/item/stack/sheet/glass/cyborg = 50,
		/obj/item/stack/cable_coil/cyborg = 30
		)

/obj/item/weapon/robot_module/drone/New()
	modules += new /obj/item/weapon/weldingtool/largetank/cyborg(src)
	modules += new /obj/item/weapon/screwdriver/cyborg(src)
	modules += new /obj/item/weapon/wrench/cyborg(src)
	modules += new /obj/item/weapon/crowbar/cyborg(src)
	modules += new /obj/item/weapon/wirecutters/cyborg(src)
	modules += new /obj/item/device/multitool/cyborg(src)
	modules += new /obj/item/device/lightreplacer(src)
	modules += new /obj/item/weapon/gripper(src)
	modules += new /obj/item/weapon/matter_decompiler(src)
	modules += new /obj/item/weapon/reagent_containers/spray/cleaner/drone(src)
	modules += new /obj/item/weapon/soap(src)
	modules += new /obj/item/device/t_scanner(src)

	emag = new /obj/item/weapon/pickaxe/drill/cyborg/diamond(src)

	for(var/T in stacktypes)
		var/obj/item/stack/sheet/W = new T(src)
		W.amount = stacktypes[T]
		modules += W

	fix_modules()

/obj/item/weapon/robot_module/drone/respawn_consumable(mob/living/silicon/robot/R)
	var/obj/item/weapon/reagent_containers/spray/cleaner/C = locate() in modules
	C.reagents.add_reagent("cleaner", 3)

	var/obj/item/device/lightreplacer/LR = locate() in modules
	LR.Charge(R)

	..()

//checks whether this item is a module of the robot it is located in.
/obj/item/proc/is_robot_module()
	if(!istype(loc, /mob/living/silicon/robot))
		return 0

	var/mob/living/silicon/robot/R = loc

	return (src in R.module.modules)
