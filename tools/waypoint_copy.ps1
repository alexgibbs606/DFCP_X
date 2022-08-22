# This script automates copying waypoints from one flight to multiple other flights in a mission file.
# When run successfully, a new miz file will be created in the same directory as the input miz, named: "mymissionname.wpcopy.miz"

# Usage:1
# Update the below ARGS.
# miz_file_path: the full path to your *.miz file
# src_aircraft: the group name of the flight to copy waypoints from
# dst_aircraft: a space separated list of flight names to copy waypoints to

# ARGS
$miz_file_path = "C:\Users\Chris\Saved Games\DCS\Missions\PG_M13.miz"
$src_aircraft = "BONK"
$dst_aircraft = "CONTACT ORPHAN ENYA PATCH DESKPOP FURRY PIRATE" # group names must be alphanumeric, can use - and _

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
./bin/lua/lua54.exe waypoint_copy.lua ./expanded_miz/mission $src_aircraft $dst_aircraft

##############
##### zip up the mission files into tmp_miz.zip
##############
Compress-Archive -update ./expanded_miz/mission tmp_miz.zip #
Remove-Item expanded_miz -Recurse -force # delete expanded_miz folder

# rename the zipped up files into a miz file that won't overwrite the original
$out_file_path = $miz_file_path -replace ".miz$", ".wpcopy.miz"
Remove-Item $out_file_path -ErrorAction SilentlyContinue # wipe out the previous file, if we ran this before
Move-Item tmp_miz.zip $out_file_path 