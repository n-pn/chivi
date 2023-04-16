require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/muhead"

data = Array({Int32, Int32, Int32}).from_json(File.read "tmp/murepls.json")

data.each do |id, touser_id, torepl_id|
  puts [{id, touser_id, torepl_id}]
  PGDB.exec <<-SQL, touser_id, torepl_id, id
  update murepls set touser_id = $1, torepl_id = $2 where id = $3
  SQL
end

# CV::Murepl.query.order_by(id: :asc).each do |murepl|
#   output << {murepl.id, murepl.touser_id, murepl.torepl_id}

#   #   t_id = murepl.thread_id
#   #   urn = t_id < 0 ? "wn:#{-t_id // 2}" : "gd:#{t_id}"
#   #   puts "urn: #{urn}"
#   #   muhead = CV::Muhead.find!(urn)
#   #   puts "found: #{muhead.id}"

#   #   murepl.muhead_id = muhead.id
#   #   murepl.save!
#   # rescue
#   #   puts [murepl.id, murepl.thread_id, murepl.thread_mu, murepl.viuser_id]
#   #   puts murepl.itext
# end

# File.write("tmp/murepls.json", output.to_pretty_json)
