#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Create spk2gender file that gives speaker gender information
"""

import os
import sys

folder = sys.argv[1]
os.chdir('../data')

spk2utt = open("{}/spk2utt".format(folder), "r")
spk2gender = open("{}/spk2gender".format(folder), "w")
for line in spk2utt:
    spk_id = line.split()[0]
    spk_gender = spk_id[0]
    if spk_gender not in ['f', 'm']:
        spk_gender = 'UNKNOWN'
    spk2gender.write(spk_id + ' ' + spk_gender + '\n')
spk2gender.close()