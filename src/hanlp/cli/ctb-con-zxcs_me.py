#!/usr/bin/python3

import os, gc, sys, glob, re
import hanlp, torch

# os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ERNIE_GRAM)

def parse(inp_path, label):
  out_path = inp_path.replace('.ele_b.tok', '.ern_g.con')

  # if os.path.isfile(out_path):
  #   print(f'- <{label}> skipping [{out_path}]')
  #   return

  with open(inp_path, 'r', encoding='UTF-8') as inp_file:
    lines = inp_file.readlines()
    tdata = [line.strip().split('\t') for line in lines]

  con_data = CON(tdata)
  out_text = ''

  with open(out_path, 'w', encoding='UTF-8') as file:
    for con_line in con_data:
      file.write(re.sub('\\n(\\s*)', ' ', str(con_line)))
      file.write('\n')

  print(f'- <{label}> [{out_path}] parsed and saved!')
  torch.cuda.empty_cache()
  gc.collect()

dirs = glob.glob('/app/hanlp/data/zxcs_me/*/')
dir_count = len(dirs)

for index, dir_path in enumerate(dirs):
  files = glob.glob(f'{dir_path}*.ele_b.tok')
  file_count = len(files)

  for index_2, file_path in enumerate(files):
    try:
      parse(file_path, f' {index + 1}/{dir_count}> - <{index_2 + 1}/{file_count}')
    except Exception as e:
      print(e)
