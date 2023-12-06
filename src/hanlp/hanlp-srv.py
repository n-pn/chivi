#!/usr/bin/python3

import os, re, gc

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request
from hanlp_trie import DictInterface, TrieDict

COMBINE_FILE = '/2tb/var.hanlp/dict-combine.tsv'
DICT_COMBINE = TrieDict()

FORCE_FILE = '/2tb/var.hanlp/dict-force.tsv'
DICT_FORCE = TrieDict()

SAVED_TERMS = set()
TASKS_CACHE = {}

def read_txt_file(inp_path, encoding='utf-8'):
    with open(inp_path, 'r', encoding='UTF-8') as inp_file:
        return inp_file.read().split('\n')

def read_combine_dict():
    lines = read_txt_file(COMBINE_FILE)

    for line in lines:
        if line.isspace() or line == '':
            continue

        SAVED_TERMS.add(line)
        DICT_COMBINE[line] = line

def read_force_dict():
    lines = read_txt_file(FORCE_FILE)

    for line in lines:
        rows = line.split('\t')

        if line.isspace() or len(rows) < 2:
            continue

        add_force_term(rows[0], rows[1])

def add_force_term(key, val):
    val_arr = val.split(' | ')

    if len(val_arr) > 1:
        val = val_arr

    DICT_FORCE[key] = val
    return val

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

    mtl_task['tok/fine'].dict_force = DICT_FORCE
    mtl_task['tok/fine'].dict_combine = DICT_COMBINE

    TASKS_CACHE[kind] = mtl_task
    return mtl_task

def add_names_to_task(mtl_line):
    msra_line = mtl_line['ner/msra']
    onto_line = set(mtl_line['ner/ontonotes'])

    for item in msra_line:
        word = item[0]

        if word in SAVED_TERMS:
            continue

        if not item in onto_line:
            continue

        SAVED_TERMS.add(word)
        DICT_COMBINE[word] = word

        with open(COMBINE_FILE, 'a', encoding='UTF-8') as out_file:
            out_file.write(word + '\n')

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

def render_con_data(con_data):
    output = ''

    for con_line in con_data:
        output += re.sub('\\n(\\s*)', ' ', str(con_line))
        output += '\n'

    return output


app = Flask(__name__)
# app.config['JSON_AS_ASCII'] = False

@app.route("/mtl_file/<kind>", methods=['GET'])
def mtl_from_file(kind):
    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)

    mtl_data = call_mtl_task_for_plaintext(load_task(kind), inp_data)
    mtl_path = inp_path.replace('.raw.txt', f'.{kind}.mtl')

    with open(mtl_path, 'w', encoding='utf-8') as mtl_file:
        mtl_file.write(mtl_data.to_json())

    con_text = render_con_data(mtl_data['con'])
    return con_text

@app.route("/mtl_text/<kind>", methods=['POST'])
def mtl_from_text(kind):
    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = call_mtl_task_for_plaintext(load_task(kind), inp_data)

    return json.dumps(mtl_data, ensure_ascii=False)

@app.route("/mtl_toks/<kind>", methods=['POST'])
def mtl_from_toks(kind):
    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = call_mtl_task_for_tokenized(load_task(kind), inp_data)

    return json.dumps(mtl_data, ensure_ascii=False)

@app.route("/force_term", methods=['GET'])
def force_term(key, val):
    with open(FORCE_FILE, 'a', encoding='UTF-8') as out_file:
        out_file.write(key + '\t' + val + '\n')

    return add_force_term(key, val)

@app.route("/combine_term", methods=['GET'])
def combine_term(word):
    with open(CONBINE_FILE, 'a', encoding='UTF-8') as out_file:
        out_file.write(word + '\n')

    SAVED_TERMS.add(word)
    DICT_COMBINE[word] = word

    return word

## start app
if __name__ == '__main__':
    read_force_dict()
    read_combine_dict()

    # app.run(debug=True, port=5555)

    from waitress import serve
    serve(app, port=5555)
