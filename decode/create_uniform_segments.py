#!/usr/bin/env python
# Copyright 2014  Johns Hopkins University (Authors: Daniel Povey, Vijayaditya Peddinti).  Apache 2.0.

# creates a segments file in the provided data directory
# into uniform segments with specified window and overlap

from __future__ import division
import imp, sys, argparse, os, math, subprocess

min_segment_length = 10 # in seconds
def segment(total_length, window_length, overlap = 0):
  increment = window_length - overlap
  num_windows = int(math.ceil(float(total_length)/increment))
  segments = [(x * increment, min( total_length, (x * increment) + window_length)) for x in range(0, num_windows)]
  if segments[-1][1] - segments[-1][0] < min_segment_length:
    segments[-2] = (segments[-2][0], segments[-1][1])
    segments.pop()
  return segments

def get_wave_segments(wav_command, window_length, overlap):
  raw_output = subprocess.check_output("sox {} -n stat 2>&1 | grep Length ".format(wav_command), shell = True)
  print(raw_output)
  parts = raw_output.split(":")
  if parts[0].strip() != "Length (seconds)":
    raise Exception("Failed while processing file ", wav_command)
  total_length = float(parts[1])
  segments = [(0.0, total_length)]
  if total_length > 30:
    segments = segment(total_length, window_length, overlap)
  return segments

def prepare_segments_file(kaldi_data_dir, window_length, overlap):
  wav_scp = [f for f in os.listdir(kaldi_data_dir) if f.endswith('wav.scp')]
  if len(wav_scp) != 1:
    raise Exception("Wav scp not found")

  filename = wav_scp[0]
  if not os.path.exists(kaldi_data_dir+'/{}'.format(filename)):
    raise Exception("Not a proper kaldi data directory")
  ids = []
  files = []
  for line in  open(kaldi_data_dir+'/{}'.format(filename)).readlines():
    parts = line.split()
    ids.append(parts[0])
    files.append(" ".join(parts[1:]))
  segments_total = []
  segments_per_recording = []
  for i in range(0, len(ids)):
    segments = get_wave_segments(files[i], window_length, overlap)
    segments_current_recording = []
    for segment in segments:
      segment_string = "{0}-{1:06}-{2:06} {0} {3} {4}".format(ids[i], int(segment[0] * 1000), int(segment[1]* 1000), segment[0], segment[1])
      segments_total.append(segment_string)
      segments_current_recording.append(segment_string.split()[0])
    segments_per_recording.append([ids[i], segments_current_recording])
  return segments_total, segments_per_recording
if __name__ == "__main__":
  usage = """ Python script to create segments file with uniform segment
  given the kaldi data directory."""
  sys.stderr.write(str(" ".join(sys.argv)))
  main_parser = argparse.ArgumentParser(usage)
  parser = argparse.ArgumentParser()
  parser.add_argument('--window-length', type = float, default = 30.0, help = 'length of the window used to cut the segment')
  parser.add_argument('--overlap', type = float, default = 5.0, help = 'overlap of neighboring windows')
  parser.add_argument('data_dir', help='directory such as data/train')

  params = parser.parse_args()

  # write the segments file
  segments_file = open(params.data_dir+"/segments", "w")
  segments, segments_per_recording = prepare_segments_file(params.data_dir, params.window_length, params.overlap)
  segments_file.write("\n".join(segments))
  segments_file.write("\n")
  segments_file.close()

  utt2spk_file = open(params.data_dir + "/utt2spk", "w")
  spk2utt_file = open(params.data_dir + "/spk2utt", "w")
  # write the utt2spk file
  # assumes the recording id is the speaker ir
  for i in range(len(segments_per_recording)):
    segments = segments_per_recording[i][1]
    recording = segments_per_recording[i][0]
    spk2utt_file.write("{0} {1}\n".format(recording, " ".join(segments)))
    for segment in segments:
      utt2spk_file.write("{0} {1}\n".format(segment, recording))

  spk2utt_file.close()
  utt2spk_file.close()

