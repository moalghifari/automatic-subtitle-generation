#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

ALLOWED_EXTENSIONS = {'.mp4'}
os.chdir('../input_wav')
input_path = os.getcwd()
filename = sys.argv[1]
transcriptions_folder = sys.argv[2]
f = open("../{}/wav.scp".format(transcriptions_folder), "w")

actual_filename = os.path.splitext(filename)[0]
f.write("{} input_wav/{}\n".format(actual_filename, filename))

f.close()