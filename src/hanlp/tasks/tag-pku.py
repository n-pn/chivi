#!/usr/bin/python3
import os, sys, glob
import hanlp
import gc
import torch

POS = hanlp.load(hanlp.pretrained.pos.PKU_POS_ELECTRA_SMALL) # 世界最大中文语料库

def write_file(lines, out_path):
  out_file = open(out_path, 'w')

  for line in lines:
    for i, token in enumerate(line):
      if i > 0:
        out_file.write('\t')

      out_file.write(token)

    out_file.write('\n')

count = 0

def tokenize(inp_dir_path, ext = '.pku.tsv'):
  global count

  out_dir_path = inp_dir_path.replace('tok/', 'pos/')
  os.makedirs(out_dir_path, exist_ok=True)

  inp_paths = glob.glob(os.path.join(inp_dir_path, '*.tsv'))

  for inp_path in inp_paths:
    out_path = inp_path.replace('tok/', 'pos/').replace('.tsv', ext)
    count += 1

    if os.path.isfile(out_path):
      print(f'- {count}: [{inp_path}] parsed, skipping!')
      continue

    print(f'- {count}: [{inp_path}] parsing')

    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    gc.collect()
    torch.cuda.empty_cache()

    out_file = open(out_path, 'w')

    try:
      for line in lines:
        token = line.split('\t')
        result = POS(token)
        out_file.write('\t'.join(result))

    except:
      print(f'\033[91m {inp_path} failed!\033[0m')

    out_file.close()

folders = glob.glob(os.path.join("var/inits/hanlp/tok/zxcs_me/*"))

for folder in folders:
  tokenize(folder)
