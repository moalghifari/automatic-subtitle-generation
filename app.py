#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import load_env
from flask import Flask, jsonify, flash, request, redirect, url_for
from util import respond_data, respond_message, generate_random_string
from flask_cors import CORS
from commons import model_list, transcriptions_path

model = sys.argv[1]
output_version = sys.argv[2]
rnnlm_rescore = 0
ALLOWED_EXTENSIONS = {'.mp4', '.wav'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = os.getenv("UPLOAD_FOLDER")
CORS(app)


@app.route('/')
def info():
    return respond_message("News ASR Backend", 200)

@app.route('/news-videos', methods=['POST'])
def news_videos():
    if 'file' not in request.files:
        return respond_message("File not found", 400)
    file = request.files['file']
    if file.filename == '':
        return respond_message("File not found", 400)
    if file and allowed_file(file.filename):
        filename = generate_random_string() + os.path.splitext(file.filename)[1].lower()
        file.save(os.path.join(os.getenv("UPLOAD_FOLDER"), filename))
        decode(filename)
        transcription = get_transcriptions(filename.split('.')[0])
        return respond_data({
            "filename": file.filename.split('.')[0],
            "transcription": transcription
        })
    return respond_message("Failed to upload", 500)

def decode(filename):
    os.chdir('decode')
    os.system("./decode.sh {} {} {} {}".format(filename, model, output_version, rnnlm_rescore))

def allowed_file(filename):
    return '.' in filename and \
           os.path.splitext(filename)[1].lower() in ALLOWED_EXTENSIONS

def get_transcriptions(filename):
    os.chdir('..')
    path = "{}/{}/output_ver_{}.txt".format(transcriptions_path[model], filename, output_version)
    if not os.path.exists(path):
        return respond_message('File not found', 400)
    f = open(path, "r")
    transcription = f.read()
    return transcription

if __name__ == "__main__":
    if model not in model_list:
        print('Model is not valid')
        sys.exit()
    if int(output_version) not in [1, 2, 3]:
        print('Output version is not valid')
        sys.exit()
    app.run(port=int(os.getenv("PORT")), host=os.getenv("HOST"), threaded=True)