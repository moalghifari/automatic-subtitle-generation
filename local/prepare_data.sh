#!/usr/bin/env bash

# Prepare words.txt, wav.scp, utt2spk, spk2utt

folder=$1

cd local/

cut -d ' ' -f 2- ../data/$folder/text | sed 's/ /\n/g' | sort -u > ../data/$folder/words.txt

python create_path_file.py $folder

python create_uttr_to_speaker.py $folder

python create_speaker_to_uttr.py $folder

# for x in $train_folder $test_folder; do 
#     python create_speaker_to_gender.py data/$folder
# done
