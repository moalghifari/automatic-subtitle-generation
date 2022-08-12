#!/usr/bin/env python
# -*- coding: utf-8 -*-

lexicon_path="../manual_lexicon"
semi_manual_lexicon_path="../semi_manual_lexicon"
# words_path="../data/all/words.txt"
words_path="../data/local/count_1.txt"
lexicon_not_found_path="../data/all/lexicon_not_found.txt"

lexicon = open(lexicon_path, 'r')
semi_manual_lexicon = open(semi_manual_lexicon_path, 'r')
words = open(words_path, 'r')
lexicon_not_found = open(lexicon_not_found_path, 'w')

lexicon_dict = {}
for line in lexicon:
    line_splitted = line.split(' ', 1)
    if line_splitted[0] in lexicon_dict:
        lexicon_dict[line_splitted[0]].append(line_splitted[1])
    else:
        lexicon_dict[line_splitted[0]] = [line_splitted[1]]

for line in semi_manual_lexicon:
    line_splitted = line.split(' ', 1)
    if line_splitted[0] in lexicon_dict:
        lexicon_dict[line_splitted[0]].append(line_splitted[1])
    else:
        lexicon_dict[line_splitted[0]] = [line_splitted[1]]

for line in words:
    parts = line.split()
    word = parts[0]
    count = parts[1].rstrip()
    if int(count) < 3:
        continue
    if word not in lexicon_dict:
        lexicon_not_found.write('{}\n'.format(word))