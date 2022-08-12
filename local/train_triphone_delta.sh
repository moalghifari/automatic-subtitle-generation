#!/usr/bin/env bash

train_cmd="run.pl"
decode_cmd="run.pl"

HMM_states="2000"
Gaussians="10000"

train_folder=$1
test_folder=$2
lm=$3

steps/align_si.sh \
    --boost-silence 1.25 \
    --nj 4 \
    --cmd "$train_cmd" \
    data/$train_folder data/$lm exp/mono exp/mono_ali || exit 1;

steps/train_deltas.sh \
    --boost-silence 1.25 \
    --cmd "$train_cmd" "$HMM_states" "$Gaussians" \
    data/$train_folder data/$lm exp/mono_ali exp/tri1 || exit 1;

utils/mkgraph.sh \
    data/$lm exp/tri1 exp/tri1/graph_tgpr

steps/decode.sh \
    --nj 4 \
    --cmd "run.pl" \
    exp/tri1/graph_tgpr data/$test_folder exp/tri1/decode_$test_folder
