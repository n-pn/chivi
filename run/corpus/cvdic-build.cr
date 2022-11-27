require "sqlite3"

@[Flags]
enum Mark
  Top50 # exists in 50+ books (LAC result)
  Top25 # exists in 25+ books (LAC result)

  Pku98 # exists in people daily 1998
  Pku14 # exists in people daily 2014
  X360w # from 360w most commom words

  Ud2 # universal dependency
  Ctb # chinese treebank

  Edict # exist in cc_cedict
  Vdict # exists in trich dan or lacviet
  Cdict # exists in chinese dicts
end

DIC = DB.open("sqlite3:var/cvhlp/all_terms.dic")
# DIC.exec "pragma journal_mode = WAL"
DIC.exec "begin transaction"
at_exit { DIC.exec "commit"; DIC.close }

def add_term(zh : String, mark : Mark, type : String, ptag : String)
  DIC.exec <<-SQL, zh, mark.value, ptag
    insert into terms(zh, mark, #{type}) values (?, ?, ?)
    on conflict (zh) do update set
      mark = mark | excluded.mark,
      #{type} = IIF(#{type} = '', excluded.#{type}, #{type} || char(9) || excluded.#{type})
  SQL
end

# lines = File.read_lines("var/inits/bdtmp/top50-raw.tsv")
# lines.each do |line|
#   next if line.empty?
#   word, ptag = line.split('\t', 2)

#   add_term(word, :top50, "lac", ptag.tr("¦", ":"))
# end

# lines = File.read_lines("var/inits/bdtmp/top25-all.tsv")
# lines.each do |line|
#   next if line.empty?
#   word, ptag = line.split('\t', 2)

#   add_term(word, :top25, "lac", ptag.tr("¦", ":"))
# end

# lines = File.read_lines("var/inits/cvmtl/360w.txt")
# lines.each do |line|
#   next if line.empty?
#   word, ptag = line.split('\t', 2)
#   add_term(word, :x360w, "t3m", ptag.tr("\t", ":"))
# end

DB.open("sqlite3:var/cvmtl/dicts/pku14-freq.db") do |db|
  db.query_each "select word, ptag, freq from freqs" do |rs|
    word, ptag, freq = rs.read(String, String, Int32)
    add_term(word, :pku14, "p14", "#{ptag}:#{freq}")
  end
end

DB.open("sqlite3:var/cvmtl/dicts/pku98-freq.db") do |db|
  db.query_each "select word, ptag, freq from freqs" do |rs|
    word, ptag, freq = rs.read(String, String, Int32)
    add_term(word, :pku98, "p98", "#{ptag}:#{freq}")
  end
end

DB.open("sqlite3:var/cvmtl/dicts/pmtv1-freq.db") do |db|
  db.query_each "select word, ptag, freq from freqs" do |rs|
    word, ptag, freq = rs.read(String, String, Int32)
    add_term(word, :pku98, "pmt", "#{ptag}:#{freq}")
  end
end
