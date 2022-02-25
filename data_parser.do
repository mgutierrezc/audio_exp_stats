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

files = ["all_apps_wide-2022-02-22.csv", "all_apps_wide-2022-02-24 (5).csv"]


for file in files:
	session_data = pd.read_csv(file)
	old_names = session_data.columns

	# renaming cols for shorter names
	updated_names = [name.replace("audio_files_supreme_court", "afsc_") for name in old_names]
	updated_names = [name.replace("demographic", "dem_") for name in updated_names]
	updated_names = [name.replace("participantmturk_", "") for name in updated_names]
	updated_names = [name.replace("participant_", "") for name in updated_names]
	updated_names = [name.replace("participant.", "") for name in updated_names]
	updated_names = [name.replace("sessionmturk_", "") for name in updated_names]

	session_data.columns = updated_names # updating names

	# saving fixed file
	file_path = Macro.getGlobal("aux_path") + "/" + file
	session_data.to_csv(file_path, index=False)
	
end


/*----------------
Importing and reshaping data
------------------*/

***
import delimited "$aux_path\all_apps_wide-2022-02-24 (5).csv", clear