#!/usr/bin/python3
import os, sys, glob
import json
import hanlp
# import gc
# import torch

MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)
# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)

doc = MTL(["家乐福或大润发的大卖场", "很多医学领域、制药领域的专家"])
con = doc["con"]
for line in con:
  print(line)
