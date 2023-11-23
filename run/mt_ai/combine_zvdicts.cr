INP = "/2tb/app.chivi/var/mt_db/mt_ai"
ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/mt_ai/data/vi_term"
require "../../src/mt_ai/data/zv_dict"

def merge_wn_a(db_file : String)
  d_id = File.basename(db_file, ".db3")
  return if d_id[0] == '$'

  terms = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    db.query_all "select #{d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "#{db_file}: #{terms.size} entries"

  dict = MT::ZvDict.load!("wn#{d_id}")

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  return if dict.total == 0

  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_up_a(db_file : String)
  d_id = File.basename(db_file, ".db3")

  terms = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    db.query_all "select #{d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "#{db_file}: #{terms.size} entries"

  dict = MT::ZvDict.load!("up#{d_id}")

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  return if dict.total == 0

  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
rescue ex
  puts db_file, ex
end

def merge_essence
  dict = MT::ZvDict.load!("essence")

  terms = DB.open("sqlite3:#{INP}/essence.db3?immutable=1") do |db|
    db.query_all "select #{dict.d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "essence: #{terms.size} entries"

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_word_hv
  dict = MT::ZvDict.load!("word_hv")

  terms = DB.open("sqlite3:#{INP}/hv_word.db3?immutable=1") do |db|
    db.query_all "select #{dict.d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "word_hv: #{terms.size} entries"

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_name_hv
  dict = MT::ZvDict.load!("name_hv")

  terms = DB.open("sqlite3:#{INP}/hv_name.db3?immutable=1") do |db|
    db.query_all "select #{dict.d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "name_hv: #{terms.size} entries"

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_regular
  dict = MT::ZvDict.load!("regular")

  terms = DB.open("sqlite3:#{INP}/regular.db3?immutable=1") do |db|
    db.query_all "select #{dict.d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "regular: #{terms.size} entries"

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_combine
  dict = MT::ZvDict.load!("combine")

  terms = DB.open("sqlite3:#{INP}/combine.db3?immutable=1") do |db|
    db.query_all "select #{dict.d_id} as d_id, * from terms", as: MT::ZvTerm
  end

  puts "combine: #{terms.size} entries"

  dict.term_db.open_tx do |db|
    terms.each(&.upsert!(db: db))
  end

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.join(',')
end

def merge_core
  merge_essence
  merge_word_hv
  merge_name_hv
  merge_regular
  merge_combine
end

merge_core
Dir.glob("#{INP}/up/*.db3").each { |file| merge_up_a(file) }
Dir.glob("#{INP}/book/*.db3").each { |file| merge_wn_a(file) }

MT::ZvDict.db.open_tx do |db|
  MT::ZvDict::DB_CACHE.each_value(&.upsert!(db: db))
end
