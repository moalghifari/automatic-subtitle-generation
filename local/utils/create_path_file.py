#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Create wav.scp file that maps each audio id to its path
"""

import os
import sys

folder = sys.argv[1]
os.chdir('../data')

segments = open("{}/segments".format(folder), "r")
wav_scp = open("{}/wav.scp".format(folder), "w")
filename_dict = {}
for line in segments:
    parts = line.split()
    uttr_id = parts[0]
    speaker_folder = uttr_id[2:4]
    filename = speaker_folder + uttr_id[-4:]
    env = uttr_id.split('-')[1]
    filename = parts[1]
    if not filename in filename_dict:
        if env == '20sp':
            wav_scp.write('{} 20sp_dessi/{}/{}.wav\n'.format(filename, speaker_folder, filename))
        else:
            wav_scp.write('{} wav/{}.wav\n'.format(filename,filename))
        filename_dict[filename] = True
wav_scp.close()