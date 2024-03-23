require "./_srv/*"
start_server!(CV_ENV.sp_port, "mt_sp", host: "0.0.0.0")
