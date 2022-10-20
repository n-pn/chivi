#!/usr/bin/python3
import os, sys, glob
import hanlp
import gc
import torch

TOK = hanlp.load(hanlp.pretrained.ner.MSRA_NER_ALBERT_BASE_ZH) # 世界最大中文语料库

count = 0

def run_ner(inp_dir_path, ext = '.albert.tsv'):
  global count

  out_dir_path = inp_dir_path.replace('inp/', 'ner/')
  os.makedirs(out_dir_path, exist_ok = True)

  inp_paths = glob.glob(inp_dir_path + '/*.txt')

  for inp_path in inp_paths:
    count += 1
    out_path = inp_path.replace('inp/', 'ner/').replace('.txt', ext)

    # if os.path.isfile(out_path):
    #   print('- Parsed, skipping!')
    #   continue

    print(f'- {count}: {inp_path}')

    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    gc.collect()
    torch.cuda.empty_cache()
    out_file = open(out_path, 'w')

    for line in lines:
      result = TOK(line)

      for tup in result:
        out_file.write('\t'.join(map(str, tup)))
        out_file.write('\n')

    out_file.close()

source = "var/inits/hanlp/inp/zxcs_me/"
folders = glob.glob(source + "*/")

for folder in folders:
  print(folder)
  run_ner(folder)
