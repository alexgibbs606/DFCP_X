<# Script used to unpack mission files from DCS `.miz` for opening.

	Arguments:
		miz_file_path: The source miz file to unpack
		destination_path: The destination directory to unpack the miz file

	Usage in command line:
		unpackMiz ./OperationConjecture.miz ./OperationConjecture.230124.2024

	Usage in lua:
		os.execute('unpackMiz ' .. mission_path .. ' ' .. mission_path:gsub('.miz.', os.date('%y%m%d.%H%M')))
#>

[CmdletBinding()]
param (
	# Parameter help description
	[Parameter(Mandatory=$true)]
	[string]
	$mission_file_dir,
	# Parameter help description
	[Parameter(Mandatory=$true)]
	[string]
	$destination_zip,
	# Parameter help description
	[Parameter(Mandatory=$true)]
	[string]
	$destination_miz
)

# Packing our data from the source directory
Compress-Archive -update $mission_file_dir $destination_zip

# Unpacking miz file
Copy-Item "$($destination_zip)" $destination_miz