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
	$destination_miz
)

$zip_file_path = "$($destination_miz.basename).zip"

# Packing our data from the source directory
Compress-Archive $mission_file_dir -DestinationPath $zip_file_path -force

# Unpacking miz file
Move-Item "$($zip_file_path)" $destination_miz