require "../../src/_data/dboard/dtopic"
require "../../src/_data/dboard/gdroot"
require "../../src/_data/dboard/rpnode"

# Log.setup :debug

# CV::Dtopic.query.order_by(id: :asc).each do |dtopic|
#   puts "#{dtopic.id}-#{dtopic.title}"
#   gdroot = CV::Gdroot.find!(:dtopic, dtopic.id.to_s)

#   PGDB.query <<-SQL, gdroot.viuser_id, gdroot.id
#     update gdroots set touser_id = $1
#     where torepl_id = 0 and gdroot_id = $2
#   SQL
#   # CV::Gdroot.new(dtopic).upsert!
# end

# wn_ids.each do |wn_id|
#   wnovel = CV::Wninfo.find!({id: wn_id})
#   puts "#{wnovel.id}-#{wnovel.vname}"
#   CV::Gdroot.new(wnovel).upsert!
# end
