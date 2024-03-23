require "./_srv/*"

start_server!(CV_ENV.wn_port, "wnapp", "0.0.0.0")
