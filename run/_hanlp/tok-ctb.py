#!/usr/bin/python3
import os, sys, glob
import hanlp
import gc
import torch

TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE_CRF)

def write_file(lines, out_path):
  out_file = open(out_path, 'w')

  for line in lines:
    for i, token in enumerate(line):
      if i > 0:
        out_file.write('\t')

      out_file.write(token)

    out_file.write('\n')

  out_file.close()

count = 0

def tokenize(inp_dir_path, ext = '.ctb-crf.tsv'):
  global count

  out_dir_path = inp_dir_path.replace('inp/', 'tok/')
  os.makedirs(out_dir_path, exist_ok=True)

  inp_paths = glob.glob(os.path.join(inp_dir_path, '*.txt'))

  for inp_path in inp_paths:
    count += 1
    out_path = inp_path.replace('inp/', 'tok/').replace('.txt', ext)

    if os.path.isfile(out_path):
      print(f'- {count}: [{inp_path}] parsed, skipping')
      continue

    print(f'- {count}: [{inp_path}] parsing')

    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    gc.collect()
    torch.cuda.empty_cache()

    try:
      result = TOK(lines)
      write_file(result, out_path)

    except:
      print(f'\033[91m {inp_path} failed!\033[0m')

folders = glob.glob(os.path.join("var/inits/hanlp/inp/zxcs_me/*"))

for folder in folders:
  print(folder)
  tokenize(folder)
