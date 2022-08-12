#!/usr/bin/env bash

cd ../data/local/lang

# non-silence
cut -d ' ' -f 2- lexicon.txt |  sed 's/ /\n/g' | sort -u > nonsilence_phones.txt

printf "%s\n%s\n" '!SIL SIL' "<unk> <noise>" | cat - lexicon.txt > lexicon.temp && mv lexicon.temp lexicon.txt

python ../../../local/utils/delete_newline_nonsil.py

# silence
printf "SIL\n<noise>\n" > silence_phones.txt

# optional silence
echo 'SIL' > optional_silence.txt

# extra
echo '' > extra_question.txt