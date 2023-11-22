ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"

existing = MT::ViTerm.db("regular").open_ro do |db|
  db.query_all("select ipos, zstr from terms", as: {Int32, String}).to_set
end

puts existing.size

suggests = MT::ViTerm.get_all(db: MT::ViTerm.db("suggest"))
puts suggests.size
suggests.reject! { |x| existing.includes?({x.ipos, x.zstr}) }
puts suggests.size

MT::ViTerm.db("regular").open_tx do |db|
  suggests.each(&.upsert!(db: db))
end
