ENV["CV_ENV"] ||= "production"
require "../../src/_data/_data"

def mkdirs!(wn_id : Int32)
  Dir.mkdir_p("var/texts/wn~avail/#{wn_id}")
end

wn_ids = PGDB.query_all "select distinct(wn_id) from wnseeds", as: Int32
wn_ids.each { |wn_id| mkdirs!(wn_id) }
