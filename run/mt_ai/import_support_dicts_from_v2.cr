require "../../src/mt_ai/data/vi_term"

struct Input
  include DB::Serializable
  include DB::Serializable::NonStrict

  getter zstr : String = ""
  getter vstr : String = ""

  getter uname : String = ""
  getter mtime : Int32 = 0

  SPLIT = 'ǀ'

  def to_term
    vstr = @vstr.split(SPLIT).first.strip

    term = MT::ViTerm.new(zstr: @zstr, cpos: "_", vstr: vstr, attr: MT::MtAttr::None)

    term.uname = @uname
    term.mtime = @mtime

    term._lock = @uname.empty? ? 1 : 2

    term
  end
end

hv_names = DB.open "sqlite3:var/mtdic/mt_sp/hv_name.dic" do |db|
  db.query_all("select * from defns", as: Input)
end

puts hv_names.size

MT::ViTerm.db("hv_name").open_tx do |db|
  hv_names.each(&.to_term.upsert!(db: db))
end

hv_words = DB.open "sqlite3:var/mtdic/mt_sp/sino_vi.dic" do |db|
  db.query_all("select * from defns", as: Input)
end

puts hv_words.size

MT::ViTerm.db("hv_word").open_tx do |db|
  hv_words.each(&.to_term.upsert!(db: db))
end

pin_yins = DB.open "sqlite3:var/mtdic/mt_sp/pin_yin.dic" do |db|
  db.query_all("select * from defns", as: Input)
end

puts pin_yins.size

MT::ViTerm.db("pin_yin").open_tx do |db|
  pin_yins.each(&.to_term.upsert!(db: db))
end
