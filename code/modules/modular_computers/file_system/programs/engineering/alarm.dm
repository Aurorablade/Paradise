/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm Monitoring"
	ui_header = "alarm_green.gif"
	program_icon_state = "alert-green"
	extended_desc = "This program provides visual interface for station's alarm system."
	requires_ntnet = 1
	network_destination = "alarm monitoring network"
	size = 5
	var/tgui_id = "NtosStationAlertConsole"
	var/ui_x = 315
	var/ui_y = 500

	var/has_alert = 0
	var/alarms = list("Fire" = list(), "Atmosphere" = list(), "Power" = list())

/datum/computer_file/program/alarm_monitor/process_tick()
	..()

	if(has_alert)
		program_icon_state = "alert-red"
		ui_header = "alarm_red.gif"
		update_computer_icon()
	else
		if(!has_alert)
			program_icon_state = "alert-green"
			ui_header = "alarm_green.gif"
			update_computer_icon()
	return 1

/datum/computer_file/program/alarm_monitor/tgui_data(mob/user)
	var/list/data = get_header_data()

	data["alarms"] = list()
	for(var/class in alarms)
		data["alarms"][class] = list()
		for(var/area in alarms[class])
			data["alarms"][class] += area

	return data

/datum/computer_file/program/alarm_monitor/proc/triggerAlarm(class, area/A, list/O, obj/alarmsource)
	if(is_station_level(source.z))
		if(!(A.type in GLOB.the_station_areas))
			return
	else if(!is_mining_level(source.z) || istype(A, /area/ruin))
		return

	var/list/L = alarms[class]
	for(var/I in L)
		if(I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if(!(alarmsource.UID() in sources))
				sources += alarmsource.UID()
			return TRUE
	L[A.name] = list(get_area_name(A, TRUE), O, list(alarmsource.UID()))
	update_alarm_display()
	return TRUE


/datum/computer_file/program/alarm_monitor/proc/cancelAlarm(class, area/A, obj/origin)
	var/list/L = alarms[class]
	var/cleared = 0
	var/arealevelalarm = FALSE // set to TRUE for alarms that set/clear whole areas
	if(class == "Fire")
		arealevelalarm = TRUE
	for(var/I in L)
		if(I == A.name)
			if(!arealevelalarm) // the traditional behaviour
				var/list/alarm = L[I]
				var/list/srcs  = alarm[3]
				if(origin.UID() in srcs)
					srcs -= origin.UID()
				if(srcs.len == 0)
					cleared = 1
					L -= I
			else
				L -= I // wipe the instances entirely
				cleared = 1


	update_alarm_display()
	return !cleared

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	has_alert = FALSE
	for(var/cat in alarms)
		var/list/L = alarms[cat]
		if(L.len)
			has_alert = TRUE

/datum/computer_file/program/alarm_monitor/run_program(mob/user)
	. = ..(user)
	GLOB.alarmdisplay += src

/datum/computer_file/program/alarm_monitor/kill_program(forced = FALSE)
	GLOB.alarmdisplay -= src
	..()
