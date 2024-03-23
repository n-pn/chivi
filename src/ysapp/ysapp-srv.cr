require "./_srv/*"

start_server!(CV_ENV.ys_port, "ysapp", "0.0.0.0")
