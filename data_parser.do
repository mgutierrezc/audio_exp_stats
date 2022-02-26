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
	updated_names = [name.replace("demographic.1.", "") for name in updated_names]
	updated_names = [name.replace("participantmturk_", "") for name in updated_names]
	updated_names = [name.replace("participant_", "") for name in updated_names]
	updated_names = [name.replace("participant.", "") for name in updated_names]
	updated_names = [name.replace("sessionmturk_", "") for name in updated_names]
	updated_names = [name.replace("player.qN_times_played_audio", "pqn_times_aud") for name in updated_names]
	updated_names = [name.replace("_order_", "_o_") for name in updated_names]
	updated_names = [name.replace("_reversed_", "_r_") for name in updated_names]
	updated_names = [name.replace("beep_answer_correct", "beep_cor") for name in updated_names]
	updated_names = [name.replace("player.gender_audios", "gender_aud") for name in updated_names]

	# swaping prefixes - suffixes
	final_names = []
	for name in updated_names:
		# extract preffix if detected
		preffix = re.match("afsc_\d+", name)
		
		if preffix: # swap if preffix was detected
			name = name.replace(preffix.group(0), "")
			name = name + "_" + preffix.group(0)
					
		final_names.append(name)

	# removing string leftovers
	final_names = [name.replace("player", "") for name in final_names]
	final_names = [name.replace("afsc_", "afsc") for name in final_names]
		
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
	
	*drop missing worker ids
	drop if mturk_worker_id==""
	
	unab vars : *24
	local stubs : subinstr local vars "24" "", all
	
	*wide to long reshape
	reshape long `stubs', i(mturk_worker_id) j(time)
	


/*----------------
Formatting variables
------------------*/

	*dropping unnecessary vars
	drop v2716 groupid_in_subsession subsessionround_number id_in_session code label _is_bot _index_in_pages _max_page_index _current_app_name _current_page_name time_started visited payoff sessioncode sessionlabel sessioncomment sessionis_demo sessionconfigreal_world_currency sessionconfiguse_browser_bots sessionconfigparticipation_fee id_in_group_afsc role_afsc payoff_afsc role id_in_group subsessionround_number_afsc groupid_in_subsession_afsc

	
	*MTurk
	rename mturk_worker_id WorkerId
	rename sessionmturk_hitid HitId
	rename sessionmturk_hitgroupid MTurkGroupId
	rename mturk_assignment_id AssignmentId 
	
	*Audio
	rename key_id_afsc AudioKey
	rename key_name_afsc Audio
	rename gender_aud_afsc Lawyer_Gender
	rename is_trial_afsc TrialAudio
	rename has_beep_afsc AudioHasBeep
	
	*AFSC Responses
	rename q1_attractive_afsc Attractive
	rename q1_masculine_afsc Masculine
	rename q1_intelligent_afsc Intelligent
	rename q1_aggressive_afsc Aggressive
	rename q1_trustworthy_afsc Trustworthy
	rename q1_confident_afsc Confident
	
	rename q1_o_attractive_afsc OrdAttractive
	rename q1_o_masculine_afsc OrdMasculine
	rename q1_o_intelligent_afsc OrdIntelligent
	rename q1_o_aggressive_afsc OrdAggressive
	rename q1_o_trustworthy_afsc OrdTrustworthy
	rename q1_o_confident_afsc OrdConfident
	
	rename q1_r_attractive_afsc RevAttractive
	rename q1_r_masculine_afsc RevMasculine
	rename q1_r_intelligent_afsc RevIntelligent
	rename q1_r_aggressive_afsc RevAggressive
	rename q1_r_trustworthy_afsc RevTrustworthy
	rename q1_r_confident_afsc RevConfident	
	
	rename pqn_times_aud_afsc TimesReplayedAudio
	
	drop q1_*
	
	rename beep_answer_afsc BeepAnswer
	rename beep_cor_afsc BeepRightAns
	
	
	