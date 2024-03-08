require "./_srv/*"
start_server!(CV_ENV.ai_port, "mt_ai", host: "0.0.0.0")
