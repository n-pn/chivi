#!/usr/bin/python3
import os, sys, glob
import json
import hanlp
# import gc
# import torch

MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)
# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)

# input = "“他一直很想进鬼屋参观，这是我和他约定好的，能不能帮帮忙。”少妇从背包里翻出张一百的整钞：“不会出事的。”"
input = "陈歌没去接少妇的钱，略带疑惑的问道：“为什么你们非要进鬼屋里？这孩子看着才八九岁，鬼屋里环境复杂特殊，容易对小孩子造成心理上的刺激。”"

doc = MTL([input])
con = doc["con"]
for line in con:
  print(line)
