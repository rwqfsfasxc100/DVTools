# [license]
# SPDX-License-Identifier: LicenseRef-Proprietary
# Copyright © 2026 __hev (Benjamin Buckhurst). All Rights Reserved.
# 
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that all following conditions are met:
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
extends CheckButton

var modlet_path:String = ""

func _ready():
	connect("visibility_changed",self,"change_name")

func change_name():
	var mname = parse_file_as_manifest()
	var nameConcat = modlet_path
	if mname:
		nameConcat = "%s (%s)" % [mname,modlet_path]
	text = nameConcat

var file:File = File.new()
func parse_file_as_manifest() -> String:
	var mname:String = ""
	if modlet_path and file.file_exists(modlet_path):
		var cfg = ConfigFile.new()
		cfg.load(modlet_path)
		var mv = 1.0
		if cfg.has_section("manifest_definitions") and cfg.has_section_key("manifest_definitions","manifest_version"):
			mv = cfg.get_value("manifest_definitions","manifest_version",mv)
		match mv:
			1,1.0,2,2.0:
				mname = cfg.get_value("package","name","")
			2.1,2.2:
				mname = cfg.get_value("mod_information","name","")
	return mname
