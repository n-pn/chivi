require "../server"
require "./server/*"

start_server!(CV_ENV.ms_port, "mt_sp")
