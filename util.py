import os
from flask import jsonify
from string import ascii_letters
from random import choice

def generate_random_string(length=8):
    result = ""
    for _ in range(length):
        result += choice(ascii_letters)
    return result

def respond_data(data, code=200):
    return jsonify({"apiVersion": os.getenv("apiVersion"), "status": code, "data": data}), code

def respond_message(message, code=500):
    if code == 200:
        return jsonify({"apiVersion": os.getenv("apiVersion"), "status": code, "message": message}), code
    return jsonify({"apiVersion": os.getenv("apiVersion"), "error": {"code": code, "message": message}}), code
