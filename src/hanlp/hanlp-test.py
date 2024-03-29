#!/usr/bin/python3

import os, re, gc
import json

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from hanlp_trie import DictInterface, TrieDict

SAVED_TERMS = set()
TASKS_CACHE = {}

def load_task(kind):
    if kind in TASKS_CACHE:
        return TASKS_CACHE[kind]

    if kind == 'mtl_1':
        mtl_task = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)
    elif kind == 'mtl_2':
        mtl_task = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
    elif kind == 'mtl_3':
        mtl_task = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)
    else:
        raise 'Unsupported type!'

    del mtl_task['dep']
    del mtl_task['sdp']
    del mtl_task['srl']
    del mtl_task['ner/pku']
    del mtl_task['pos/pku']
    del mtl_task['pos/863']
    del mtl_task['tok/coarse']

    TASKS_CACHE[kind] = mtl_task
    return mtl_task

def call_mtl_task(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0]])

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line)

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

def call_mtl_task_for_plaintext(mtl_task, inp_lines):
    mtl_data = [mtl_task(x) for x in inp_lines]

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

def call_mtl_task_for_tokenized(mtl_task, inp_lines):
    mtl_data = [mtl_task(x.split('\t'), skip_tasks='tok*') for x in inp_lines]

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

if __name__ == '__main__':
    test = ["第一章和美少女们迷失废村", "“所以，我们真的出不去了吗．．．．．．”"]
    data = call_mtl_task(load_task('mtl_2'), test)
    print(data.to_json)
