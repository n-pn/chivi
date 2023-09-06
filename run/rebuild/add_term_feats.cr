require "./_shared"

DIC = DB.open("sqlite3:#{MT::DbTerm.db_path("common-main")}")
at_exit { DIC.close }

# INP = DB.open("sqlite3:var/mtapp/v1dic/v1_defns.dic")
# at_exit { INP.close }

# ditrans = INP.query_all("select distinct(key) from defns where dic = -30", as: String)
# puts ditrans

# DIC.exec "begin"
# ditrans.each do |zstr|
#   DIC.exec "update defns set feat = feat || ' ' || 'vditra' where zstr = $1", zstr
# end
# DIC.exec "commit"

def cleanup_feats
  input = DIC.query_all <<-SQL, as: {String, String}
  select zstr, feat from defns where feat <> ''
SQL

  DIC.exec "begin"
  input.each do |zstr, feat|
    feat = feat.split(' ', remove_empty: true).uniq!.join(' ')
    DIC.exec "update defns set feat = $1 where zstr = $2", feat, zstr
  end
  DIC.exec "commit"
end

DIC.exec <<-SQL
  update defns set xpos = 'PU' where upos = 'w';
  SQL

cleanup_feats
