#!/usr/bin/python3
import os, sys, datetime, rarfile

INP_RAR = "/www/chivi/xyz/seeds/zxcs.me/_rars"
files = os.listdir(INP_RAR)

def fix_mtime(file):
  rar = rarfile.RarFile(file)
  txt_file = file.replace("_rars", "texts").replace(".rar", ".txt")

  for txt in rar.infolist():
    print(txt_file, txt.mtime)
    utime = txt.mtime.timestamp()
    os.utime(txt_file, (utime, utime))
    return utime

idx_file = open("/www/chivi/xyz/seeds/zxcs.me/mftime.tsv", "w")

for file in files:
  try:
    rar_file =os.path.join(INP_RAR, file)
    rar_size = os.stat(rar_file).st_size

    if rar_size > 1000:
        mtime = fix_mtime(rar_file)

        fname = os.path.basename(file)
        snvid = os.path.splitext(fname)[0]
        idx_file.write(snvid + '\t' + str(round(mtime)) + '\n')


  except Exception as e:
    print("Oops!", e.__class__, "occurred.")

idx_file.close()
