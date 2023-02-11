Zipper = {}

if arg[-1] == nil or arg[-1]:sub(0, 6) == 'dofile' then
	Zipper.LUA_EXE = [[C:\Users\AleX\Saved Games\DCS.openbeta\Missions\DFCP-ME\tools\bin\lua54.exe]]
else
	Zipper.LUA_EXE = arg[-1]
end
Zipper.LUA_EXE_FILENAME = 'lua54.exe'
Zipper.UNPACK_MIZ = Zipper.LUA_EXE:gsub(Zipper.LUA_EXE_FILENAME, 'unpackMiz.ps1')
Zipper.UPDATE_MIZ = Zipper.LUA_EXE:gsub(Zipper.LUA_EXE_FILENAME, 'updateMiz.ps1')


function Zipper.unpack(miz_file_path, zip_file_path, dest_path)
	local command = 'powershell -file "' .. Zipper.UNPACK_MIZ ..
		'" -miz_file_path "' .. miz_file_path ..
		'" -zip_file_path "' .. zip_file_path ..
		'" -destination_path "' .. dest_path .. '"'
	os.execute(command)
end


function Zipper.update(mission_file_path, zip_file_path, miz_file_path)
	local command = 'powershell -file "' .. Zipper.UPDATE_MIZ ..
		'" -mission_file_dir "' .. mission_file_path ..
		'" -destination_zip "' .. zip_file_path ..
		'" -destination_miz "' .. miz_file_path .. '"'
	os.execute(command)
end