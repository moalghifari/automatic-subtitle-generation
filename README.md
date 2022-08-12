# Indonesian Speech Recognition

## Introduction
The goal of this project is to develop an automatic subtitle generation system for Indonesian news broadcast videos. Using the Kaldi and SRILM language modeling tools, the acoustic model and language model are trained. React.js is used to build the web interface. ([moalghifari/news-asr-frontend](https://github.com/moalghifari/news-asr-frontend)).

The recordings of Kompas TV news broadcasts were manually annotated using Audacity to create the speech corpus. A text corpus which was collected by ILPS was used to build a dictionary and a n-gram language model.

## Requirements
- python2.7.13
- NVIDIA + CUDA
- kaldi

## Installation
The acoustic model and the linguistic model must both be trained in order to build an ASR. Here are the steps:

### Language Model Training
The language model is trained using trigram (3-gram)
```
source path.sh
```
```
cd local/ngramlm
```
```
./create_lm.sh <text corpus dirs that used to build language model>
./create_lm.sh train_st,train_nst,train_mix,ind_kompas_2017-2018,ind_kompas_2001-2002,ind_tempo_2001-2002
```

### Accoustic Model Training
Acoustic models are trained using GMM, DNN, and CNN techniques
```
source path.sh
```
```
./run.sh <train_folder> <test_folder> <lm> 
./run.sh train_st,train_nst,train_mix test_st,test_mix lang_train_st,train_nst,train_mix,ind_kompas_2017-2018,ind_kompas_2001-2002,ind_tempo_2001-2002
```

## Usage
Here are the steps to run the backend service. To run the web interface check this repositories [moalghifari/news-asr-frontend](https://github.com/moalghifari/news-asr-frontend).
```
virtualenv venv
```
```
. venv/bin/activate
```
```
pip install -r requirements.txt
```
```
source path.sh
```
```
python app.py <model> <output_version>
```
--model: the accoustic model
- tri_delta
- tri_lda_mllt_sat
- dbn_dnn
- cnn_dbn-dnn_smbr

--output_version: subtitles style
- 1 (split per 25 s)
- 2 (split per word)
- 3 (split per silence)
