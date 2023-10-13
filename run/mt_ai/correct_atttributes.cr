# ENV["MT_DIR"] = "/2tb/dev.chivi/var/mt_db/mt_ai"
ENV["MT_DIR"] = "/2tb/app.chivi/var/mt_db/mt_ai"

require "../../src/mt_ai/data/vi_term"

terms = MT::ViTerm.db("regular").open_ro do |db|
  query = "select * from terms where ipos = $1"
  db.query_all query, MT::MtEpos::JJ.to_i, as: MT::ViTerm
end

terms.reject! { |x| x.zstr.size > 1 || x.attr.includes?("Prfx") }

MT::ViTerm.db("regular").open_tx do |db|
  query = "update terms set attr = $1, iatt = $2 where ipos = $3 and zstr = $4"

  terms.each do |term|
    term.attr = {term.attr, "Prfx"}.join(" ").strip

    db.exec query, term.attr, term.iatt, term.ipos, term.zstr
  end
end
