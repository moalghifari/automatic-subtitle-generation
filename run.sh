#!/usr/bin/env bash

# Based mostly on the TIMIT recipe. The description of the database:
# https://github.com/moalghifari/indonesian-asr/data_preparation.md

train_folder="$(local/joint_data.sh $1)"
test_folder="$(local/joint_data.sh $2)"
lm=$3

rm -rf exp mfcc
mkdir exp mfcc

echo ============================================================================
echo "                             Prepare Data                                 "
echo ============================================================================
for folder in $train_folder $test_folder; do 
    local/prepare_data.sh $folder || exit 1;
done

echo ============================================================================
echo "                             Extract MFCC                                 "
echo ============================================================================
for folder in $train_folder $test_folder; do 
    local/extract_mfcc.sh $folder || exit 1;
done

echo ============================================================================
echo "                     MonoPhone Training & Decoding                        "
echo ============================================================================
local/train_monophone.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "           tri1 : Deltas + Delta-Deltas Training & Decoding               "
echo ============================================================================
local/train_triphones_delta.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "                 tri2 : LDA + MLLT Training & Decoding                    "
echo ============================================================================
local/train_triphones_lda_mllt.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "              tri3 : LDA + MLLT + SAT Training & Decoding                 "
echo ============================================================================
local/train_triphones_sat_fmllr.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "               DNN Hybrid Training & Decoding (Karel's recipe)            "
echo ============================================================================
steps/align_fmllr.sh --nj 3 --cmd "run.pl" data/$train_folder data/$lm exp/tri3 exp/tri3_ali || exit 1;
rm -R data-fmllr-tri3
local/nnet/run_dnn.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "                          CNN (Karel's recipe)                            "
echo ============================================================================
rm -R data-fbank
local/nnet/run_cnn.sh $train_folder $test_folder $lm || exit 1;

echo ============================================================================
echo "Finished successfully on" `date`
echo ============================================================================

exit 0
