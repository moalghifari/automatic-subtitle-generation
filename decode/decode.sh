#!/usr/bin/env bash

filename=$1
filename_w_ext="${filename%.*}"
extension="${filename##*.}"
model=$2
output_version=$3
overlap=5
window=30
train_cmd="run.pl"
decode_cmd="run.pl"

segmented_data_dir="transcriptions/${model}/${filename_w_ext}" 
final_mdl="model/${model}/final.mdl"
if [[ $model == tri* ]]; then
    final_mat="model/${model}/final.mat"
    hclg_fst="model/${model}/graph/HCLG.fst"
    words_txt="model/${model}/graph/words.txt"
    if [[ $model == "tri_delta" ]]; then
        features="ark,s,cs:apply-cmvn  --utt2spk=ark:$segmented_data_dir/utt2spk scp:$segmented_data_dir/cmvn.scp scp:$segmented_data_dir/feats.scp ark:- | add-deltas  ark:- ark:- |" 
    elif [[ $model == "tri_sat_fmllr" ]]; then
        final_mat="model/${model}/final.mat"
        features="ark,s,cs:apply-cmvn  --utt2spk=ark:$segmented_data_dir/utt2spk scp:$segmented_data_dir/cmvn.scp scp:$segmented_data_dir/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- | transform-feats $final_mat ark:- ark:- |"
    fi
else
    final_mat="model/${model}/gmm/final.mat"
    hclg_fst="model/${model}/gmm/graph/HCLG.fst"
    words_txt="model/${model}/gmm/graph/words.txt"
    feature_transform="model/${model}/final.feature_transform"
    pdf_counts="model/${model}/ali_train_pdf.counts"
    final_nnet="model/${model}/final.nnet"
    if [[ $model == "cnn_dbn-dnn_smbr" ]]; then
        final_nnet="model/${model}/6.nnet"
        prior_counts="model/${model}/prior_counts"
    fi
fi
lang=data/lang_train_st_v1_cv1,train_nst_v1_cv1,train_mix_v1_cv1,ind_kompas_2017-2018,ind_kompas_2001-2002,ind_tempo_2001-2002
oldlang=$lang
lattices="${segmented_data_dir}/lat.1.gz"
word_boundary="$lang/phones/word_boundary.int"

# rm -R "../${segmented_data_dir}"
mkdir "../${segmented_data_dir}"

python convert_to_wav.py $filename
if [[ $extension != "wav" ]]; then
    filename="$filename_w_ext.wav"
fi
python create_wav_scp.py $filename $segmented_data_dir

cd ..

./path.sh


# wav_length="$(sox input_wav/$filename -n stat 2>&1 | grep Length |  grep -Eo '[+-]?[0-9]+([.][0-9]+)?')"
python decode/create_uniform_segments.py --overlap $overlap --window $window $segmented_data_dir || exit;
utils/fix_data_dir.sh ${segmented_data_dir} || exit;
steps/make_mfcc.sh --cmd "$train_cmd" --nj 1 $segmented_data_dir $segmented_data_dir/make_mfcc $segmented_data_dir || exit;
if [[ $model == cnn* ]]; then
    steps/make_fbank_pitch.sh --nj 1 --cmd "$train_cmd" $segmented_data_dir $segmented_data_dir/make_mfcc $segmented_data_dir || exit;
fi
steps/compute_cmvn_stats.sh $segmented_data_dir $segmented_data_dir/make_mfcc $segmented_data_dir || exit;

if [[ $model == tri* ]]; then
    gmm-latgen-faster \
        --word-symbol-table=$words_txt \
        $final_mdl \
        $hclg_fst \
        "${features}" \
        "ark:|gzip -c > $lattices" || exit;
elif [[ $model == "dbn_dnn" ]]; then
    nnet-forward \
        --no-softmax=true --prior-scale=1.0 \
        --feature-transform=$feature_transform \
        --class-frame-counts=$pdf_counts \
        --use-gpu=no \
        $final_nnet \
        "ark,s,cs:apply-cmvn  --utt2spk=ark:$segmented_data_dir/utt2spk scp:$segmented_data_dir/cmvn.scp scp:$segmented_data_dir/feats.scp ark:- | splice-feats --left-context=3 --right-context=3 ark:- ark:- | transform-feats $final_mat ark:- ark:- |" ark:- | \
    latgen-faster-mapped \
        --word-symbol-table=$words_txt \
        $final_mdl \
        $hclg_fst \
        ark:- "ark:|gzip -c > $lattices"  || exit;
elif [[ $model == "cnn_dbn-dnn_smbr" ]]; then
    nnet-forward \
        --no-softmax=true --prior-scale=1.0 \
        --feature-transform=$feature_transform \
        --class-frame-counts=$prior_counts \
        --use-gpu=no \
        $final_nnet \
        "ark,s,cs:apply-cmvn --norm-means=true --norm-vars=true --utt2spk=ark:$segmented_data_dir/utt2spk scp:$segmented_data_dir/cmvn.scp scp:$segmented_data_dir/feats.scp ark:- | add-deltas --delta-order=2 ark:- ark:- |" ark:- | \
    latgen-faster-mapped \
        --word-symbol-table=$words_txt \
        $final_mdl \
        $hclg_fst \
        ark:- "ark:|gzip -c > $lattices"  || exit;
fi

rnnlm=$4
rnnlmdir=model/rnnlm_lstm_1a
if [[ $rnnlm == '1' ]]; then
    echo '1' > $segmented_data_dir/num_jobs
    rnnlm/lmrescore_nbest.sh \
        --cmd "$decode_cmd --mem 8G" --N 20 \
        0.4 $oldlang $rnnlmdir \
        $segmented_data_dir $segmented_data_dir \
        $segmented_data_dir/rnnlm_nbest_rescore

    lattices="${segmented_data_dir}/rnnlm_nbest_rescore/lat.1.gz"
fi

output_raw="$segmented_data_dir/output_ver_${output_version}_raw.txt"
output_txt="$segmented_data_dir/output_ver_${output_version}.txt"
if [[ $output_version == "1" ]]; then
    lattice-best-path \
        --lm-scale=12 \
        --word-symbol-table=$words_txt \
        "ark:zcat $lattices |" ark,t:- |
    utils/int2sym.pl -f 2- $words_txt > $output_raw
else
    ctm="$segmented_data_dir/transcript.ctm"
    segments="$segmented_data_dir/segments"
    lattice-1best \
        --lm-scale=12 \
        "ark:zcat $lattices |" ark:- |
    lattice-align-words \
        --silence-label=1 \
        $word_boundary $final_mdl \
        ark:- ark:- |
    nbest-to-ctm ark:- - |
    utils/int2sym.pl -f 5 $words_txt > $ctm
    utils/ctm/resolve_ctm_overlaps.py \
        $segments \
        $ctm \
        $output_raw
fi

python decode/format_output.py $output_raw $output_txt $output_version
echo $output_raw $output_txt $output_version