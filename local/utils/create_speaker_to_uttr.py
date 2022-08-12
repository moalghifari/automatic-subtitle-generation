#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Create spk2utt file that maps each speaker id to list of utterance id
"""

import os
import sys

folder = sys.argv[1]
os.chdir("..")
os.system("utils/fix_data_dir.sh data/{}".format(folder))