require "../server"
require "./server/*"

start_server!(CV_ENV.sp_port, "mt_sp")
