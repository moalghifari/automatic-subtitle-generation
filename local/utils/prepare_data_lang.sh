#!/usr/bin/env bash

lang_folder=$1

cd ..

utils/prepare_lang.sh data/local/lang '<unk>' data/local/ $lang_folder