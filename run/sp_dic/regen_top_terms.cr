require "../../src/mt_sp/data/wd_defn"
# require "../../src/mt_sp/data/lu_term"

terms = [] of TL::LuTerm

DB.open("sqlite3://var/dicts/core.dic") do |db|
  db.query_each "select key, val, alt from terms" do |rs|
    key, val, alt = rs.read(String, String, String?)
    next if key =~ /\P{Han}/
    terms << TL::LuTerm.new(key, val) unless val.empty?
    terms << TL::LuTerm.new(key, alt) if alt
  end
end

keeps = begin
  set = Set(String).new

  File.each_line("var/inits/bdtmp/top25-all.tsv") do |line|
    set << line.split('\t').first
  end

  set
end

DB.open("sqlite3://var/dicts/book.dic") do |db|
  db.query_each "select key, val, alt from terms" do |rs|
    key, val, alt = rs.read(String, String, String?)
    next if key =~ /\P{Han}/ || !keeps.includes?(key)

    terms << TL::LuTerm.new(key, val) unless val.empty?
    terms << TL::LuTerm.new(key, alt) if alt
  end
end

puts "input: #{terms.size}"

TL::LuTerm.init_db("top_terms", reset: true)
TL::LuTerm.upsert_bulk("top_terms", terms)
# TL::LuTerm.remove_dup!("top_terms")
