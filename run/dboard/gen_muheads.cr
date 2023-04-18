require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/dtopic"
require "../../src/_data/dboard/muhead"

# Log.setup :debug

CV::Dtopic.query.order_by(id: :asc).each do |dtopic|
  puts "#{dtopic.id}-#{dtopic.title}"
  muhead = CV::Muhead.find!("gd:#{dtopic.id}")

  PGDB.query <<-SQL, muhead.viuser_id, muhead.id
    update murepls set touser_id = $1
    where torepl_id = 0 and muhead_id = $2
  SQL
  # CV::Muhead.new(dtopic).upsert!
end

# wn_ids.each do |wn_id|
#   wnovel = CV::Wninfo.find!({id: wn_id})
#   puts "#{wnovel.id}-#{wnovel.vname}"
#   CV::Muhead.new(wnovel).upsert!
# end
