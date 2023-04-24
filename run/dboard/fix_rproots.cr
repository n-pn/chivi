require "../../src/_data/dboard/rproot"

# data = Array({Int32, Int32, Int32}).from_json(File.read "tmp/rpnodes.json")

# data.each do |id, touser_id, torepl_id|
#   puts [{id, touser_id, torepl_id}]
#   PGDB.exec <<-SQL, touser_id, torepl_id, id
#   update rpnodes set touser_id = $1, torepl_id = $2 where id = $3
#   SQL
# end

roots = CV::Rproot.db.query_all <<-SQL, as: CV::Rproot
  select * from rproots where ukey = '' order by id desc
SQL

def map_kind(kind : CV::Rproot::Kind)
  kind.value
end

roots.each do |root|
  type, ukey = root.urn.split(':')

  case type
  when "gd" then kind = map_kind(:dtopic)
  when "wn" then kind = map_kind(:wninfo)
  when "vc" then kind = map_kind(:vicrit)
  when "vl" then kind = map_kind(:vilist)
  else           raise "unsuported urn: #{root.urn}"
  end

  puts [root.urn, kind, ukey]

  CV::Rproot.db.exec <<-SQL, kind, ukey, root.id
    update rproots set kind = $1, ukey = $2 where id = $3
    SQL
end
