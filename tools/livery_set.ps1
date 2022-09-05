# This script changes the livery of all ground vehicles to desert/winter. Creates a new miz file named "yourmizname.livery.miz"

# Usage:
# Update the below ARGS.
# miz_file_path: the full path to your *.miz file
# theme: desert/winter

# ARGS
$miz_file_path = "C:\Users\Chris\Saved Games\DCS\Missions\test_moose.miz"
$theme = "desert" # Choose: (desert, winter) ... maybe more later on
# END OF ARGS



########
# Make a tmp miz file, expand it so we can edit it
########
# remove any existing tmp file first
Remove-Item ./tmp_miz.zip -force -ErrorAction SilentlyContinue

Copy-Item $miz_file_path  -Destination ./tmp_miz.zip
Expand-Archive ./tmp_miz.zip -DestinationPath ./expanded_miz/ -force # we'll reuse this later


# run lua script to update the waypoints in the *.miz/mission file
# updates the ./expanded_miz/mission file
$cwd = (get-item livery_set.ps1).Directory.FullName # hack to make lua libs work
./bin/lua/lua54.exe livery_set.lua $cwd/lib ./expanded_miz/mission $theme

##############
##### zip up the mission files into tmp_miz.zip
##############
Compress-Archive -update ./expanded_miz/mission tmp_miz.zip #
Remove-Item expanded_miz -Recurse -force # delete expanded_miz folder

# rename the zipped up files into a miz file that won't overwrite the original
$out_file_path = $miz_file_path -replace ".miz$", ".livery.miz"
Remove-Item $out_file_path -ErrorAction SilentlyContinue # wipe out the previous file, if we ran this before
Move-Item tmp_miz.zip $out_file_path 