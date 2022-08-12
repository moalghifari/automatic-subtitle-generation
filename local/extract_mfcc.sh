#!/usr/bin/env bash

folder=$1

mfccdir=mfcc
train_cmd="run.pl"
decode_cmd="run.pl"

steps/make_mfcc.sh --cmd "$train_cmd" --nj 4 data/$folder data/$folder $mfccdir  
steps/compute_cmvn_stats.sh data/$folder data/$folder $mfccdir

if [[ ! -L exp/make_mfcc/data/$folder ]]; then
    if [[ ! -d exp/make_mfcc ]]; then
        mkdir exp/make_mfcc
        mkdir exp/make_mfcc/data
    fi
    ln -s data/$folder exp/make_mfcc/data/
fi