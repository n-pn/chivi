#!/usr/bin/python3
import sys
import pkuseg

argv_len = len(sys.argv)

inp_file = sys.argv[1] if argv_len > 1 else None
out_file = sys.argv[2] if argv_len > 2 else None
n_thread = sys.argv[3] if argv_len > 3 else 10

if inp_file and out_file:
  pkuseg.test(inp_file, out_file, postag = True, nthread = int(n_thread))
