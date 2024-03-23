require "./routes/**"

start_server!(CV_ENV.be_port, "cv-app", "0.0.0.0")
