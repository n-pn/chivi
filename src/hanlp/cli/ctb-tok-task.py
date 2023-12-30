#!/usr/bin/python3

import os, sys, glob, hashlib
from charset_normalizer import from_path

# os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch

TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE_CRF)
OUT = 'hanlp_out'

os.makedirs(OUT, exist_ok=True)

def read_file(file_path):
  detected = from_path(file_path).best()

  if detected:
    encoding = detected.encoding
  else:
    print(f"can't detect encoding for {file_path}, skipping!")
    return

  sha1 = hashlib.sha1()

  parts = [ [] ]
  count = 0

  with open(file_path, 'r', encoding=encoding) as file:
    for line in file:
      if line.isspace():
        continue

      line = line.strip()
      count += len(line)
      parts[-1].append(line)

      if count > 2000:
        parts.append([])
        count = 0

      sha1.update(line.encode('utf-8'))

  cksum = sha1.hexdigest()
  return cksum[0:16], parts

def tokenize(cksum, parts):
  total = len(parts)

  for index, lines in enumerate(parts):
    out_path = os.path.join(OUT, f"{cksum}-{index}.con")

    if os.path.isfile(out_path):
      print(f'- [{out_path}] ({index + 1}/{total}) parsed before, skipping!')
      continue

    out_data = TOK(lines)
    out_text = ''

    for out_line in out_data:
      out_text += '\t'.join(out_line)
      out_text += '\n'

    with open(out_path, 'w', encoding='utf-8') as file:
      file.write(out_text)

    print(f'- [{out_path}] ({index + 1}/{total}) parsed and saved!')


files = []

for i in range(1, len(sys.argv) ):
  argv = sys.argv[i]

  if argv.endswith('.txt'):
    files.append(argv)
  else:
    glob_pattern = os.path.join(argv, "**", "*.txt")
    files = files + glob.glob(glob_pattern, recursive=True)

total = len(files)

for index, fpath in enumerate(files):
  print(f"\n[{index + 1}/{total}]: {fpath}")

  cksum, parts = read_file(fpath)
  tokenize(cksum, parts)
