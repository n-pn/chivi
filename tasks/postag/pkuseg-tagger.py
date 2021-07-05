#!/usr/bin/python3
import os
import sys
import zipfile
import pkuseg

INP_DIR = "_db/chseed"
OUT_DIR = "_db/vpinit/pkuseg"

def tag_zip(zip_file, out_dir, pick_mode = 0, skip_existing = True):
    print('\nInput: {}'.format(zip_file))

    with zipfile.ZipFile(zip_file, 'r') as zip_data:
        idx = 0
        for file in zip_data.namelist():
            idx = idx + 1

            if not should_tag(idx, pick_mode):
                continue

            txt_file = os.path.join(out_dir, file)
            out_file = os.path.join(out_dir, file.replace('.txt', '.dat'))

            if skip_existing and os.path.isfile(out_file):
                continue

            zip_data.extract(file, out_dir)
            print('\nTagging [{}] (#{})'.format(txt_file, idx))
            pkuseg.test(txt_file, out_file, postag=True, nthread=20)
            os.remove(txt_file)


def should_tag(idx, pick_mode = 0):
    if pick_mode == 2:
        return True

    if idx % 10 == 1:
        return True

    return pick_mode == 1 and idx < 50


def tag_book(sname, snvid):
    inp_dir = os.path.join(INP_DIR, sname, snvid)
    out_dir = os.path.join(OUT_DIR, sname, snvid)
    os.makedirs(out_dir, exist_ok = True)

    # pick_modes:
    # - 0: only postag every 10th chaps
    # - 1: postag every 10th chaps plus first 50 chaps
    # - 2: postag all entries inside the archive

    pick_mode = 1
    for file in os.listdir(inp_dir):
        if file.endswith(".zip"):
            zip_file = os.path.join(inp_dir, file)
            tag_zip(zip_file, out_dir, pick_mode, skip_existing = True)
            pick_mode = 0


def tag_seed(sname):
    seed_dir = os.path.join(INP_DIR, sname)

    dirs = os.listdir(seed_dir)
    dirs.sort(key = int)

    for snvid in dirs:
        if os.path.isdir(os.path.join(seed_dir, snvid)):
            tag_book(sname, snvid)

if __name__ == "__main__":
    sname = sys.argv[1] or "zxcs_me"
    tag_seed(sname)
