require "../../src/_data/dboard/dtopic"
require "../../src/_data/dboard/rproot"
require "../../src/_data/dboard/rpnode"

# Log.setup :debug

CV::Dtopic.query.order_by(id: :asc).each do |dtopic|
  puts "#{dtopic.id}-#{dtopic.title}"
  rproot = CV::Rproot.find!("gd:#{dtopic.id}")

  PGDB.query <<-SQL, rproot.viuser_id, rproot.id
    update rproots set touser_id = $1
    where torepl_id = 0 and rproot_id = $2
  SQL
  # CV::Rproot.new(dtopic).upsert!
end

# wn_ids.each do |wn_id|
#   wnovel = CV::Wninfo.find!({id: wn_id})
#   puts "#{wnovel.id}-#{wnovel.vname}"
#   CV::Rproot.new(wnovel).upsert!
# end
