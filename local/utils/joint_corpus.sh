#!/usr/bin/env bash

corpus=$1
corpus_path="../data/local/corpus.txt"
rm $corpus_path
touch $corpus_path
IFS=',' read -r -a corpus_array <<< "$corpus"
for corpus_source in "${corpus_array[@]}"; do
    if [[ $corpus_source == *"ind_"* ]]; then
        cat $corpus_path | cat - ../data/corpus/$corpus_source/editted_corpus.txt > $corpus_path.temp && mv $corpus_path.temp $corpus_path
    else
        text_path="../data/$corpus_source/text" 
        cut -f 2- -d ' ' $text_path > $text_path.tmp
        cat $corpus_path | cat - $text_path.tmp > $corpus_path.temp && mv $corpus_path.temp $corpus_path
    fi
done
