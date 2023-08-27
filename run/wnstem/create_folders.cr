ENV["CV_ENV"] = "production"
require "../../src/_data/_data"

def mkdirs!(wn_id : Int32)
  Dir.mkdir_p("var/wnapp/chinfo/#{wn_id}")
  Dir.mkdir_p("var/wnapp/chtext/#{wn_id}")
  Dir.mkdir_p("var/wnapp/chtran/#{wn_id}")
end

wn_ids = PGDB.query_all "select id from wninfos where id >= 0 order by id desc", as: Int32
wn_ids.each { |wn_id| mkdirs!(wn_id) }
