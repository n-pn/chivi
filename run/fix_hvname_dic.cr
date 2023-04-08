require "sqlite3"

DB.open("sqlite3:var/dicts/v0dic/hv_name.dic?synchronous=normal") do |db|
  inp = db.query_all "select zstr, defs from terms", as: {String, String}

  db.exec "begin"

  inp.each do |zstr, defs|
    db.exec "update terms set defs = $1 where zstr = $2", defs.titleize, zstr
  end

  db.exec "commit"
end
