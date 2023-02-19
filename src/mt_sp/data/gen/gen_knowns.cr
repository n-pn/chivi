require "../sp_ents"

knowns = Set(String).new
SP::EntRelate.db.query_each("select form, etag from ent_relates") do |rs|
  knowns << rs.read(String) + "\t" + rs.read(String)
end

SP::EntValue.db.query_each("select form, etag from ent_values") do |rs|
  knowns << rs.read(String) + "\t" + rs.read(String)
end

File.write("var/texts/anlzs/known_entities.tsv", knowns.join('\n'))
