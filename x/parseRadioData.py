#!/bin/env python311

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



with open(r'DFCP-ME\tools\share\lua\5.4\dat\radio.data.lua', 'w') as outFile:
	outFile.write('radio = {')
	for airframeName, radioData in data.items():
		for radio in radioData:
			for field, value in radio.items():
				if value in ['No Radio', '']:
					radio[field] = 'nil'
				else:
					try:
						radio[field] = float(value)
					except ValueError:
						radio[field] = f'"{value}"'

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
		'''))
	outFile.write('}')