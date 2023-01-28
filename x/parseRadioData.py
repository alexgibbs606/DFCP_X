#!/bin/env python311

FILE_DOCUMENTATION = r''' Radio data taken exported from the SRS google document.

original file: https://docs.google.com/spreadsheets/d/1tzd996zJ1t0heZ-t1PpL7vNUIZbXl7pI6De0GThN1Qw/edit?usp=sharing

If an update is needed, export this file as csv, remove all but the data and it's header and place in `DFCP-ME\x\radio.data.csv`.

Run the file `DFCP-ME\x\parseRadioData.py` with python > 3.7 to create the `DFCP-ME\tools\share\lua\5.4\dat\radio_data.lua` file including this message.

As of January 2023, the airframe names are NOT accurate to what's in DCS; `DFCP-ME\tools\share\lua\5.4\dat\radio.lua` includes a mapping from DCS airframe names to the names found in the `radio_data.lua` file.
'''

from textwrap import dedent

data = {}

with open(r'DFCP-ME\x\radio.data.csv') as inFile:
	inFile.readline()
	for line in inFile.readlines():
		line = [_.strip() for _ in line.split(',')]

		data[line[0]] = [
			{
				'radioName': line[1],
				'minFreq': line[2],
				'maxFreq': line[3],
				'GUARD': line[4],
			}, {
				'radioName': line[1+4],
				'minFreq': line[2+4],
				'maxFreq': line[3+4],
				'GUARD': line[4+4],
			}, {
				'radioName': line[1+8],
				'minFreq': line[2+8],
				'maxFreq': line[3+8],
				'GUARD': line[4+8],
			},
		]


with open(r'DFCP-ME\tools\share\lua\5.4\dat\radio_data.lua', 'w') as outFile:
	# Writing our documentation
	outFile.write(f'--[[{FILE_DOCUMENTATION}--]]\n\n')

	# Starting out radio data table
	outFile.write('radio_data = {')

	for airframeName, radioData in data.items():
		for radio in radioData:
			for field, value in radio.items():

				# If no radio data if provided, we're going to provide a null value
				if value in ['No Radio', '']:
					radio[field] = 'nil'

				# If we do have radio information, we sort for floats and strings
				else:
					try:
						radio[field] = float(value)
					except ValueError:
						radio[field] = f'"{value}"'

		# Writing radio information for this airframe.
		outFile.write(dedent(f'''
			["{airframeName}"] = {{
				{{
					["radioName"] = {radioData[0]['radioName']},
					["minFrequency"] = {radioData[0]['minFreq']},
					["maxFrequency"] = {radioData[0]['maxFreq']},
					["GUARDFrequency"] = {radioData[0]['GUARD']},
				}}, {{
					["radioName"] = {radioData[1]['radioName']},
					["minFrequency"] = {radioData[1]['minFreq']},
					["maxFrequency"] = {radioData[1]['maxFreq']},
					["GUARDFrequency"] = {radioData[1]['GUARD']},
				}}, {{
					["radioName"] = {radioData[2]['radioName']},
					["minFrequency"] = {radioData[2]['minFreq']},
					["maxFrequency"] = {radioData[2]['maxFreq']},
					["GUARDFrequency"] = {radioData[2]['GUARD']},
				}}
			}},
		''').replace('\n', '\n\t'))
	outFile.write('}')