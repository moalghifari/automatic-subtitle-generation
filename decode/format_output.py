#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from time import strftime
from time import gmtime
from datetime import datetime, timedelta


def convert_milseconds_to_formatted_time(milliseconds):
    time = datetime(2021, 1, 1) + timedelta(milliseconds=int(milliseconds))
    return time.strftime("%H:%M:%S,%f")[:-3]

def write_to_srt(count, start_time, uttrs, uttr_id_parts):
    end_time = float(uttr_id_parts[-2]) + (float(parts[2]) * 1000) + (float(parts[3]) * 1000)
    start_time = convert_milseconds_to_formatted_time(start_time)
    end_time = convert_milseconds_to_formatted_time(end_time)
    fout.write('{}\n{} --> {}\n{}\n\n'.format(count, start_time, end_time, uttrs.rstrip("\n")))
    

file_in_path = sys.argv[1]
file_out_path = sys.argv[2]
version = sys.argv[3]

fin = open("{}".format(file_in_path), "r")
fin_list = fin.readlines()
fout = open("{}".format(file_out_path), "w")

if int(version) == 1:
    for i in range(0,len(fin_list)):
        parts = fin_list[i].split(' ', 1)
        uttr_id_parts = parts[0].split('-') 
        uttr = parts[1]
        start_time = convert_milseconds_to_formatted_time(uttr_id_parts[-2])
        end_time = convert_milseconds_to_formatted_time(uttr_id_parts[-1])
        fout.write('{}\n{} --> {}\n{}\n\n'.format(i+1, start_time, end_time, uttr.rstrip("\n")))

elif int(version) == 2:
    count = 1
    for i in range(0,len(fin_list)):
        parts = fin_list[i].split(' ')
        uttr_id_parts = parts[0].split('-') 
        uttr = parts[4]
        if uttr.rstrip("\n") == '!SIL':
            continue
        write_to_srt(count, float(uttr_id_parts[-2]) + (float(parts[2]) * 1000), uttr, uttr_id_parts)
        count = count + 1

elif int(version) == 3:
    count = 1
    i = 0
    uttrs = ''
    start_time = 0
    end_time = 0
    is_finished = False
    while i < len(fin_list):
        parts = fin_list[i].split(' ')
        uttr = parts[4]
        if uttr.rstrip("\n") == '!SIL':
            if i > 0:
                parts = fin_list[i-1].split(' ')
                write_to_srt(count, start_time, uttrs, parts[0].split('-'))
                count = count + 1
            if i <= len(fin_list) - 2:
                uttrs = ''
                while fin_list[i].split(' ')[4].rstrip("\n") == '!SIL' and i <= len(fin_list) - 2:
                    i = i + 1
                if i > len(fin_list) - 2 and fin_list[i].split(' ')[4].rstrip("\n") == '!SIL':
                    is_finished = True
                    i = i + 1
                    continue            
                parts = fin_list[i].split(' ')
                uttr_id_parts = parts[0].split('-')
                start_time = float(uttr_id_parts[-2]) + (float(parts[2]) * 1000)
                uttr = parts[4]
            else:
                is_finished = True
                i = i + 1
                continue
        uttrs = '{}{} '.format(uttrs, uttr.rstrip("\n"))
        i = i + 1
    if not is_finished:
        write_to_srt(count, start_time, uttrs, parts[0].split('-'))
