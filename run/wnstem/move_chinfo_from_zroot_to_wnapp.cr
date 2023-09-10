ENV["CV_ENV"] = "production"

require "../../src/_data/_data"
require "../../src/wnapp/data/chinfo"

INP = "var/zroot/wnchap"
OUT = "var/wnapp/chinfo"

input = PGDB.query_all "select wn_id, sname, s_bid from wnseeds", as: {Int32, String, String}

input.each do |wn_id, sname, sn_id|
  new_path = WN::Chinfo.db_path(wn_id, sname)
  next if File.file?(new_path)
  old_path = WN::Chinfo.old_db_path(sname, sn_id)
  next unless File.file?(old_path)

  File.copy(old_path, new_path)
  File.rename(old_path, old_path + ".old")
  puts "[#{wn_id}/#{sname}/#{sn_id}] moved!"
end
