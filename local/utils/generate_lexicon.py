#!/usr/bin/env python
# -*- coding: utf-8 -*-

generated_lexicon_path="../data/all/generated_lexicon.txt"
lexicon_not_found_path="../data/all/lexicon_not_found.txt"

lexicon_not_found = open(lexicon_not_found_path, 'r')
generated_lexicon = open(generated_lexicon_path, 'w')

transformed_last_char = {
    'b': 'p',
    'd': 't',
    'g': 'k'
}
pair_phoneme = ['ng', 'ny', 'sy']
vowels = ['a', 'i', 'u', 'e', 'o']
phoneme = {
    'a' : 'a',
    'b' : 'b e',
    'c' : 'c e',
    'd' : 'd e',
    'e' : 'e',
    'f' : 'e f',
    'g' : 'g e',
    'h' : 'h a',
    'i' : 'i',
    'j' : 'j e',
    'k' : 'k a',
    'l' : 'e l',
    'm' : 'e m',
    'n' : 'e n',
    'o' : 'o',
    'p' : 'p e',
    'q' : 'q i',
    'r' : 'e r',
    's' : 'e s',
    't' : 't e',
    'u' : 'u',
    'v' : 'v e',
    'w' : 'w e',
    'x' : 'e x',
    'y' : 'y e',
    'z' : 'z e t',
}

for line in lexicon_not_found:
    word_dict = line.split('\n')[0]
    word = word_dict.replace("<", "")
    word = word.replace(">", "")
    word = word.replace("-", "")

    # Check vowels / consonants chain length
    chain_count = 0
    chain_list = []
    is_chain_of_vowels = True
    for char in word:
        if char in vowels:
            if is_chain_of_vowels is True:
                chain_count = chain_count + 1
            else:
                chain_list.append(chain_count)
                chain_count = 1
                is_chain_of_vowels = True
        else:
            if is_chain_of_vowels is False:
                chain_count = chain_count + 1
            else:
                chain_list.append(chain_count)
                chain_count = 1
                is_chain_of_vowels = False
    chain_list.append(chain_count)
    max_chain_count = max(chain_list)
    fonem = ''
    if max_chain_count <= 4:
        prev_char = ''
        next_char = ''
        is_last_char = False

        for prefix in ['me', 'pe', 'ke', 'ter', 'ber', 'se']:
            if prefix in word[:3]:
                if prefix == 'me' and 'pe' in word[:6]:
                    word = word[:6].replace('e', '@') + word[6:]
                    break
                word = word[:3].replace('e', '@') + word[3:]

        for i in range(0, len(word)):
            char = word[i]

            if i == 0:
                prev_char = ''
                if len(word) >= 2:
                    next_char = word[i+1]
            elif i == len(word) - 1:
                prev_char = word[i-1]
                next_char = ''
                is_last_char = True
            else:
                prev_char = word[i-1]
                next_char = word[i+1]

            if char == 'q':
                char = 'k'
                        
            # Double consonant phoneme
            if (prev_char+char) in pair_phoneme:
                fonem = '{}{} '.format(fonem[:-1], char)
                continue

            # Diphtong
            if char == 'i' and prev_char == 'a':
                fonem = '{}y '.format(fonem[:-1])
                continue
            if char == 'i' and prev_char in ['e', 'o']:
                char = 'y'

            if char == 'i' and (next_char in ['a', 'u', 'e', 'o']):
                fonem = '{}{} y '.format(fonem, char)
                continue
            if char == 'e' and (next_char in ['a', 'o']):
                fonem = '{}{} y '.format(fonem, char)
                continue
            if char == 'u' and next_char == 'a':
                fonem = '{}{} w '.format(fonem, char)
                continue

            if is_last_char and char in transformed_last_char:
                fonem = '{}{} '.format(fonem, transformed_last_char[char])
                continue
        
            fonem = '{}{} '.format(fonem, char)
    else:
        for i in range(0, len(word)):
            char = word[i]
            fonem = '{}{} '.format(fonem, phoneme[char])

    fonem = fonem[:-1]
    lexicon_fonem = '{} {}\n'.format(word_dict, fonem)
    generated_lexicon.write(lexicon_fonem)

generated_lexicon.close()

import os
os.system("cp {} ../generated_lexicon".format(generated_lexicon_path))

lexicon_path="../lexicon"
manual_lexicon_path="../manual_lexicon"
semi_manual_lexicon_path="../semi_manual_lexicon"
generated_lexicon_path="../generated_lexicon"
lexicon = open(lexicon_path, 'w')
manual_lexicon = open(manual_lexicon_path, 'r')
semi_manual_lexicon = open(semi_manual_lexicon_path, 'r')
generated_lexicon = open(generated_lexicon_path, 'r')
lexicon.write(manual_lexicon.read())
lexicon.write(semi_manual_lexicon.read())
lexicon.write(generated_lexicon.read())