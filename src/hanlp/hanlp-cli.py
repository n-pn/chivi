#!/usr/bin/python3

import os, re, gc, glob

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request

from hanlp_trie import DictInterface, TrieDict

DICT_FORCE = TrieDict()
DICT_COMBINE = TrieDict()

SAVED_TERM = set()
TASK_CACHE = {}

def load_task(kind):
    if kind in TASK_CACHE:
        return TASK_CACHE[kind]

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

    mtl_task['tok/fine'].dict_force = DICT_FORCE
    mtl_task['tok/fine'].dict_combine = DICT_COMBINE

    TASK_CACHE[kind] = mtl_task
    return mtl_task

def add_names_to_task(tok_task, mtl_line):
    msra_line = mtl_line['ner/msra']
    onto_line = set(mtl_line['ner/ontonotes'])


    for item in msra_line:
        word = item[0]

        if word in SAVED_TERM:
            continue

        if not item in onto_line:
            continue

        tok_task.dict_combine[word] = word
        SAVED_TERM.add(word)
def call_mtl_task(mtl_task, inp_lines):
    tok_task = mtl_task['tok/fine']
    mtl_data = mtl_task([inp_lines[0]])

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line)

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

        add_names_to_task(tok_task, mtl_line)

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

def render_con_data(con_data):
    output = ''

    for con_line in con_data:
        output += re.sub('\\n(\\s*)', ' ', str(con_line))
        output += '\n'

    return output


def read_txt_file(inp_path):
    with open(inp_path, 'r') as inp_file:
        return inp_file.read().split('\n')

def analyze_file(mtl_task, inp_path):
    inp_data = read_txt_file(inp_path)

    mtl_data = call_mtl_task(mtl_task, inp_data)
    con_text = render_con_data(mtl_data["con"])

    con_path = inp_path.replace('.txt', '.mtl_3.con')
    mtl_path = inp_path.replace('.txt', '.mtl_3.mtl')

    with open(mtl_path, 'w', encoding='utf-8') as mtl_file:
        mtl_file.write(mtl_data.to_json())

    with open(con_path, 'w', encoding='utf-8') as con_file:
        for con_line in mtl_data["con"]:
            con_file.write(re.sub('\\n(\\s*)', ' ', str(con_line)))
            con_file.write('\n')

mtl_task = load_task('mtl_3')

files = glob.glob("var/texts/up@Nipin/1303/*.raw.txt")

for file in files:
  print(file)
  analyze_file(mtl_task, file)
