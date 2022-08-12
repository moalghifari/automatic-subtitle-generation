#!/usr/bin/env bash

lang_folder=$1
lm_folder=$2

cd ..

# utils/format_lm.sh data/lang data/local/lm/srilm-1.7.3.tar.gz data/local/lang/lexicon.txt data/lang_test


echo
echo "===== MAKING lm.arpa ====="
echo
loc=`which ngram-count`;
if [ -z $loc ]; then
    if uname -a | grep 64 >/dev/null; then
        sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
    else
        sdir=$KALDI_ROOT/tools/srilm/bin/i686
    fi
    if [ -f $sdir/ngram-count ]; then
        echo "Using SRILM language modelling tool from $sdir"
        export PATH=$PATH:$sdir
    else
        echo "SRILM toolkit is probably not installed.
            Instructions: tools/install_srilm.sh"
        exit 1
    fi
fi
local=data/local
mkdir $lm_folder
lm_order=3

# WBDiscount
# ngram-count -vocab data/all/words.txt -text $local/corpus.txt -order 3 -write-vocab $lm_folder/vocab.txt -wbdiscount -lm $lm_folder/lm.arpa -unk

# Read
ngram-count -vocab data/all/words.txt -text $local/corpus.txt -order 3 -write $lm_folder/count.txt -unk -write-vocab $lm_folder/vocab.txt
ngram-count -read $lm_folder/count.txt -order 3 -lm $lm_folder/lm.arpa -vocab data/all/words.txt

# Addsmooth
# ngram-count -vocab data/all/words.txt -text $local/corpus.txt -order 3 -addsmooth 1 -lm $lm_folder/lm.arpa

# Model OOV words explicitly
# ngram-count -kndiscount -interpolate -vocab data/all/words.txt -unk -text $local/corpus.txt -order 3 -lm $lm_folder/lm.arpa

# Basic Default
# ngram-count -text $local/corpus.txt -order 3 -lm $lm_folder/lm.arpa


echo
echo "===== MAKING G.fst ====="
echo
lang=data/lang
arpa2fst --disambig-symbol=#0 --read-symbol-table=$lang_folder/words.txt $lm_folder/lm.arpa $lang_folder/G.fst
