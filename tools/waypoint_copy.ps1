# This script automates copying waypoints from one flight to multiple other flights in a mission file.
# When run successfully, a new miz file will be created in the same directory as the input miz, named: "mymissionname.wpcopy.miz"

# Usage:
# Update the below ARGS.
# miz_file_path: the full path to your *.miz file
# src_aircraft: the group name of the flight to copy waypoints from
# dst_aircraft: a space separated list of flight names to copy waypoints to

# ARGS
$miz_file_path = "C:\Users\Chris\Saved Games\DCS\Missions\scripts\DFCP-ME\tools\WAYPOINT_COPY_TEST.miz"
$src_aircraft = "ENYA"
$dst_aircraft = "ORPHAN PIRATE PATCH" # group names must be alphanumeric, can use - and _
# END OF ARGS




# copy the miz file into a zip file, then expand it
Remove-Item ./tmp_miz.zip -force -ErrorAction SilentlyContinue
Copy-Item $miz_file_path  -Destination ./tmp_miz.zip
Expand-Archive ./tmp_miz.zip -DestinationPath ./expanded_miz/ -force
remove-item tmp_miz.zip -force # cleanup the temp zip file

# run lua script to update the waypoints in the *.miz/mission file
./bin/lua/lua54.exe waypoint_copy.lua .\expanded_miz\mission $src_aircraft $dst_aircraft


# zip up the mission files into expanded_miz.zip
Remove-Item ./expanded_miz.zip -ErrorAction SilentlyContinue # remove the zip if we error'd out before
Compress-Archive expanded_miz/* -DestinationPath expanded_miz.zip
Remove-Item expanded_miz -Recurse -force # delete expanded_miz folder

# rename the zipped up files into a miz file that won't overwrite the original
$out_file_path = $miz_file_path -replace ".miz$", ".wpcopy.miz"
Remove-Item $out_file_path -ErrorAction SilentlyContinue # wipe out the previous file, if we ran this before
rename-item expanded_miz.zip $out_file_path 