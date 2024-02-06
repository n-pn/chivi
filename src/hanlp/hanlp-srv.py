#!/usr/bin/python3

import os, re, gc, json

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request

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
    del mtl_task['ner/ontonotes']
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

def call_mtl_task_tokenized(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0].split('\t')], skip_tasks='tok*')

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line.split('\t'), skip_tasks='tok*')

        for key in mtl_line:
            mtl_data[key].append(mtl_line[key])

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

## start app
if __name__ == '__main__':
    # app.run(debug=True, port=5556)

    from waitress import serve
    serve(app, port=5555)
