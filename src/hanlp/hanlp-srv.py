#!/usr/bin/python3

import os, re, gc, json

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request
from hanlp_trie import DictInterface, TrieDict

COMBINE_FILE = '/app/hanlp/dict-combine.tsv'
DICT_COMBINE = TrieDict()

FORCE_FILE = '/app/hanlp/dict-force.tsv'
DICT_FORCE = TrieDict()

TASKS_CACHE = {}

SAVED_TERMS = set()
KEEP_ENTITY = ['PERSON', 'LOCATION', 'ORGANIZATION']

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
    del mtl_task['ner/ontonotes']
    del mtl_task['pos/pku']
    del mtl_task['pos/863']
    del mtl_task['tok/fine']

    TASKS_CACHE[kind] = mtl_task
    return mtl_task

def add_names_to_task(mtl_line):
    msra_line = mtl_line['ner/msra']

    for item in msra_line:
        word = item[0]
        entm = item[1]

        if not entm in KEEP_ENTITY:
            continue

        if word in SAVED_TERMS:
            continue

        SAVED_TERMS.add(word)
        DICT_COMBINE[word] = word

        with open(COMBINE_FILE, 'a', encoding='UTF-8') as out_file:
            out_file.write(word + '\n')

def call_mtl_task(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0]])

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line)

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

        add_names_to_task(mtl_line)

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

def call_mtl_task_tokenized(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0].split('\t')], skip_tasks='tok*')

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line.split('\t'), skip_tasks='tok*')

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

        add_names_to_task(mtl_line)

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

app = Flask(__name__)
app.json.ensure_ascii = False

@app.route("/mtl_text/<kind>", methods=['POST'])
def mtl_from_text(kind):
    inp_data = request.get_data(as_text=True).splitlines()
    mtl_data = call_mtl_task(load_task(kind), inp_data)

    return mtl_data.to_json()

@app.route("/mtl_toks/<kind>", methods=['POST'])
def mtl_from_toks(kind):
    inp_data = request.get_data(as_text=True).splitlines()
    mtl_data = call_mtl_task_tokenized(load_task(kind), inp_data)

    return mtl_data.to_json()

@app.route("/force_term", methods=['GET'])
def force_term(key, val):
    with open(FORCE_FILE, 'a', encoding='UTF-8') as out_file:
        out_file.write(key + '\t' + val + '\n')

    SAVED_TERMS.add(word)
    return key

@app.route("/combine_term", methods=['GET'])
def combine_term(word):
    with open(CONBINE_FILE, 'a', encoding='UTF-8') as out_file:
        out_file.write(word + '\n')

    SAVED_TERMS.add(word)
    DICT_COMBINE[word] = word

    return word


## start app
if __name__ == '__main__':
    # app.run(debug=True, port=5556)

    from waitress import serve
    serve(app, port=5555)
