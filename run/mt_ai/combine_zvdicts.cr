INP = "/2tb/app.chivi/var/mt_db/mt_ai"
ENV["MT_DIR"] ||= "/2tb/app.chivi/var/mt_db"

require "../../src/mt_ai/data/vi_term"
require "../../src/mt_ai/data/zv_term"
require "../../src/mt_ai/data/zv_dict"

def make_zvterm(term, d_id)
  zterm = MT::ZvTerm.new(
    d_id: d_id,
    zstr: term.zstr,
    cpos: term.cpos,
    vstr: term.vstr,
    attr: term.attr,
    plock: term.plock.to_i16,
  )

  zterm.tap(&.add_track(term.uname, term.mtime))
end

def merge_wn_a(db_file : String)
  d_id = File.basename(db_file, ".db3")
  return if d_id[0] == '$'

  terms = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    db.query_all "select * from terms where mtime > $1", MTIME, as: MT::ViTerm
  end

  puts "#{db_file}: #{terms.size} entries"
  return if terms.size == 0

  dict = MT::ZvDict.load!("wn#{d_id}")
  dict.total = terms.size

  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

def merge_up_a(db_file : String)
  d_id = File.basename(db_file, ".db3")
  dict = MT::ZvDict.load!("up#{d_id}")

  terms = DB.open("sqlite3:#{db_file}?immutable=1") do |db|
    db.query_all "select * from terms where mtime > $1", MTIME, as: MT::ViTerm
  end

  puts "#{db_file}: #{terms.size} entries"
  return if terms.size == 0

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

def merge_essence
  terms = DB.open("sqlite3:#{INP}/essence.db3?immutable=1") do |db|
    db.query_all "select * from terms", as: MT::ViTerm
  end

  DB.open("sqlite3:#{INP}/hv_word.db3?immutable=1") do |db|
    terms.concat(db.query_all "select * from terms", as: MT::ViTerm)
  end

  puts "essence: #{terms.size} entries"
  dict = MT::ZvDict.load!("essence")

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

def merge_name_hv
  terms = DB.open("sqlite3:#{INP}/hv_name.db3?immutable=1") do |db|
    db.query_all "select * from terms", as: MT::ViTerm
  end

  puts "name_hv: #{terms.size} entries"

  dict = MT::ZvDict.load!("name_hv")
  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

MTIME = TimeUtil.cv_mtime - 60

def merge_regular
  dict = MT::ZvDict.load!("regular")

  terms = DB.open("sqlite3:#{INP}/regular.db3?immutable=1") do |db|
    db.query_all "select * from terms where mtime > $1", MTIME, as: MT::ViTerm
  end

  puts "regular: #{terms.size} entries"

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

def merge_combine
  dict = MT::ZvDict.load!("combine")

  terms = DB.open("sqlite3:#{INP}/combine.db3?immutable=1") do |db|
    db.query_all "select * from terms where mtime > $1", MTIME, as: MT::ViTerm
  end

  puts "combine: #{terms.size} entries"

  dict.total = terms.size
  dict.mtime = terms.max_of(&.mtime)
  dict.users = terms.map(&.uname).uniq!.reject!(&.empty?)

  MT::ZvTerm.db.transaction do |db|
    terms.each { |x| make_zvterm(x, dict.d_id).upsert!(db: db.connection) }
  end
end

# merge_essence
merge_regular
# merge_combine
# merge_name_hv

Dir.glob("#{INP}/up/*.db3").each { |file| merge_up_a(file) }
Dir.glob("#{INP}/wn/*.db3").each { |file| merge_wn_a(file) }

MT::ZvDict.db.transaction do |db|
  MT::ZvDict::DB_CACHE.each_value(&.upsert!(db: db.connection))
end
