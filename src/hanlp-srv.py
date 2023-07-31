#!/usr/bin/python3

import os, re, hanlp, gc, torch
from flask import Flask, request

# os.environ["CUDA_VISIBLE_DEVICES"] = ""
# os.environ["PYTORCH_CUDA_ALLOC_CONF"] = "max_split_size_mb:50"

# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ERNIE_GRAM_ZH)
# MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)
MTL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)

app = Flask(__name__)

@app.route("/con/rand", methods=['POST'])
def con_rand():
    data = request.get_data(as_text=True).split('\n')
    con = MTL(data)["con"]
    return '\n'.join([str(line) for line in con])

def read_file(inp_path):
    inp_file = open(inp_path, 'r')
    lines = inp_file.read().splitlines()

    inp_file.close()
    return lines

@app.route("/con/file", methods=['GET'])
def con_file():
    inp_path = request.args.get('file', '')
    inp_data = read_file(inp_path)

    out_path = inp_path.replace('.txt', '.con')
    out_file = open(out_path, 'w')

    con_data = MTL(inp_data)["con"]

    for line in con_data:
        out_file.write(re.sub('\\n(\\s+)', ' ', str(line)))
        out_file.write('\n')

    out_file.close()
    return 'ok'

if __name__ == '__main__':
    app.run(debug=True, port=5555)

    # from waitress import serve
    # serve(app, port=5555)
