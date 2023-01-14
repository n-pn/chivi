require "./server/*"
require "../server"

start_server!(CV::Config.ys_port, "ysapp")
