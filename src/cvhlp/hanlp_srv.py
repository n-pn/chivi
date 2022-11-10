#! /usr/bin/python3

import os
import sys
import time
import hanlp

from http.server import HTTPServer, BaseHTTPRequestHandler

TOK = hanlp.load(hanlp.pretrained.tok.FINE_ELECTRA_SMALL_ZH)
POS = hanlp.load(hanlp.pretrained.pos.PKU_POS_ELECTRA_SMALL)

class Server(BaseHTTPRequestHandler):
  def do_POST(self):
    content_len = int(self.headers.get('Content-Length'))
    post_body = self.rfile.read(content_len).decode('utf-8')

    if self.path == "/pos":
      lines = [x.split('\t') for x in post_body.split('\n')]
      self.print_result(POS(lines))
    elif self.path == "/tok":
      lines = post_body.split('\n')
      self.print_result(TOK(lines))
    else:
      self.send_response(400)
      self.send_header("Content-type", "text/plain; charset=utf-8")
      self.end_headers()
      self.wfile.write('Unsupported path'.encode('utf-8'))

  def parse_input(self, post_body):


    return lines

  def print_result(self, output):
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
