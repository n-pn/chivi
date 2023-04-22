require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/dtopic"
require "../../src/_data/dboard/muhead"

# Log.setup :debug

CV::Dtopic.query.order_by(id: :asc).each do |dtopic|
  puts "#{dtopic.id}-#{dtopic.title}"
  muhead = CV::Rproot.find!("gd:#{dtopic.id}")

  PGDB.query <<-SQL, muhead.viuser_id, muhead.id
    update murepls set touser_id = $1
    where torepl_id = 0 and muhead_id = $2
  SQL
  # CV::Rproot.new(dtopic).upsert!
end

# wn_ids.each do |wn_id|
#   wnovel = CV::Wninfo.find!({id: wn_id})
#   puts "#{wnovel.id}-#{wnovel.vname}"
#   CV::Rproot.new(wnovel).upsert!
# end
