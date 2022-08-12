#!/usr/bin/env bash

train_cmd="run.pl"
decode_cmd="run.pl"

train_folder=$1
test_folder=$2
lm=$3

steps/train_mono.sh \
    --boost-silence 1.25 \
    --nj 4 \
    --cmd "$train_cmd" \
    data/$train_folder data/$lm exp/mono

utils/mkgraph.sh \
    data/$lm exp/mono exp/mono/graph_tgpr

steps/decode.sh \
    --nj 4 \
    --cmd "run.pl" \
    exp/mono/graph_tgpr data/$test_folder exp/mono/decode_$test_folder
