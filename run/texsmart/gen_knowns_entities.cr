require "../../src/mt_sp/data/sp_ents"

knowns = Set(String).new
SP::EntRelate.db.query_each("select form, etag from ent_relates") do |rs|
  knowns << rs.read(String) + "\t" + rs.read(String)
end

SP::EntValue.db.query_each("select form, etag from ent_values") do |rs|
  knowns << rs.read(String) + "\t" + rs.read(String)
end

File.write("var/anlzs/texsmart/known_entities.tsv", knowns.join('\n'))