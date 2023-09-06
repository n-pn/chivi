#!/usr/bin/python3

import os, re

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request

from hanlp_common.document import Document

def merge_pos_into_con(doc: Document):
    flat = isinstance(doc['pos'][0], str)
    if flat:
        doc = Document((k, [v]) for k, v in doc.items())
    for tree, tags in zip(doc['con'], doc['pos']):
        offset = 0
        for subtree in tree.subtrees(lambda t: t.height() == 2):
            tag = subtree.label()
            if tag == '_':
                subtree.set_label(tags[offset])
            offset += 1
    if flat:
        doc = doc.squeeze()
    return doc


TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE)
POS = hanlp.load(hanlp.pretrained.pos.CTB9_POS_ELECTRA_SMALL)
CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ERNIE_GRAM)

NLP = hanlp.pipeline() \
    .append(POS, input_key='tok', output_key='pos') \
    .append(CON, input_key='tok', output_key='con') \
    .append(merge_pos_into_con, input_key='*')

input = [
  "封不觉看了看镜子中自己的形象，此刻他成了个超高像素的三维ＣＧ人物。身上的服装变成了黑色的长袖Ｔ恤和长裤，没什么特别之处。游戏人物的脸和现实中自己的长相几乎一样，一米八不到，乱糟糟的头发，面部线条略显阴柔。"
]

print(NLP(con=CON(input)))
