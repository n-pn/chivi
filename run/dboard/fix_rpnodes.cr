require "../../src/_data/dboard/gdroot"
require "../../src/_data/dboard/rpnode"

# data = Array({Int32, Int32, Int32}).from_json(File.read "tmp/rpnodes.json")

# data.each do |id, touser_id, torepl_id|
#   puts [{id, touser_id, torepl_id}]
#   PGDB.exec <<-SQL, touser_id, torepl_id, id
#   update rpnodes set touser_id = $1, torepl_id = $2 where id = $3
#   SQL
# end

CV::Gdrepl.query.order_by(id: :asc).each do |rpnode|
  next if rpnode.torepl_id == 0

  parent = CV::Gdrepl.find!({id: rpnode.torepl_id})
  next if rpnode.touser_id == parent.viuser_id

  puts [rpnode.touser_id, parent.viuser_id]

  PGDB.exec <<-SQL, parent.viuser_id, rpnode.id
    update rpnodes set touser_id = $1 where id = $2
    SQL
end
