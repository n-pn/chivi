#!/usr/bin/python3
import os, sys, glob
import hanlp
import gc
import torch

TOK = hanlp.load(hanlp.pretrained.tok.MSR_TOK_ELECTRA_BASE_CRF) # 世界最大中文语料库

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

def tokenize(inp_dir_path, ext = '.msr.tsv'):
  global count

  out_dir_path = inp_dir_path.replace('inp/', 'tok/')
  os.makedirs(out_dir_path, exist_ok=True)

  inp_paths = glob.glob(os.path.join(inp_dir_path, '*.txt'))

  for inp_path in inp_paths:
    print('- ', count, ': ', inp_path)
    count += 1
    out_path = inp_path.replace('inp/', 'tok/').replace('.txt', ext)

    if os.path.isfile(out_path):
      print('- Parsed, skipping!')
      continue

    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    gc.collect()
    torch.cuda.empty_cache()

    result = TOK(lines)
    write_file(result, out_path)

folders = glob.glob(os.path.join("var/inits/hanlp/inp/zxcs_me/*"))

for folder in folders:
  print(folder)
  tokenize(folder)
