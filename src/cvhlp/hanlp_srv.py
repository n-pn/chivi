#! /usr/bin/python3

import os
import sys
import time
import hanlp

from http.server import HTTPServer, BaseHTTPRequestHandler

POS = hanlp.load(hanlp.pretrained.pos.PKU_POS_ELECTRA_SMALL)

class Server(BaseHTTPRequestHandler):
  def do_POST(self):
    content_len = int(self.headers.get('Content-Length'))
    post_body = self.rfile.read(content_len).decode('utf-8')


    if self.path == "/pos":
      self.pos_tagging(post_body)

  def pos_tagging(self, content):
    lines = []

    for line in content.split('\n'):
      lines.append(line.rstrip('\n').split('\t'))

    output = POS(lines)

    self.send_response(200)
    self.send_header("Content-type", "text/plain; charset=utf-8")
    self.end_headers()

    for entry in output:
      self.wfile.write('\t'.join(entry).encode('utf-8'))
      self.wfile.write('\n'.encode('utf-8'))


HOST_NAME = 'localhost'
PORT = 5401

if __name__ == '__main__':
  httpd = HTTPServer((HOST_NAME, PORT), Server)
  print(time.asctime(), 'Start Server - %s:%s' % (HOST_NAME, PORT))

  try:
    httpd.serve_forever()
  except KeyboardInterrupt:
    pass

  httpd.server_close()
  print(time.asctime(), 'Stop Server - %s:%s' % (HOST_NAME, PORT))
