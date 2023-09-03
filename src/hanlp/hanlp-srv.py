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

def init_mtl(type):
    mtl = hanlp.load(type)

    del mtl['dep']
    del mtl['sdp']
    del mtl['srl']

    del mtl['ner/pku']
    del mtl['ner/ontonotes']

    del mtl['pos/pku']
    del mtl['pos/863']

    return mtl

MTL_EB = init_mtl(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
MTL_EG = init_mtl(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)

# TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE)
# POS = hanlp.load(hanlp.pretrained.pos.CTB9_POS_ELECTRA_SMALL)
# CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ERNIE_GRAM)

# NLP = hanlp.pipeline() \
#     .append(POS, input_key='tok', output_key='pos') \
#     .append(CON, input_key='tok', output_key='con') \
#     .append(merge_pos_into_con, input_key='*')

def call_mtl_task(mtl_pipeline, lines):
    doc = mtl_pipeline(lines[0])

    for line in lines[1:]:
        line_doc = mtl_pipeline(line)

        for key in doc:
            doc[key].append(line_doc[key])

    return doc

def read_txt_file(inp_path):
    with open(inp_path, 'r') as inp_file:
        return inp_file.read().split('\n')

def render_con_data(con_data):
    output = ''

    for con_line in con_data:
        output += re.sub('\\n(\\s+)', ' ', str(con_line))
        output += '\n'

    return output

def write_mtl_file(out_path, mtl_data, mtl_algo):
    with open(f'{out_path}.{mtl_algo}.mtl', 'w') as mtl_file:
        mtl_file.write(mtl_data.to_json())

def write_con_file(out_path, con_data, con_algo):
    with open(f'{out_path}.{con_algo}.con', 'w') as con_file:
        con_file.write(render_con_data(con_data))

app = Flask(__name__)

## electra base

@app.route("/hmeb/file", methods=['GET'])
def mtl_electra_base_file():
    torch.cuda.empty_cache()

    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)

    mtl_data = call_mtl_task(MTL_EB, inp_data)
    out_path = inp_path.replace('chtext', 'nlp_wn').replace('.txt', '')

    write_mtl_file(out_path, mtl_data, 'hmeb')
    write_con_file(out_path, mtl_data['con'], 'hmeb')

    return 'ok'

@app.route("/hceb/text", methods=['POST'])
def mtl_electra_base_text():
    torch.cuda.empty_cache()

    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = call_mtl_task(MTL_EB, inp_data)

    return render_con_data(mtl_data["con"])

## ernie gram

@app.route("/hmeg/file", methods=['GET'])
def mtl_ernie_gram_file():
    torch.cuda.empty_cache()

    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)

    mtl_data = call_mtl_task(MTL_EG, inp_data)
    out_path = inp_path.replace('chtext', 'nlp_wn').replace('.txt', '')

    write_mtl_file(out_path, mtl_data, 'hmeg')
    write_con_file(out_path, mtl_data['con'], 'hmeg')

    return 'ok'

@app.route("/hceg/text", methods=['POST'])
def mtl_ernie_gram_text():
    torch.cuda.empty_cache()

    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = call_mtl_task(MTL_EG, inp_data)

    return render_con_data(mtl_data["con"])

## start app

if __name__ == '__main__':
    # app.run(debug=True, port=5555)

    from waitress import serve
    serve(app, port=5555)
