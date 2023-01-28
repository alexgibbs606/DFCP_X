--[[ Radio data taken exported from the SRS google document.

original file: https://docs.google.com/spreadsheets/d/1tzd996zJ1t0heZ-t1PpL7vNUIZbXl7pI6De0GThN1Qw/edit?usp=sharing

If an update is needed, export this file as csv, remove all but the data and it's header and place in `DFCP-ME\x\radio.data.csv`.

Run the file `DFCP-ME\x\parseRadioData.py` with python > 3.7 to create the `DFCP-ME\tools\share\lua\5.4\dat\radio_data.lua` file including this message.

As of January 2023, the airframe names are NOT accurate to what's in DCS; `DFCP-ME\tools\share\lua\5.4\dat\radio.lua` includes a mapping from DCS airframe names to the names found in the `radio_data.lua` file.
--]]

radio_data = {
	["A10A"] = {
		{
			["radioName"] = "AN/ARC-186(V)",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.98,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-186(V)FM",
			["minFrequency"] = "30 FM",
			["maxFrequency"] = "87.975 FM",
			["GUARDFrequency"] = nil,
		}
	},
	
	["MiG-29 A/S/G"] = {
		{
			["radioName"] = "R-862",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.98,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["SU-25(T)"] = {
		{
			["radioName"] = "R-862",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.98,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "R-828",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "59.975 FM",
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["SU-27"] = {
		{
			["radioName"] = "R-800",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.98,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "R-864",
			["minFrequency"] = 3.0,
			["maxFrequency"] = 10.0,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["F15C"] = {
		{
			["radioName"] = "AN/ARC-164 UHF 1",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.98,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-164 UHF 2",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.975,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["Other Aircraft / Mods / FC3"] = {
		{
			["radioName"] = "FC3 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 400.0,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "FC3 VHF",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "FC3 FM",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "87.975FM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["CA / Spectator"] = {
		{
			["radioName"] = "CA UHF/VHF",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 400.0,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "CA UHF/VHF",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 400.0,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "CA FM",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "87.975FM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["UH-1H"] = {
		{
			["radioName"] = "AN/ARC-51BX - UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-134",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "AN/ARC-131",
			["minFrequency"] = "30 FM",
			["maxFrequency"] = "75.95 FM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["SA342 M/L"] = {
		{
			["radioName"] = "TRAP 138A",
			["minFrequency"] = 118.0,
			["maxFrequency"] = 143.98,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "UHF TRA 6031",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.975,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "TRC 9600 PR4G",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "60 FM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["KA-50"] = {
		{
			["radioName"] = "R-800L14 VHF/UHF",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "R-828",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "59.975 FM",
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["Mi-8"] = {
		{
			["radioName"] = "R-863",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = "121.5 or 243",
		}, {
			["radioName"] = "JADRO-1A",
			["minFrequency"] = 2.0,
			["maxFrequency"] = 20.0,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "R-828",
			["minFrequency"] = "20 FM",
			["maxFrequency"] = "59.975 FM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["L-39"] = {
		{
			["radioName"] = "R-832M",
			["minFrequency"] = 118.0,
			["maxFrequency"] = 399.95,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "INTERCOM",
			["minFrequency"] = "INTERCOM",
			["maxFrequency"] = "INTERCOM",
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["A10C"] = {
		{
			["radioName"] = "AN/ARC-186(V)",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-186(V)FM",
			["minFrequency"] = "30 FM",
			["maxFrequency"] = "87.975 FM",
			["GUARDFrequency"] = 40.5,
		}
	},
	
	["F-86"] = {
		{
			["radioName"] = "AN/ARC-27",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["MiG-15"] = {
		{
			["radioName"] = "RSI-6K",
			["minFrequency"] = 3.75,
			["maxFrequency"] = 5.0,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["MiG-21"] = {
		{
			["radioName"] = "R-832",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["TF/P-51D"] = {
		{
			["radioName"] = "SCR522A",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 156.0,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["FW-190"] = {
		{
			["radioName"] = "FuG 16ZY",
			["minFrequency"] = 38.4,
			["maxFrequency"] = 42.4,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["BF-109"] = {
		{
			["radioName"] = "FuG 16ZY",
			["minFrequency"] = 38.4,
			["maxFrequency"] = 42.4,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["C-101"] = {
		{
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-134",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 149.975,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "INTERCOM",
			["minFrequency"] = "INTERCOM",
			["maxFrequency"] = "INTERCOM",
			["GUARDFrequency"] = "NO",
		}
	},
	
	["Hawk"] = {
		{
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "ARI 23259/1",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 149.975,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["M2000C"] = {
		{
			["radioName"] = "TRT ERA 7000 (V/UHF)",
			["minFrequency"] = "118-144",
			["maxFrequency"] = "225-399.975",
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "TRT ERA 7200 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["F5E-3 / MiG 28"] = {
		{
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["AJS 37"] = {
		{
			["radioName"] = "FR-22 (V/UHF)",
			["minFrequency"] = "103-155.995",
			["maxFrequency"] = "225-399.95",
			["GUARDFrequency"] = "NO",
		}, {
			["radioName"] = "FR-24 VHF",
			["minFrequency"] = 110.0,
			["maxFrequency"] = 147.0,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["F/A-18C"] = {
		{
			["radioName"] = "AN/ARC-210",
			["minFrequency"] = "30-88",
			["maxFrequency"] = "255-399.975",
			["GUARDFrequency"] = "121.5 or 243",
		}, {
			["radioName"] = "AN/ARC-210",
			["minFrequency"] = "30-88",
			["maxFrequency"] = "255-399.975",
			["GUARDFrequency"] = "121.5 or 243",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["F-14B"] = {
		{
			["radioName"] = "AN/ARC-159 (UHF1 Pilot)",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.975,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-182 (V/UHF2 RIO)",
			["minFrequency"] = "30-88",
			["maxFrequency"] = "255-399.975",
			["GUARDFrequency"] = "as desired",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["A-10C II"] = {
		{
			["radioName"] = "AN/ARC-186(V)",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-186(V)",
			["minFrequency"] = 116.0,
			["maxFrequency"] = 151.975,
			["GUARDFrequency"] = 121.5,
		}
	},
	
	["JF-17"] = {
		{
			["radioName"] = "R&S M3AR",
			["minFrequency"] = "108-173.975",
			["maxFrequency"] = "225-399.975",
			["GUARDFrequency"] = "121.5 or 243",
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["P-47"] = {
		{
			["radioName"] = "SCR522",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 150.0,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["F-16C_50"] = {
		{
			["radioName"] = "AN/ARC-164 UHF",
			["minFrequency"] = 225.0,
			["maxFrequency"] = 399.9,
			["GUARDFrequency"] = 243.0,
		}, {
			["radioName"] = "AN/ARC-222",
			["minFrequency"] = 108.0,
			["maxFrequency"] = 173.975,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["I-16"] = {
		{
			["radioName"] = "SCR522",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 156.0,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["MiG-19"] = {
		{
			["radioName"] = "RSIU-4V",
			["minFrequency"] = 100.0,
			["maxFrequency"] = 150.0,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	
	["CE-2"] = {
		{
			["radioName"] = "KY 196B",
			["minFrequency"] = 118.0,
			["maxFrequency"] = 136.992,
			["GUARDFrequency"] = 121.5,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}, {
			["radioName"] = nil,
			["minFrequency"] = nil,
			["maxFrequency"] = nil,
			["GUARDFrequency"] = nil,
		}
	},
	}