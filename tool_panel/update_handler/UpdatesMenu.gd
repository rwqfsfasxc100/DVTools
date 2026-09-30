tool
extends AcceptDialog

export (NodePath) var settings_button_path = NodePath("../VBoxContainer/Menu/Updates")
onready var settings_button = get_node_or_null(settings_button_path)
export (NodePath) var tool_panel_path = NodePath("..")
onready var tool_panel = get_node_or_null(tool_panel_path)

onready var updates_list = get_node_or_null(NodePath("PanelContainer/VBoxContainer/Updates/ScrollContainer/VBoxContainer"))
onready var update_all = get_node_or_null(NodePath("PanelContainer/VBoxContainer/Updates/HBoxContainer/All"))
onready var update_refresh = get_node_or_null(NodePath("PanelContainer/VBoxContainer/Updates/HBoxContainer/Refresh"))

onready var download_list = get_node_or_null(NodePath("PanelContainer/VBoxContainer/DownloadNew/ScrollContainer/VBoxContainer"))
onready var download_all = get_node_or_null(NodePath("PanelContainer/VBoxContainer/DownloadNew/HBoxContainer/All"))
onready var download_refresh = get_node_or_null(NodePath("PanelContainer/VBoxContainer/DownloadNew/HBoxContainer/Refresh"))

onready var showUpdatesPopup = get_node_or_null(NodePath("UpdatesAvailable"))

onready var http:HTTPRequest = get_node_or_null("HTTPRequest")
onready var http2:HTTPRequest = get_node_or_null("HTTPRequest_DOWNLOADS")

var plugin_settings

var available_manifests = []

var file:File = File.new()
var dir:Directory = Directory.new()

func _ready():
	yield(get_tree(),"idle_frame")
	if tool_panel and settings_button:
		plugin_settings = tool_panel.plugin_settings
		http.connect("request_completed",self,"updatelist_return")
		http2.connect("request_completed",self,"downloadlist_return")
		file.open(update_store,File.WRITE)
		file.store_string("{}")
		file.close()
		file.open(github_store,File.WRITE)
		file.store_string("{}")
		file.close()
		
		recursive_delete(base_download_dir)
		dir.make_dir_recursive(base_download_dir)
		
		
		
		available_manifests = plugin_settings.get("discovered_manifests")
		
		fetch_manifests()
		
		showUpdatesPopup.connect("confirmed",self,"show")
		
		settings_button.connect("pressed",self,"show")
		update_refresh.connect("pressed",self,"fetch_manifests",[1])
		download_refresh.connect("pressed",self,"fetch_manifests",[3])
		update_all.connect("pressed",self,"update_all")
		download_all.connect("pressed",self,"download_all")

func show():
	update_updates_list()
	update_download_list()
	popup_centered()


const update_store:String = "user://cache/.DVTools_Cache/needs_updates.json"
const base_download_dir = "user://cache/.DVTools_Cache/zip_dir/"
const api_url:String = "https://publicactiontrigger.azurewebsites.net/api/dispatches/rwqfsfasxc100/dv_update_database"
const updateDB_url:String = "https://raw.githubusercontent.com/rwqfsfasxc100/dv_update_database/refs/heads/main/manifest_path_store.json"

const github_fetcher_url:String = "https://raw.githubusercontent.com/rwqfsfasxc100/dv_update_database/refs/heads/main/github_fetcher_store/compiled_topic_store.json"
const github_store:String = "user://cache/.DVTools_Cache/github_list.json"

var mod_box = load("res://addons/DVTools/tool_panel/update_handler/ModBox.tscn")
var github_box = load("res://addons/DVTools/tool_panel/update_handler/GithubBox.tscn")

func update_updates_list():
	for i in updates_list.get_children():
		updates_list.remove_child(i)
		i.queue_free()
	file.open(update_store,File.READ)
	var needs_updates:Dictionary = JSON.parse(file.get_as_text()).result
	file.close()
	for id in needs_updates:
		var data = needs_updates[id]
		var box = mod_box.instance()
		box.download_url = data.github
		box.file_to_store = data.file_name
		box.mod_display = data.display
		box.mod_id = id
		box.base_menu = self
		updates_list.add_child(box)

func update_all():
	if updates_list.get_child_count():
		updates_list.get_child(0).do_download(true)








func downloadlist_return(result, response_code,headers,body):
	if result == 0 and response_code == 200:
		var p:Dictionary = JSON.parse(body.get_string_from_utf8()).result
		var ids:Array = get_mod_ids().keys()
		var pKeys:Array = p.keys()
		for i in ids:
			if i in pKeys:
				p.erase(i)
		file.open(github_store,File.WRITE)
		file.store_string(JSON.print(p))
		file.close()
		

func update_download_list():
	for i in download_list.get_children():
		download_list.remove_child(i)
		i.queue_free()
	file.open(github_store,File.READ)
	var needs_updates:Dictionary = JSON.parse(file.get_as_text()).result
	file.close()
	for id in needs_updates:
		var data = needs_updates[id]
		var box = github_box.instance()
		var header = data.get("formatted",{}).get("header_data",{})
		box.download_url = data.zip_filename
		box.file_to_store = data.zip_filename.get_file()
		box.mod_display = "%s (%s)" % [header.get("MOD_NAME","MOD NAME MISSING"),header.get("MOD_ID","no ID D:")]
		box.mod_id = id
		box.base_menu = self
		download_list.add_child(box)
		
		
	
	

