#!/usr/bin/env bash

train_cmd="run.pl"
decode_cmd="run.pl"

HMM_states="2500"
Gaussians="15000"

train_folder=$1
test_folder=$2
lm=$3

steps/align_si.sh \
    --nj 4 \
    --cmd "$train_cmd" \
    --use-graphs true \
    data/$train_folder data/$lm exp/tri2 exp/tri2_ali  || exit 1;

steps/train_sat.sh \
    --cmd "$train_cmd" "$HMM_states" "$Gaussians" \
    data/$train_folder data/$lm exp/tri2_ali exp/tri3

utils/mkgraph.sh \
    data/$lm exp/tri3 exp/tri3/graph_tgpr

steps/decode_fmllr.sh \
    --nj 4 \
    --cmd "run.pl" \
    exp/tri3/graph_tgpr data/$test_folder exp/tri3/decode_$test_folder
