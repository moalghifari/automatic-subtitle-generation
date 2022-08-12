#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Create utt2spk file that maps each utterance id to speaker id
"""

import os
import sys

folder = sys.argv[1]
os.chdir('../data')

path = '../../wav/'
segments = open("{}/segments".format(folder), "r")
utt2spk = open("{}/utt2spk".format(folder), "w")
for line in segments:
    uttr_id = line.split()[0]
    speaker_id = uttr_id.split('-')[0]
    utt2spk.write(uttr_id + ' ' + speaker_id + '\n')
utt2spk.close()