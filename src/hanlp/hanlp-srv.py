#!/usr/bin/python3

import os, re, gc

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


KINDS = {
    hm_es: hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH,
    hm_eb: hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH,
    hm_eg: hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH,

    om_es: hanlp.pretrained.mtl.OPEN_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH,
    om_eb: hanlp.pretrained.mtl.OPEN_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH,
    om_eg: hanlp.pretrained.mtl.OPEN_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH,
}

CACHE = {}

def load_task(kind):
    if kind in CACHE:
        return CACHE[kind]

    mtl_task = hanlp.load(KINDS[kind])

    del mtl_task['dep']
    del mtl_task['sdp']
    del mtl_task['srl']

    del mtl_task['ner/pku']
    del mtl_task['ner/msra']
    del mtl_task['ner/ontonotes']

    del mtl_task['pos/pku']
    del mtl_task['pos/863']

    CACHE[kind] = mtl_task
    return mtl_task


def call_mtl_task(mtl_task, inp_lines):
    mtl_data = mtl_task([inp_lines[0]])

    for line in inp_lines[1:]:
        mtl_line = mtl_task(line)

        for key in doc:
            mtl_data[key].append(mtl_line[key])

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

app = Flask(__name__)

@app.route("/mtl_file/<kind>", methods=['GET'])
def mtl_from_file(kind):
    inp_data = read_txt_file(request.args.get('file', ''))

    mtl_data = call_mtl_task(load_task(kind), inp_data)
    con_text = render_con_data(mtl_data["con"])

    return con_text

@app.route("/mtl_text/<kind>", methods=['POST'])
def mtl_from_text():
    inp_data = request.get_data(as_text=True).split('\n')

    mtl_data = call_mtl_task(load_task(kind), inp_data)
    con_text = render_con_data(mtl_data["con"])

    return con_text

## start app

if __name__ == '__main__':
    # app.run(debug=True, port=5555)

    from waitress import serve
    serve(app, port=5555)
