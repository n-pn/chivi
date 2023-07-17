#!/usr/bin/python3
import hanlp

CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ERNIE_GRAM)

tree = CON(["家乐福", "或", "大润发", "的", "大卖场"])

print(tree)
