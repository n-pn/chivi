#!/usr/bin/python3

import os, gc, sys, glob
import hanlp, torch

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
os.environ["CUDA_VISIBLE_DEVICES"] = ""

TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE)

def tokenize(inp_path, label):
  out_path = inp_path.replace('.raw', '.ele_b.tok')

  if os.path.isfile(out_path):
    print(f'- <{label}> skipping [{out_path}]')
    return

  with open(inp_path, 'r', encoding='UTF-8') as inp_file:
    lines = inp_file.read().split('\n')

  out_data = TOK(lines)
  out_text = ''

  for out_line in out_data:

    out_text += '\t'.join(out_line)
    out_text += '\n'

  with open(out_path, 'w', encoding='UTF-8') as file:
    file.write(out_text)

  print(f'- <{label}> [{out_path}] parsed and saved!')
  torch.cuda.empty_cache()
  gc.collect()

dirs = glob.glob('/2tb/hanlp/data/zxcs_me/*/')
dir_count = len(dirs)

for index, dir_path in enumerate(dirs):
  files = glob.glob(f'{dir_path}*.raw')
  file_count = len(files)

  for index_2, file_path in enumerate(files):
    tokenize(file_path, f' {index + 1}/{dir_count}> - <{index_2 + 1}/{file_count}')
