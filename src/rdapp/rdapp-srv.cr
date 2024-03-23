require "./_srv/*"

start_server!(CV_ENV.rd_port, "rd-app", "0.0.0.0")
