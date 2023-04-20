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

DIC = DB.open("sqlite3:var/mtdic/fixed/hints/all_terms.dic")
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

# lines = File.read_lines("var/inits/mt_v2/360w.txt")
# lines.each do |line|
#   next if line.empty?
#   word, ptag = line.split('\t', 2)
#   add_term(word, :x360w, "t3m", ptag.tr("\t", ":"))
# end

# DB.open("sqlite3:var/mt_v2/dicts/pku14-freq.db") do |db|
#   db.query_each "select word, ptag, freq from freqs" do |rs|
#     word, ptag, freq = rs.read(String, String, Int32)
#     add_term(word, :pku14, "p14", "#{ptag}:#{freq}")
#   end
# end

# DB.open("sqlite3:var/mt_v2/dicts/pku98-freq.db") do |db|
#   db.query_each "select word, ptag, freq from freqs" do |rs|
#     word, ptag, freq = rs.read(String, String, Int32)
#     add_term(word, :pku98, "p98", "#{ptag}:#{freq}")
#   end
# end

# DB.open("sqlite3:var/mt_v2/dicts/pmtv1-freq.db") do |db|
#   db.query_each "select word, ptag, freq from freqs" do |rs|
#     word, ptag, freq = rs.read(String, String, Int32)
#     add_term(word, :pku98, "pmt", "#{ptag}:#{freq}")
#   end
# end

# DB.open("sqlite3:var/mt_v2/dicts/ctbv9-freq.db") do |db|
#   db.query_each "select word, ptag, freq from freqs" do |rs|
#     word, ptag, freq = rs.read(String, String, Int32)
#     add_term(word, :ctb, "ctb", "#{ptag}:#{freq}")
#   end
# end

# DB.open("sqlite3:var/mt_v2/dicts/ud211-freq.db") do |db|
#   db.query_each "select word, ptag, freq from freqs" do |rs|
#     word, ptag, freq = rs.read(String, String, Int32)
#     add_term(word, :ud2, "ud2", "#{ptag}:#{freq}")
#   end
# end

# puts Mark::Edict.value
# puts Mark::Vdict.value
# puts Mark::Cdict.value

# require "../../src/mt_sp/engine"

# hanviet = [] of {String, Int32}

# DIC.query_each "select rowid, zh from terms where hv = ''" do |rs|
#   id = rs.read(Int32)
#   zh = rs.read(String)
#   hv = SP::MtCore.tl_sinovi(k, cap: false)
#   hanviet << {hv, id}
# end

# hanviet.each do |hv, id|
#   DIC.exec "update terms set hv = ? where rowid = ?", hv, id
# end

# VI = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

# Dir.glob("var/vhint/phrase/viuser/*.tsv").each do |file|
#   File.each_line(file) do |line|
#     args = line.split('\t')
#     key = args.shift
#     VI[key] = args
#   end
# end

# Dir.glob("var/vhint/phrase/cvuser/*.tsv").each do |file|
#   File.each_line(file) do |line|
#     args = line.split('\t')
#     key = args.shift
#     VI[key].concat(args).uniq!
#   end
# end

# VI.each do |zh, vi|
#   next unless res = DIC.query_one?("select rowid, vi from terms where zh = ?", zh, as: {Int32, String})
#   vi.concat(res[1].split('\t')).reject!(&.empty?).uniq!
#   DIC.exec "update terms set vi = ? where rowid = ?", vi.join('\t'), res[0]
# end
