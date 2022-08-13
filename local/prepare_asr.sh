cd ..

mkdir model model/tri_delta model/tri_sat_fmllr model/dbn_dnn model/cnn_dbn-dnn_smbr
mkdir transcriptions transcriptions/tri_delta transcriptions/tri_sat_fmllr transcriptions/dbn_dnn transcriptions/cnn_dbn-dnn_smbr

rm -R model/tri_delta
mkdir -p model/tri_delta/graph
cp exp/tri1/final.mdl model/tri_delta/final.mdl
cp exp/tri1/graph_tgpr/HCLG.fst model/tri_delta/graph/HCLG.fst
cp exp/tri1/graph_tgpr/words.txt model/tri_delta/graph/words.txt

rm -R model/tri_sat_fmllr
mkdir -p model/tri_sat_fmllr/graph
cp exp/tri3/final.mdl model/tri_sat_fmllr/final.mdl
cp exp/tri3/final.mat model/tri_sat_fmllr/final.mat
cp exp/tri3/graph_tgpr/HCLG.fst model/tri_sat_fmllr/graph/HCLG.fst
cp exp/tri3/graph_tgpr/words.txt model/tri_sat_fmllr/graph/words.txt

rm -R model/dbn_dnn
mkdir -p model/dbn_dnn
cp exp/dnn4_pretrain-dbn_dnn/final.mdl model/dbn_dnn/final.mdl
cp exp/dnn4_pretrain-dbn_dnn/final.feature_transform model/dbn_dnn/final.feature_transform
cp exp/dnn4_pretrain-dbn_dnn/ali_train_pdf.counts model/dbn_dnn/ali_train_pdf.counts
cp exp/dnn4_pretrain-dbn_dnn/final.nnet model/dbn_dnn/final.nnet
cp -R model/tri_sat_fmllr model/dbn_dnn/gmm

rm -R model/cnn_dbn-dnn_smbr
mkdir -p model/cnn_dbn-dnn_smbr
cp exp/cnn4c_pretrain-dbn_dnn_smbr/final.mdl model/cnn_dbn-dnn_smbr/final.mdl
cp exp/cnn4c_pretrain-dbn_dnn_smbr/final.feature_transform model/cnn_dbn-dnn_smbr/final.feature_transform
cp exp/cnn4c_pretrain-dbn_dnn_smbr/ali_train_pdf.counts model/cnn_dbn-dnn_smbr/ali_train_pdf.counts
cp exp/cnn4c_pretrain-dbn_dnn_smbr/prior_counts model/cnn_dbn-dnn_smbr/prior_counts
cp exp/cnn4c_pretrain-dbn_dnn_smbr/6.nnet model/cnn_dbn-dnn_smbr/6.nnet
cp -R model/tri_sat_fmllr model/cnn_dbn-dnn_smbr/gmm

# cp -R exp/rnnlm_lstm_1a model/