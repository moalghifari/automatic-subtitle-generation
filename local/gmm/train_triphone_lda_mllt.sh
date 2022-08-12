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
    data/$train_folder data/$lm exp/tri1 exp/tri1_ali || exit 1;

steps/train_lda_mllt.sh \
    --cmd "$train_cmd" \
    --splice-opts "--left-context=3 --right-context=3" "$HMM_states" "$Gaussians" \
    data/$train_folder data/$lm exp/tri1_ali exp/tri2 || exit 1;

utils/mkgraph.sh \
    data/$lm exp/tri2 exp/tri2/graph_tgpr

steps/decode.sh \
    --nj 4 \
    --cmd "run.pl" \
    exp/tri2/graph_tgpr data/$test_folder exp/tri2/decode_$test_folder
