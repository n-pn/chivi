require "../../src/mt_ai/data/pg_dict"

d_id = MT::PgDict.load!("regular").d_id

query = "select * from zvterm where d_id ipos = $1"
terms = MT::ZvTerm.db.query_all query, MT::MtEpos::JJ.to_i, as: MT::ZvTerm

terms.reject! { |x| x.zstr.size > 1 || x.attr.includes?("Prfx") }

MT::ZvTerm.db.transaction do |tx|
  query = "update zvterm set attr = $1 where d_id = $2 and ipos = $3 and zstr = $4"

  terms.each do |term|
    term.attr = {term.attr, "Prfx"}.join(" ").strip
    tx.connection.exec query, term.attr, d_id, term.ipos, term.zstr
  end
end
