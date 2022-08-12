#!/usr/bin/env bash

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

corpus=$1
utils/joint_corpus.sh $corpus
cat ../data/local/corpus.txt | sed 's/ /\n/g' | sort -u > ../data/all/words.txt
# cp ../data/all/words.txt ../data/train/words.txt
ngram-count -vocab ../data/all/words.txt -text ../data/local/corpus.txt -order 1 -write ../data/local/count_1.txt -unk
python utils/filter_lexicon_not_found.py
python utils/generate_lexicon.py
python utils/filter_lexicon.py
