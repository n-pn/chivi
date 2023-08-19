#!/usr/bin/python3

import os, re, hanlp, gc, torch, json
from flask import Flask, request

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
os.environ["CUDA_VISIBLE_DEVICES"] = ""


MTL_ELECTRA_BASE = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
MTL_ELECTRA_SMALL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)

# MTL_ERNIE_GRAM = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)

def read_txt_file(path):
    file = open(path, 'r')
    lines = file.read().splitlines()

    file.close()
    return lines

def write_mtl_file(inp_path, mtl_data, mtl_algo):
    mtl_path = inp_path.replace('.txt', '.' + mtl_algo + '.mtl')
    mtl_file = open(mtl_path, 'w')

    mtl_file.write(mtl_data.to_json())
    mtl_file.close()

def write_con_file(inp_path, con_data, con_algo):
    con_path = inp_path.replace('.txt', '.con')
    con_file = open(con_path, 'a')
    line_idx = 0

    for con_line in con_data:
        con_file.write(str(line_idx))
        con_file.write('\t')
        con_file.write(con_algo)
        con_file.write('\t')
        con_file.write(re.sub('\\n(\\s+)', ' ', str(con_line)))
        con_file.write('\n')
        line_idx += 1

    con_file.close()


app = Flask(__name__)

@app.route("/mtl/electra_base/text", methods=['POST'])
def mtl_electra_base_text():
    inp_data = request.get_data(as_text=True).split('\n')

    mtl_data = MTL_ELECTRA_BASE(inp_data)
    con_data = mtl_data["con"]

    return mtl_data

# @app.route("/mtl/electra_small/text", methods=['POST'])
# def mtl_electra_small_text():
#     inp_data = request.get_data(as_text=True).split('\n')
#     mtl_data = MTL_ELECTRA_SMALL(inp_data)

#     return mtl_data

@app.route("/mtl/electra_base/file", methods=['GET'])
def mtl_electra_base_file():
    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)
    mtl_data = MTL_ELECTRA_BASE(inp_data)

    # write_mtl_file(inp_path, mtl_data, 'electra_base')
    write_con_file(inp_path, mtl_data["con"], 'electra_base')

    return 'ok'

@app.route("/mtl/electra_small/file", methods=['GET'])
def mtl_electra_small_file():
    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)
    mtl_data = MTL_ELECTRA_SMALL(inp_data)

    write_mtl_file(inp_path, mtl_data, 'electra_small')
    write_con_file(inp_path, mtl_data["con"], 'electra_small')

    return 'ok'



if __name__ == '__main__':
    app.run(debug=True, port=5555)

    # from waitress import serve
    # serve(app, port=5555)
