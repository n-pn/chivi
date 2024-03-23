#!/usr/bin/python3

import os, re, gc, json

# os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request
# from hanlp_trie import DictInterface, TrieDict

# COMBINE_FILE = '/2tb/var.hanlp/dict-combine.tsv'
# DICT_COMBINE = TrieDict()

# FORCE_FILE = '/2tb/var.hanlp/dict-force.tsv'
# DICT_FORCE = TrieDict()

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
    del mtl_task['tok/coarse']

    TASKS_CACHE[kind] = mtl_task
    return mtl_task

# def add_names_to_task(mtl_line):
#     msra_line = mtl_line['ner/msra']

#     for item in msra_line:
#         word = item[0]
#         entm = item[1]

#         if not entm in KEEP_ENTITY:
#             continue

#         if word in SAVED_TERMS:
#             continue

#         SAVED_TERMS.add(word)
#         DICT_COMBINE[word] = word

#         with open(COMBINE_FILE, 'a', encoding='UTF-8') as out_file:
#             out_file.write(word + '\n')

def call_mtl_task(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0]])

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line)

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

        # add_names_to_task(mtl_line)

    torch.cuda.empty_cache()
    gc.collect()

    return mtl_data

def call_mtl_task_tokenized(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0].split('\t')], skip_tasks='tok*')

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line.split('\t'), skip_tasks='tok*')

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

        # add_names_to_task(mtl_line)

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

# def add_force_term(key, val):
#     val_arr = val.split('|')

#     if len(val_arr) > 1:
#         val = val_arr

#     DICT_FORCE[key] = val
#     return val

# @app.route("/force_term", methods=['GET'])
# def force_term():
#     zstr = request.args.get('zstr')
#     wseg = request.args.get('wseg')

#     with open(FORCE_FILE, 'a', encoding='UTF-8') as out_file:
#         out_file.write(zstr + '\t' + wseg + '\n')

#     return add_force_term(zstr, wseg)

# @app.route("/combine_term", methods=['GET'])
# def combine_term():
#     zstr = request.args.get('zstr')

#     with open(COMBINE_FILE, 'a', encoding='UTF-8') as out_file:
#         out_file.write(zstr + '\n')

#     SAVED_TERMS.add(zstr)
#     DICT_COMBINE[zstr] = zstr

#     return zstr

# @app.route("/remove_term", methods=['GET'])
# def remove_term():
#     zstr = request.args.get('zstr')

#     DICT_FORCE[zstr] = None
#     DICT_COMBINE[zstr] = None

#     return zstr

# def read_txt_file(inp_path, encoding='UTF-8'):
#     with open(inp_path, 'r', encoding=encoding) as inp_file:
#         return inp_file.read().split('\n')

# def read_combine_dict():
#     lines = read_txt_file(COMBINE_FILE)

#     for line in lines:
#         if line.isspace() or line == '':
#             continue

#         SAVED_TERMS.add(line)
#         DICT_COMBINE[line] = line

# def read_force_dict():
#     lines = read_txt_file(FORCE_FILE)

#     for line in lines:
#         rows = line.split('\t')

#         if line.isspace() or len(rows) < 2:
#             continue

#         add_force_term(rows[0], rows[1])

## start app
if __name__ == '__main__':
    # read_force_dict()
    # read_combine_dict()

    # app.run(debug=True, port=5556)

    from waitress import serve
    serve(app, port=5555)
