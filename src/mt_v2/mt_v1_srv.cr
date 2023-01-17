require "./server/*"
require "../server"

start_server!(CV::Config.m2_port, "mt_v2")
