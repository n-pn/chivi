DIC = DB.open("sqlite3:var/dicts/hints/all_terms.dic")
DIC.exec "begin transaction"
at_exit { DIC.exec "commit"; DIC.close }
