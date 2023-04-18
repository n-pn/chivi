require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/muhead"

# data = Array({Int32, Int32, Int32}).from_json(File.read "tmp/murepls.json")

# data.each do |id, touser_id, torepl_id|
#   puts [{id, touser_id, torepl_id}]
#   PGDB.exec <<-SQL, touser_id, torepl_id, id
#   update murepls set touser_id = $1, torepl_id = $2 where id = $3
#   SQL
# end

CV::Murepl.query.order_by(id: :asc).each do |murepl|
  next if murepl.torepl_id == 0

  parent = CV::Murepl.find!({id: murepl.torepl_id})
  next if murepl.touser_id == parent.viuser_id

  puts [murepl.touser_id, parent.viuser_id]

  PGDB.exec <<-SQL, parent.viuser_id, murepl.id
    update murepls set touser_id = $1 where id = $2
    SQL
end
