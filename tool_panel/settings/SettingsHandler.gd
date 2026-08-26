extends Node
tool

var config:Dictionary = {
	"driver_tag_discovery_preference":0,
	"use_specific_tags":PoolStringArray(),
	
}

var discovered_drivers:Array = [] setget setDisDrivers , getDisDrivers
var drivers_by_type:Dictionary = {} setget , getDT

var current_tooltips:Dictionary = {}

func setDisDrivers(how:Array):
	if how:
		drivers_by_type.clear()
		for driver in how:
			var file = driver.get_file()
			if not file in drivers_by_type:
				drivers_by_type[file] = []
			drivers_by_type[file].append(driver)
		discovered_drivers = how

func getDisDrivers():
	if not discovered_drivers:
		recheck_fs()
	return discovered_drivers

func getDT():
	if not drivers_by_type:
		setDisDrivers(self.discovered_drivers)
	return drivers_by_type

var file:File = File.new()
var directory:Directory = Directory.new()

var cache_directory:String = "user://cache/.DVTools_Cache/"
func init_settings():
	var cfg = ConfigFile.new()
	if not directory.dir_exists(cache_directory):
		directory.make_dir_recursive(cache_directory)
	if not file.file_exists(cache_directory + "settings.cfg"):
		saveConfig()
	cfg.load(cache_directory + "settings.cfg")
	for i in cfg.get_section_keys("settings"):
		config[i] = cfg.get_value("settings",i,config.get(i,null))
	recheck_fs()
	fetch_tooltips_file()

func get_value(setting:String):
	return config.get(setting,null)

func set_value(setting:String,value):
	config[setting] = value

func saveConfig():
	var cfg = ConfigFile.new()
	for i in config:
		cfg.set_value("settings",i,config[i])
	cfg.save(cache_directory + "settings.cfg")


var driver_directories = PoolStringArray([
	"HEVLIB_EQUIPMENT_DRIVER_TAGS",
	"HEVLIB_MENU",
	"HEVLIB_MINERAL_DRIVER_TAGS",
	"HEVLIB_DRIVERS",
])

func recheck_fs():
	var drivers = []
	var baseDir = __fetch_folder_files("res://")
	for first in baseDir:
		if first.ends_with("/"):
			var second = __fetch_folder_files(first)
			for i in second:
				if i.ends_with("/") and i.split("/",false)[2] in driver_directories:
					drivers.append_array(__fetch_folder_files(i,false))
	if drivers:
		discovered_drivers = drivers

func fetch_tooltips_file():
	file.open("res://addons/DVTools/resource_handling/TooltipDocumentation/tooltips.json",File.READ)
	var jout = JSON.parse(file.get_as_text(true))
	file.close()
	if jout.error == OK:
		current_tooltips = jout.result
	$TooltipsFetch.request("https://raw.githubusercontent.com/rwqfsfasxc100/DVTools/refs/heads/main/resource_handling/TooltipDocumentation/tooltips.json")


func __fetch_folder_files(folder: String, showFolders: bool = true, returnFullPath: bool = true) -> Array:
	var fileList : PoolStringArray = PoolStringArray()
	if not folder.ends_with("/"):
		folder += "/"
	if not directory.dir_exists(folder):
		return []
	directory.open(folder)
	directory.list_dir_begin(true)
	while true:
		var fileName : String = directory.get_next()
		var capture:bool = true
		if fileName.ends_with("/"):
			capture = false
		if fileName == "." or fileName == "..":
			capture = false
		if capture:
			if not fileName:
				break
			if directory.current_is_dir():
				if not showFolders:
					continue
				if not fileName.ends_with("/"):
					fileName = fileName + "/"
			if returnFullPath:
				fileName = folder + fileName
			fileList.append(fileName)
	return Array(fileList)

func _on_TooltipsFetch_request_completed(result, response_code, headers, body):
	if result == 200 and file.file_exists("user://cache/.DVTools_Cache/tooltips.json"):
		file.open("user://cache/.DVTools_Cache/tooltips.json",File.READ)
		var jout = JSON.parse(file.get_as_text(true))
		file.close()
		if jout.error == OK:
			current_tooltips = jout.result
			print(current_tooltips)
			return
	file.open("res://addons/DVTools/resource_handling/TooltipDocumentation/tooltips.json",File.READ)
	var jout = JSON.parse(file.get_as_text(true))
	file.close()
	if jout.error == OK:
		current_tooltips = jout.result
