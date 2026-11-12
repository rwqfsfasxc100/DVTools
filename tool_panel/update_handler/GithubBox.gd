tool
extends HBoxContainer

var download_url = ""
var file_to_store = ""
onready var download = $Button
onready var label = $Label
onready var http = $HTTPRequest

var mod_display = "MOD NAME MISSING (no ID D:)"

var manifest_path = ""
var mod_id = ""

var base_menu

const base_download_dir = "user://cache/.DVTools_Cache/zip_dir/"
const update_store:String = "user://cache/.DVTools_Cache/github_list.json"

var file:File = File.new()
var dir:Directory = Directory.new()

func _ready():
	download.connect("pressed",self,"do_download")
	http.download_file = base_download_dir + file_to_store
	http.connect("request_completed",self,"download_finished")
	label.text = mod_display
	set_process(false)
	set_physics_process(false)

var requeue = false
var downloading = false

func do_download(queue_next = false):
	requeue = queue_next
	download.disabled = true
	download.text = "Downloading..."
	http.request(download_url)
	set_process(true)
	set_physics_process(true)
	downloading = true

func download_finished(result, response_code,headers,body):
	downloading = false
	set_process(false)
	set_physics_process(false)
	if result == 0 and response_code == 200:
		file.open(update_store,File.READ)
		var current_downloads:Dictionary = JSON.parse(file.get_as_text()).result
		file.close()
		current_downloads.erase(mod_id)
		file.open(update_store,File.WRITE)
		file.store_string(JSON.print(current_downloads))
		file.close()
		extract_zip_to_dir()
		base_menu.rescan_fs()
	if requeue:
		yield(get_tree().create_timer(0.25),"timeout")
		base_menu.fetch_manifests(4)

func extract_zip_to_dir():
	download.text = "Unzipping"
	var unzip_store:String = base_download_dir + file_to_store.get_basename() + "/"
	dir.make_dir(unzip_store)
	var gdunzip = load("res://addons/DVTools/miniz/miniz.gdns").new()
	
	gdunzip.open_read(http.download_file)
	gdunzip.extract_all(unzip_store)
	gdunzip.close()
	
	download.text = "Copying"
	copy_contents_from(unzip_store)
	base_menu.recursive_delete(unzip_store)
	dir.remove(http.download_file)

const destination = "res://"
func copy_contents_from(folder:String):
	var content = base_menu.fetch_folder_files(folder,true,false,false)

	for i in content:
		base_menu.recursive_delete(destination + i.split("/")[0])
	for i in content:
		var from = folder + i
		copy_recurse(from,destination)

	download.text = "DONE!"
	get_parent().remove_child(self)
	queue_free()

func copy_recurse(from:String,to:String):
	if from.ends_with("/"):
		var baseName = from.trim_prefix(from.get_base_dir().get_base_dir() + "/")
		dir.make_dir_recursive(to + baseName)
		for i in base_menu.fetch_folder_files(from,true,false,false):
			copy_recurse(from + i, to + baseName)
	else:
		var baseName = from.get_file()
		dir.copy(from,to + baseName)

func _physics_process(delta):
	if downloading:
		var total_bytes = http.get_body_size()
		var bytes_downloaded = http.get_downloaded_bytes()
		var frac:float = (float(bytes_downloaded)/float(total_bytes))* 100
		download.text = "%06.2f%% | %s of %s" % [frac,bytes_downloaded,total_bytes] 
