#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os

os.chdir('..')

ref = dict()
phones = dict()

with open("lexicon") as f:
    for line in f:
        line = line.strip()
        columns = line.split(" ", 1)
        word = columns[0]
        pron = columns[1]
        try:
            ref[word].append(pron)
        except:
            ref[word] = list()
            ref[word].append(pron)

# print(ref)

lex = open("data/local/lang/lexicon_duplicate.txt", "w")

with open("data/all/words.txt") as f:
    for line in f:
        line = line.strip()
        if line == '<unk>':
            continue
        if line in ref.keys():
            for pron in ref[line]:
                lex.write(line + " " + pron + "\n")
        # else:
        #     print("Word not in lexicon:" + line)


lex = open("data/local/lang/lexicon.txt", "w")

with open("data/local/lang/lexicon_duplicate.txt") as f:
    line_dict = {}
    for line in f:
        if not line in line_dict:
            lex.write(line)
            line_dict[line] = True
