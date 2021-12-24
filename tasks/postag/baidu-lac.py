#!/usr/bin/python3
import os, sys, glob
from LAC import LAC

DIR = "_db/vpinit/baidulac"
lac = LAC(mode='lac')

def parse_book(sname, snvid):
  nvdir = os.path.join(DIR, sname, snvid)
  files = glob.glob(os.path.join(nvdir, "*.txt"))

  count = len(files)
  index = 0
  label = "- [" + sname + "/" + snvid + "] <{}/" + str(count) + "> {},"

  for inp_path in files:
    index += 1

    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()
    inp_file.close()

    out_path = inp_path.replace('.txt', '.tsv')
    out_file = open(out_path, 'w')

    result = lac.run(lines)

    for res_line in result:
      raws = res_line[0]
      tags = res_line[1]

      for idx, raw in enumerate(raws):
        out_text = raw + " " + tags[idx]
        out_text = "\t" + out_text if idx > 0 else out_text
        out_file.write(out_text)

      out_file.write("\n")

    out_file.close()
    os.remove(inp_path)

sname = sys.argv[1]
snvid = sys.argv[2]

if sname and snvid:
  parse_book(sname, snvid)
