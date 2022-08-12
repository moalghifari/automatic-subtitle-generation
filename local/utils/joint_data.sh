#!/usr/bin/env bash

folder=$1
IFS=',' read -r -a folder_array <<< "$folder"
if [[ "${#folder_array[@]}" -ge 2 ]]; then
        folder_tmp=''
        for f in "${folder_array[@]}"
        do
            folder_tmp+=$f
            folder_tmp+='_'
        done
    folder=$folder_tmp        
    if [[ ! -d data/$folder ]]; then
        mkdir data/$folder
        rm data/$folder/segments data/$folder/text
        touch data/$folder/segments data/$folder/text
        for f in "${folder_array[@]}"
        do
            cat data/$folder/segments | cat - data/$f/segments > data/$folder/segments.temp && mv data/$folder/segments.temp data/$folder/segments
            cat data/$folder/text | cat - data/$f/text > data/$folder/text.temp && mv data/$folder/text.temp data/$folder/text
        done
    fi
fi
echo $folder
