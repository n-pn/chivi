#!/usr/bin/python3

import os, re, hanlp, gc, torch
from flask import Flask, request

def read_file(inp_path):
    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()

    inp_file.close()
    return lines

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

TOK = hanlp.load(hanlp.pretrained.tok.COARSE_ELECTRA_SMALL_ZH)
# POS = hanlp.load(hanlp.pretrained.pos.CTB9_POS_ELECTRA_SMALL)
# CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_ELECTRA_SMALL)

# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)

app = Flask(__name__)

@app.route("/con/rand", methods=['POST'])
def con_rand():
    inp_data = request.get_data(as_text=True).split('\n')

    mtl_data = MTL(inp_data)
    con_data = mtl_data["con"]

    return '\n'.join([str(line) for line in con_data])

@app.route("/mtl/file", methods=['GET'])
def mtl_file():
    inp_path = request.args.get('file', '')
    inp_data = read_file(inp_path)

    out_path = inp_path.replace('.txt', '.mtl')
    out_file = open(out_path, 'w')

    mtl_data = MTL(inp_data)
    out_file.write(mtl_data.to_json())

    out_file.close()
    return 'ok'

@app.route("/con/file", methods=['GET'])
def con_file():
    inp_path = request.args.get('file', '')
    inp_data = read_file(inp_path)

    out_path = inp_path.replace('.txt', '.con')
    out_file = open(out_path, 'w')

    mtl_data = MTL(inp_data)
    print(mtl_data["pos/ctb"])
    print(mtl_data["ner"])
    print(mtl_data["slr"])

    con_data = mtl_data["con"]

    for line in con_data:
        out_file.write(re.sub('\\n(\\s+)', ' ', str(line)))
        out_file.write('\n')

    out_file.close()
    return 'ok'

@app.route("/tok/file", methods=['GET'])
def tok_file():
    inp_path = request.args.get('file', '')
    inp_data = read_file(inp_path)

    out_path = inp_path.replace('.txt', '.tok')
    out_file = open(out_path, 'w')

    tok_data = TOK(inp_data)

    for line in tok_data:
        out_file.write('\t'.join(line))
        out_file.write('\n')

    out_file.close()
    return 'ok'

if __name__ == '__main__':
    # app.run(debug=True, port=5555)

    from waitress import serve
    serve(app, port=5555)
