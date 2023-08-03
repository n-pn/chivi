#!/usr/bin/python3
import hanlp

# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH) # 世界最大中文语料库
MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)

# input = "“他一直很想进鬼屋参观，这是我和他约定好的，能不能帮帮忙。”少妇从背包里翻出张一百的整钞：“不会出事的。”"
source = "平安县是宁州七十二县之一，境内多是山川丘陵，人口稀少，莲花岛是平安县内唯一的一座湖岛。"
source = "莲花岛因外形酷似一朵盛开的莲花而得名，岛上种着不少莲花。"
output = MTL(source)
print(output["con"])
