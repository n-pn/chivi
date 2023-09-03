#!/usr/bin/python3

import hanlp, timeit
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

TOK = hanlp.load(hanlp.pretrained.tok.CTB9_TOK_ELECTRA_BASE_CRF)
POS = hanlp.load(hanlp.pretrained.pos.CTB9_POS_ELECTRA_SMALL)
CON = hanlp.load(hanlp.pretrained.constituency.CTB9_CON_FULL_TAG_ELECTRA_SMALL)

NLP = hanlp.pipeline() \
    .append(POS, input_key='tok', output_key='pos') \
    .append(CON, input_key='tok', output_key='con') \
    .append(merge_pos_into_con, input_key='*')

def read_txt_file(inp_path):
    with open(inp_path, 'r') as inp_file:
        return inp_file.read().split('\n')

raw = read_txt_file("/2tb/tmp.chivi/texts/1-f3mh03-1.txt")
start = timeit.timeit()

doc = NLP(tok=[TOK(raw[0])])
print(doc)

for line in raw[1:]:
    mtl = NLP(tok=TOK(line))

    for key in mtl:
        doc[key].append(mtl[key])

doc = NLP(tok=TOK(raw))
print(doc)

end = timeit.timeit()
print(end - start)
