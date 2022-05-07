#!/usr/bin/python3
import os, sys, glob, pkuseg

DIR = "_db/vpinit/pkuseg"

def tag_book(sname, snvid, nthread = 1):
  nvdir = os.path.join(DIR, sname, snvid)
  files = glob.glob(os.path.join(nvdir, "*.txt"))

  count = len(files)
  index = 0
  label = "- [" + sname + "/" + snvid + "] <{}/" + str(count) + "> {},"

  for inp_file in files:
    out_file = inp_file.replace('.txt', '.dat')

    fname = os.path.basename(inp_file)
    index += 1
    pkuseg.test(
      inp_file,
      out_file,
      postag = True,
      nthread = nthread,
      label = label.format(index, os.path.basename(inp_file))
    )

    os.remove(inp_file)

asize = len(sys.argv)
sname = sys.argv[1] if asize > 1 else None
snvid = sys.argv[2] if asize > 2 else None
nthread = int(sys.argv[3]) if asize > 3 else 1

if sname and snvid:
  tag_book(sname, snvid, nthread)
