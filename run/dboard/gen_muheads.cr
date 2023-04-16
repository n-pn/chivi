require "../../src/_data/dboard/murepl"
require "../../src/_data/dboard/dtopic"
require "../../src/_data/dboard/muhead"

# Log.setup :debug

CV::Dtopic.query.order_by(id: :asc).each do |dtopic|
  puts "#{dtopic.id}-#{dtopic.title}"
  CV::Muhead.new(dtopic).upsert!
end

# wn_ids.each do |wn_id|
#   wnovel = CV::Wninfo.find!({id: wn_id})
#   puts "#{wnovel.id}-#{wnovel.vname}"
#   CV::Muhead.new(wnovel).upsert!
# end
