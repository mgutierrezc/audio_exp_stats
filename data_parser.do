cls
/*=========================
Parser for oTree data from
audio experiment Judges
==

Programmer: Marco Gutierrez
=========================*/

clear all
set more off

di `"Please, input the path for storing the outputs of this dofile into the COMMAND WINDOW and then press ENTER  "'  _request(path)
cd "$path"

global aux_path = "$path\aux_path"
cap mkdir aux_path

/*----------------
Fixing length of variable names
------------------*/

python:
from sfi import Macro
import pandas as pd
import re

files = ["all_apps_wide-2022-02-22.csv", "all_apps_wide-2022-02-24 (5).csv"]


for file in files:
	session_data = pd.read_csv(file)
	old_names = session_data.columns

	# renaming cols for shorter names
	updated_names = [name.replace("audio_files_supreme_court.", "afsc_") for name in old_names]
	updated_names = [name.replace("demographic", "dem_") for name in updated_names]
	updated_names = [name.replace("participantmturk_", "") for name in updated_names]
	updated_names = [name.replace("participant_", "") for name in updated_names]
	updated_names = [name.replace("participant.", "") for name in updated_names]
	updated_names = [name.replace("sessionmturk_", "") for name in updated_names]
	updated_names = [name.replace("player.qN_times_played_audio", "pqn_times_aud") for name in updated_names]
	updated_names = [name.replace("_order_", "_o_") for name in updated_names]
	updated_names = [name.replace("_reversed_", "_r_") for name in updated_names]
	updated_names = [name.replace("beep_answer_correct", "beep_cor") for name in updated_names]
	updated_names = [name.replace("player.gender_audios", "p_gender_aud") for name in updated_names]

	# swaping prefixes - suffixes
	final_names = []
	for name in updated_names:
		# extract preffix if detected
		print("name: ", name)
		preffix = re.match("afsc_\d+", name)
		print("preffix: ", preffix)
		
		if preffix:
			# swap if preffix was detected
			name = name.replace(preffix.group(0), "")
			name = name + "_" + preffix.group(0)
					
		final_names.append(name)
	
	session_data.columns = final_names # updating names

	# saving fixed file
	file_path = Macro.getGlobal("aux_path") + "/" + file
	session_data.to_csv(file_path, index=False)
	
end


/*----------------
Importing and reshaping data
------------------*/


import delimited "$aux_path\all_apps_wide-2022-02-24 (5).csv", clear
	
	***
	*Keeping variables of interest
	***
// 	keep mturk_worker_id sessionmturk_hitid afsc* dem*
	
	*drop missing worker ids
	drop if mturk_worker_id==""
	
	unab vars : *24
	local stubs : subinstr local vars "24" "", all
	
	*wide to long reshape
	reshape long `stubs', i(mturk_worker_id) j(time)
	