#!/usr/bin/python3

import os, re

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
os.environ["CUDA_VISIBLE_DEVICES"] = ""


import hanlp
# import gc
# import torch

MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)
# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)

input = [
  "第７４章　合照⭐范凤",
]

doc = MTL(input)
con = doc["con"]
for line in con:
  print(line)
