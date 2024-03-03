require "./_srv/*"

start_server!(CV_ENV.m1_port, "mt_v1", host: "0.0.0.0")
