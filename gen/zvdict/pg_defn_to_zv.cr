ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/mt_ai/data/pg_defn"
require "../../src/mt_ai/data/zv_defn"

min_mtime = 0

input = MT::PgDefn.get_all(min_mtime, &.<< "where mtime >= $1")
puts input.size

MT::ZvDefn.db.open_tx do |db|
  # db.exec "delete from zv_defn"
  input.each do |entry|
    MT::ZvDefn.new(
      d_id: entry.d_id,
      cpos: entry.cpos,
      zstr: entry.zstr,
      vstr: entry.vstr,
      attr: entry.attr,
      flags: entry.plock.to_i,
      mtime: entry.mtime,
      uname: entry.uname,
    ).insert!(db: db)
  end
end
