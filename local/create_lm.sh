#!/usr/bin/env bash

lm=$1

rm -rf ../data/lang_$lm ../data/local/lm_$lm ../data/local/lang ../data/all
mkdir ../data/lang_$lm ../data/local/lm_$lm ../data/local/lang ../data/all

utils/prepare_lexicon.sh $lm

utils/prepare_data_local_lang.sh || exit 1;
utils/prepare_data_lang.sh data/lang_$lm || exit 1;
utils/prepare_lm.sh data/lang_$lm data/local/lm_$lm || exit 1;
