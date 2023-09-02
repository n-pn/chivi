#!/usr/bin/python3

import os, re

os.environ["HANLP_HOME"] = "/2tb/var.hanlp/.hanlp"
# os.environ["CUDA_VISIBLE_DEVICES"] = ""

import hanlp, torch
from flask import Flask, request

MTL_ELECTRA_BASE = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_BASE_ZH)

def read_txt_file(inp_path):
    with inp_path(inp_path, 'r') as inp_file:
        return inp_file.read().splitlines()

def render_con_data(con_data):
    output = ''

    for con_line in con_data:
        output += re.sub('\\n(\\s+)', ' ', str(con_line))
        output += '\n'

    return output

def write_mtl_file(out_path, mtl_data, mtl_algo):
    with open(out_path + mtl_algo + '.mtl', 'w') as mtl_file:
        mtl_file.write(mtl_data.to_json())

def write_con_file(out_path, con_data, con_algo):
    with open(out_path + con_algo + '.con', 'w') as con_file:
        for con_line in con_data:
            con_file.write(re.sub('\\n(\\s+)', ' ', str(con_line)))
            con_file.write('\n')

app = Flask(__name__)

@app.route("/meb/file", methods=['GET'])
def mtl_electra_base_file():
    torch.cuda.empty_cache()

    inp_path = request.args.get('file', '')
    inp_data = read_txt_file(inp_path)

    mtl_data = MTL_ELECTRA_BASE([inp_data[0]])

    for inp_line in inp_data[1:]:
        mtl_line = MTL_ELECTRA_BASE(inp_line)

        for key in mtl_data:
            mtl_data[key].append(mtl_line[key])

    out_path = inp_path.replace('chtext', 'nlp_wn').replace('.txt', '')
    write_mtl_file(out_path, mtl_data, 'hmeb')
    write_con_file(out_path, mtl_data["con"], 'hmeb')

    return 'ok'


@app.route("/meb/text", methods=['POST'])
def mtl_electra_base_text():
    torch.cuda.empty_cache()

    inp_data = request.get_data(as_text=True).split('\n')
    mtl_data = MTL_ELECTRA_BASE(inp_data)

    return mtl_data

# MTL_ELECTRA_SMALL = hanlp.load(hanlp.pretrained.mtl.CLOSE_TOK_POS_NER_SRL_DEP_SDP_CON_ELECTRA_SMALL_ZH)

# @app.route("/mes/text", methods=['POST'])
# def mtl_electra_small_text():
#     torch.cuda.empty_cache()

#     inp_data = request.get_data(as_text=True).split('\n')
#     mtl_data = MTL_ELECTRA_SMALL(inp_data)

#     return mtl_data

# @app.route("/mes/file", methods=['GET'])
# def mtl_electra_small_file():
#     torch.cuda.empty_cache()

#     inp_path = request.args.get('file', '')
#     inp_data = read_txt_file(inp_path)

#     mtl_data = MTL_ELECTRA_SMALL([inp_data[0]])

#     for inp_line in inp_data[1:]:
#         # torch.cuda.empty_cache()
#         mtl_line = MTL_ELECTRA_SMALL(inp_line)

#         for key in mtl_data:
#             mtl_data[key].append(mtl_line[key])


#     write_mtl_file(inp_path, mtl_data, 'electra_small')
#     write_con_file(inp_path, mtl_data["con"], 'electra_small')

#     return 'ok'

if __name__ == '__main__':
    app.run(debug=True, port=5555)

    # from waitress import serve
    # serve(app, port=5555)
