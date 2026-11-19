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
class_name ModManifestLoader
extends ResourceFormatLoader

const ManifestClass = preload("res://addons/DVTools/resource_handling/Manifest/ModManifestClass.gd")

func get_recognized_extensions() -> PoolStringArray:
	return PoolStringArray(["manifest"])

func get_resource_type(path: String) -> String:
	var ext = path.get_extension().to_lower()
	if ext == "manifest":
		return "Resource"
	return ""

func handles_type(typename: String) -> bool:
	return ClassDB.is_parent_class(typename, "Resource")

func load(path: String, original_path: String,no_subresource_cache:bool):
	var file:File = File.new()
	if not file.file_exists(path) and not ResourceLoader.exists(path):
		return ERR_CANT_OPEN
	var dt:Dictionary = __config_parse(path)
	var res := ManifestClass.new()
	res.manifest = dt
	return res

func __config_parse(file_path: String) -> Dictionary:
	var file:File = File.new()
	var cfg:ConfigFile = ConfigFile.new()
	file.open(file_path,File.READ)
	var txt : String  = file.get_as_text()
	file.close()
	cfg.parse(txt)
	var cfg_sections : Array = cfg.get_sections()
	var cfg_dictionary : Dictionary = {}
	for section in cfg_sections:
		var data : Dictionary = {}
		var keys : Array = cfg.get_section_keys(section)
		for key in keys:
			var item = cfg.get_value(section,key)
			data.merge({key:item})
		cfg_dictionary.merge({section:data})
	return cfg_dictionary
