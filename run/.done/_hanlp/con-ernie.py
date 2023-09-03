#!/usr/bin/python3
import os, sys, glob
import json
import hanlp
# import gc
# import torch

TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE_CRF)
CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ERNIE_GRAM)

raw = [
"“哼，雕虫小技故弄玄虚。”宁擒水四下扫视，道袍一拂间，屋内烛火便灭了大半，他沉声道：“长久，小龄，随我降魔。”"
]

tok = TOK(raw)
con = CON(tok)

for line in con:
  print(line)
