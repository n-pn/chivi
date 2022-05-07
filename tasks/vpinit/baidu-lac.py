#!/usr/bin/python3
import os, sys, glob
from LAC import LAC

DIR = "_db/vpinit/bd_lac/raw"
lac = LAC(mode='lac')

FIX = {
  'PER': 'nr',
  'ORG': 'nt',
  'LOC': 'ns',
  'TIME': 't',
  'nw': 'nx'
}

def parse_book(bname):
  nvdir = os.path.join(DIR,  bname)
  files = glob.glob(os.path.join(nvdir, "*.txt"))

  count = len(files)
  index = 0
  # label = "- [" + bname + "] <{}/" + str(count) + "> {},"

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
        if idx > 0:
          out_file.write("\t")

        out_file.write(raw.replace("\t", " ") + "¦")

        tag = tags[idx]
        out_file.write(FIX.get(tag, tag))

      out_file.write("\n")

    out_file.close()
    os.remove(inp_path)

bname = sys.argv[1]

if bname:
  parse_book(bname)