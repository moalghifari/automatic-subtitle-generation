import os

nonsil = open("nonsilence_phones.txt", "r")
lines = nonsil.readlines()
nonsil.close()

if lines[0] == '\n':
    del lines[0]

new_nonsil = open("nonsilence_phones.txt", "w+")
for line in lines:
    new_nonsil.write(line)
new_nonsil.close()