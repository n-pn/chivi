require "../server"
require "./ctrls/**"

start_server!(CV::Config.be_port, "cvapp")
