#!/usr/bin/python3

import os, re, gc

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request

CACHE = {}

def load_task(kind):
    if kind in CACHE:
        return CACHE[kind]

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

    mtl_task['tok/fine'].dict_combine = {}

    CACHE[kind] = mtl_task
    return mtl_task

def add_names_to_task(tok_task, mtl_line):
    msra_line = mtl_line['ner/msra']
    onto_line = mtl_line['ner/ontonotes']

    for item in msra_line:
        if not item in onto_line:
            continue

        word = item[0]
        tok_task.dict_combine[word] = word

def call_mtl_task(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0]])
    tok_task = mtl_task['tok/fine']

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

def read_txt_file(inp_path, encoding='utf-8'):
    with open(inp_path, 'r') as inp_file:
        return inp_file.read().split('\n')

app = Flask(__name__)

@app.route("/mtl_file/<kind>", methods=['GET'])
def mtl_from_file(kind):
    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)

    mtl_data = call_mtl_task(load_task(kind), inp_data)
    mtl_path = inp_path.replace('.txt', f'.{kind}.mtl')

    with open(mtl_path, 'w', encoding='utf-8') as mtl_file:
        mtl_file.write(mtl_data.to_json())

    con_text = render_con_data(mtl_data['con'])
    return con_text

@app.route("/mtl_text/<kind>", methods=['POST'])
def mtl_from_text(kind):
    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = call_mtl_task(load_task(kind), inp_data)

    con_text = render_con_data(mtl_data['con'])
    return con_text

## start app

if __name__ == '__main__':
    # app.run(debug=True, port=5556)

    from waitress import serve
    serve(app, port=5555)
