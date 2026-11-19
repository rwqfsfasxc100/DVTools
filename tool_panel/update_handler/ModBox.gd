# [license]
# 3-Clause BSD NON-AI License
# 
# Copyright 2026 __hev (Benjamin Buckhurst)
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# 
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer
# in the documentation and/or other materials provided with the distribution.
# 
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
# 
# 4. The source code and the binary form, and any modifications made to them may not be used for the purpose of input data, reference code snippets and/or files, OR used in the training of, or improvement of machine learning algorithms,
# including but not limited to artificial intelligence, natural language processing, or data mining. This condition applies to any derivatives,
# modifications, or updates based on the Software code. Any usage of the source code or the binary form may not be present in any form as data fed, inputted, or provided to an AI, or present in any AI-training dataset is considered a breach of this License.
# 
# 5. Any projects deriving work from this project MUST include a copy of this license and all other license and/or copyright agreements posed within other source material,
# all of which must be followed to its entirety. Failure to follow these licenses prohibit all modification and redistribution of the material until all licensing has been reinstated.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
# OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
# EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# [/license]

tool
extends HBoxContainer

var download_url = ""
var file_to_store = ""
onready var download = $Button
onready var label = $Label
onready var http = $HTTPRequest

var mod_display = "MOD NAME MISSING (no ID D:)"

var mod_id = ""

var base_menu

const base_download_dir = "user://cache/.DVTools_Cache/zip_dir/"
const update_store:String = "user://cache/.DVTools_Cache/needs_updates.json"

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
		base_menu.fetch_manifests(2)

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