func download_all():
	if download_list.get_child_count():
		download_list.get_child(0).do_download(true)








func fetch_manifests(fetch_anew = 0):
	file.open(update_store,File.WRITE)
	file.store_string("{}")
	file.close()
	match fetch_anew:
		0,1,2:
			http.request(updateDB_url)
			yield(http,"request_completed")
	match fetch_anew:
		0,3,4:
			http2.request(github_fetcher_url)
			yield(http2,"request_completed")
	match fetch_anew:
		1:
			update_updates_list()
		2:
			update_updates_list()
			update_all()
		3:
			update_download_list()
		4:
			update_download_list()
			download_all()

var firstTime:bool = true

func updatelist_return(result, response_code,headers,body):
	if result == 0 and response_code == 200:
		var p:Dictionary = JSON.parse(body.get_string_from_utf8()).result
		var ids:Dictionary = get_mod_ids()
		var updates:Dictionary = {}
		for ID in p:
			if ID in ids:
				var fetchData:Dictionary=p[ID]
				var modData:Dictionary=get_mod_by_id(ID)
				var current_version:Dictionary=modData["version_data"]
				var doUpdate:bool=false
				var newVer:Array=[fetchData["major"],fetchData["minor"],fetchData["bugfix"]]
				var ctr:int = 0
				while(not doUpdate)and(ctr < 3):
					match ctr:
						0:
							if newVer[0] > current_version["version_major"]:doUpdate = true
							elif newVer[0] < current_version["version_major"]:ctr = 5
						1:
							if newVer[1] > current_version["version_minor"]:doUpdate = true
							elif newVer[1] < current_version["version_minor"]:ctr = 5
						2:
							if newVer[2] > current_version["version_bugfix"]:doUpdate = true
							elif newVer[2] < current_version["version_bugfix"]:ctr = 5
					ctr += 1
				if doUpdate:
					var file_name:String = fetchData.get("file_name","file.zip")
					updates[ID] = {"github":"https://github.com/rwqfsfasxc100/dv_update_database/raw/refs/heads/main/zip_store/%s/%d.%d.%d/%s" % [ID,newVer[0],newVer[1],newVer[2],file_name],"file_name":file_name,"display":modData.get("name","") + " (" + ID + ")","manifest_path":ids[ID]}
		file.open(update_store,File.WRITE)
		file.store_string(JSON.print(updates))
		file.close()
		if firstTime and updates:
			show_boot_updates()
			firstTime = false


func show_boot_updates():
	yield(get_tree().create_timer(1.5),"timeout")
	showUpdatesPopup.popup_centered()

var manifests:Dictionary = {}

func get_mod_ids():
	var mod_ids = {}
	for manifest in available_manifests:
		if file.file_exists(manifest):
			var cfg:ConfigFile = ConfigFile.new()
			cfg.load(manifest)
			var mod_id:String = cfg.get_value("mod_information","id","")
			if mod_id:
				mod_ids[mod_id] = manifest
				manifests[mod_id] = config_parse(manifest)
	return mod_ids

func get_mod_by_id(ID:String) -> Dictionary:
	return {"name":manifests[ID].get("mod_information",{}).get("name","MOD NAME MISSING!"),"version_data":manifests[ID].get("version",{"version_major":1,"version_minor":0,"version_bugfix":0})}

func config_parse(file_path:String):
	if not file.file_exists(file_path) and not ResourceLoader.exists(file_path):
		return {}
	var cfg:ConfigFile = ConfigFile.new()
	cfg.load(file_path)
	var cfg_sections : Array = cfg.get_sections()
	var cfg_dictionary : Dictionary = {}
	for section in cfg_sections:
		var data : Dictionary = {}
		var keys : Array = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data[key] = item
		cfg_dictionary[section] = data
	return cfg_dictionary

func fetch_folder_files(folder: String, showFolders: bool = false, returnFullPath: bool = true,globalizePath: bool = true) -> Array:
		var fileList : PoolStringArray = PoolStringArray()
		if not folder.ends_with("/"):
			folder += "/"
		var directory:Directory = Directory.new()
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
				if globalizePath:
					fileList.append(ProjectSettings.globalize_path(fileName))
				else:
					fileList.append(fileName)
		return Array(fileList)

func rescan_fs():
	if plugin_settings:
		plugin_settings.rescan_fs()

func recursive_delete(path: String, excluded_files:PoolStringArray = PoolStringArray()) -> bool:
		excluded_files.append_array(PoolStringArray([".git/",".github/",".gitignore",".gitattributes"]))
		var directory:Directory = Directory.new()
		if not directory.open(path) == OK:
			return false
		if not path.ends_with("/"):
			path = path + "/"
		var filesForDeletion : Array = []
		var foldersForDeletion : Array = []
		var pms : PoolStringArray = PoolStringArray(fetch_folder_files(path, true, true))
		for entry in pms:
			if entry.ends_with("/"):
				var fsplit:PoolStringArray = entry.split("/",false)
				if not fsplit[fsplit.size() - 1] + "/" in excluded_files:
					foldersForDeletion.append(entry)
			else:
				if not entry.get_file() in excluded_files:
					filesForDeletion.append(entry)
		for f in filesForDeletion:
			var fsplit:PoolStringArray = f.split("/")
			var splitFiles = fsplit[fsplit.size()-1]
			directory.open(path)
			directory.remove(splitFiles)
		for folder in foldersForDeletion:
			recursive_delete(folder,excluded_files)
		directory.open(path)
		directory.remove(path)
		return true


