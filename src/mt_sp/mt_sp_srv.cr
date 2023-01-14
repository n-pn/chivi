require "../server"
require "./server/*"

start_server!(CV::Config.ms_port, "mt_sp")
