#!/usr/bin/python3
import os, sys, glob
from LAC import LAC

DIR = "var/inits/bdlac"
lac = LAC(mode='lac')

def parse_book(folder_path):
  path = os.path.join(DIR, folder_path, "*.txt")
  print(path)

  files = glob.glob(path)
  count = len(files)

  for inp_path in files:
    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    out_path = inp_path.replace('.txt', '.lac')
    out_file = open(out_path, 'w')

    result = lac.run(lines)

    for res_line in result:
      raws = res_line[0]
      tags = res_line[1]

      for idx, raw in enumerate(raws):
        out_file.write('\t')
        out_file.write(raw.replace('\t', ' '))
        out_file.write('‖')
        out_file.write(tags[idx])

      out_file.write("\n")

    out_file.close()
    os.remove(inp_path)

folder_path = sys.argv[1]

if folder_path:
  parse_book(folder_path)
