require "../../src/_data/dboard/gdroot"
require "../../src/_data/dboard/gdrepl"

# data = Array({Int32, Int32, Int32}).from_json(File.read "tmp/gdrepls.json")

# data.each do |id, touser_id, torepl_id|
#   puts [{id, touser_id, torepl_id}]
#   PGDB.exec <<-SQL, touser_id, torepl_id, id
#   update gdrepls set touser_id = $1, torepl_id = $2 where id = $3
#   SQL
# end

CV::Gdrepl.query.order_by(id: :asc).each do |gdrepl|
  next if gdrepl.torepl_id == 0

  parent = CV::Gdrepl.find!({id: gdrepl.torepl_id})
  next if gdrepl.touser_id == parent.viuser_id

  puts [gdrepl.touser_id, parent.viuser_id]

  PGDB.exec <<-SQL, parent.viuser_id, gdrepl.id
    update gdrepls set touser_id = $1 where id = $2
    SQL
end
