# Indonesian Speech Recognition

## Introduction
An automatic subtitle generation system for Indonesian news broadcast videos using Automatic Speech Recognition (ASR) technology. The ASR is consist of acoustic model and language model which trained using Kaldi and SRILM tools. The backend service made in Flask framework, while the web interface is built with the React.js library. ([moalghifari/automatic-subtitle-generation-client](https://github.com/moalghifari/automatic-subtitle-generation-client)).

The recordings of Kompas TV news broadcasts were manually annotated using Audacity to create the speech corpus. A text corpus which was collected by ILPS was used to build a dictionary and a n-gram language model. The speech corpora and text corpora are not available in this repo. Please contact mo.alghifari@gmail.com for corpora request.

## Requirements
- python2.7.13
- GPU + CUDA
- Kaldi

## Installation
The acoustic model and the language model must both be trained in order to build an ASR. Here are the steps:

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
Here are the steps to run the backend service. To run the web interface check this repositories [moalghifari/automatic-subtitle-generation-client](https://github.com/moalghifari/automatic-subtitle-generation-client).
```
cd local
```
```
./prepare_asr.sh
```
```
cd ..
```
```
virtualenv -p /usr/bin/python2.7 venv
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
- tri_sat_fmllr
- dbn_dnn
- cnn_dbn-dnn_smbr

--output_version: subtitles style
- 1 (split per 25 s)
- 2 (split per word)
- 3 (split per silence)

## Screenshots
![upload_video](https://user-images.githubusercontent.com/32153658/228688628-5ceaaaa0-5580-40f4-a21c-e2eadd626925.gif)
![download_subtitles](https://user-images.githubusercontent.com/32153658/228688674-b41f57b8-7746-4147-98c7-06a8344652db.gif)

## Video
Youtube: https://www.youtube.com/watch?v=MJuHyfi0iNE
