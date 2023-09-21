ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"

# existing = MT::ViTerm.db("regular").open_ro do |db|
#   db.query_all("select ipos, zstr from terms", as: {Int32, String}).to_set
# end

hv_words = MT::ViTerm.get_all(db: MT::ViTerm.db("hv_word"))
hv_words.reject! { |x| x.ipos == 0 && x.zstr.size > 1 }

MT::ViTerm.db("regular").open_ro do |db|
  query = "select zstr from terms where ipos = $1 and zstr = $2"
  hv_words.each do |hv_word|
    next unless db.query_one?(query, hv_word.ipos, hv_word.zstr, as: String)
    hv_word.plock = -1
  end
end

hv_words.reject!(&.plock.< 0)
puts hv_words.size

MT::ViTerm.db("regular").open_tx do |db|
  hv_words.each(&.upsert!(db: db))
end
