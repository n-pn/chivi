#!/usr/bin/python3
import os, sys, glob, json, hanlp, gc, torch

MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH) # 世界最大中文语料库

def write_file(lines, out_path):
  out_file = open(out_path, 'w')

  for line in lines:
    for i, token in enumerate(line):
      if i > 0:
        out_file.write('\t')

      if type(token) == tuple:
        for j, part in enumerate(token):
          if j > 0:
            out_file.write('‖')

          out_file.write(str(part))

      if type(token) != str:
        out_file.write(json.dumps(token))
      else:
        out_file.write(token)

    out_file.write('\n')

  out_file.close()

def ran_mtl(lines, out_path):

count = 0

def tokenize(inp_dir_path, ext = '.msr.tsv'):
  global count

  out_dir_path = inp_dir_path.replace('inp/', 'tok/')
  os.makedirs(out_dir_path, exist_ok=True)

  inp_paths = glob.glob(os.path.join(inp_dir_path, '*.txt'))
  # count = len(files)

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

    result = MTL(lines)

    write_file(result["tok/fine"], out_path.replace('.txt', '.fine.tok'))
    write_file(result["tok/coarse"], out_path.replace('.txt', '.coarse.tok'))
    write_file(result["pos/ctb"], out_path.replace('.txt', '.ctb.pos'))
    write_file(result["pos/pku"], out_path.replace('.txt', '.pku.pos'))
    write_file(result["pos/863"], out_path.replace('.txt', '.863.pos'))
    write_file(result["ner/msra"], out_path.replace('.txt', '.msra.ner'))
    write_file(result["ner/pku"], out_path.replace('.txt', '.pku.ner'))
    write_file(result["ner/ontonotes"], out_path.replace('.txt', '.ontonotes.ner'))
    write_file(result["srl"], out_path.replace('.txt', '.srl'))
    write_file(result["dep"], out_path.replace('.txt', '.dep'))
    write_file(result["sdp"], out_path.replace('.txt', '.sdp'))
    write_file(result["con"], out_path.replace('.txt', '.con'))


folders = glob.glob(os.path.join("var/inits/hanlp/inp/zxcs_me/*"))

for folder in folders:
  print(folder)
  tokenize(folder)
