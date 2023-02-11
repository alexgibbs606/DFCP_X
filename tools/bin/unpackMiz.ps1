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
	$miz_file_path,
	# Parameter help description
	[Parameter(Mandatory=$true)]
	[string]
	$zip_file_path,
	# Parameter help description
	[Parameter(Mandatory=$true)]
	[string]
	$destination_path
)

# Unpacking miz file
Copy-Item "$($miz_file_path)" "$($zip_file_path)"

# Pulling data our of our new zip file
Expand-Archive "$($zip_file_path)" -DestinationPath "$($destination_path)" -force