#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys

ALLOWED_EXTENSIONS = {'.mp4', '.wav'}
os.chdir('../uploads')
input_path = os.getcwd()
output_path = '../input_wav/'
filename = sys.argv[1]

actual_filename = os.path.splitext(filename)[0]
extention = os.path.splitext(filename)[1].lower()
if extention != '.wav':
    os.system('ffmpeg -i {} {}.wav'.format(filename, actual_filename))
    filename = actual_filename + '.wav'
if extention in ALLOWED_EXTENSIONS:
    res = os.system('sox {} -t wav -r 16000 {}.wav remix 1,2'.format(filename, output_path + actual_filename))
    if res != 0:
        res = os.system('sox {} -t wav -r 16000 {}.wav remix 1'.format(filename, output_path + actual_filename))
    if res != 0:
        res = os.system('sox {} -t wav -r 16000 {}.wav remix 2'.format(filename, output_path + actual_filename))
