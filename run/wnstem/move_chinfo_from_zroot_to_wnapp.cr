# ENV["CV_ENV"] = "production"

# require "../../src/_data/_data"
# require "../../src/wnapp/data/chinfo"

# INP = "var/wnapp/chinfo"
# OUT = "var/wn_db/stems"

# input = PGDB.query_all "select wn_id, sname, s_bid from wnseeds where wn_id >= 0 and sname like '@%'", as: {Int32, String, String}

# input.group_by(&.[1]).each do |sname, group|
#   allowed = group.map(&.[2]).to_s

#   mapping = group.map { |x| {x[0], x[2]} }.to_h

#   dirname = "#{OUT}/#{sname}"

#   Dir.each_child(dirname) do |dname|
#     puts "#{dirname}/#{dname}"

#     sn_id = File.basename(dname, ".db3")
#     next if allowed.includes?(sn_id)

#     if new_name = mapping[sn_id]?
#       File.rename("#{dirname}/#{dname}", "#{dirname}/#{dname.sub(sn_id, new_name)}")
#     else
#       File.delete("#{dirname}/#{dname}")
#     end
#   end
# end

# snames = input.map(&.[1]).uniq!
# snames.each { |sname| Dir.mkdir_p("#{OUT}/#{sname}") }

# input.each do |wn_id, sname, sn_id|
#   old_path = "#{INP}/#{wn_id}/#{sname}.db3"
#   next unless File.file?(old_path)

#   new_path = "#{OUT}/#{sname}/#{sn_id}.db3"
#   File.delete?(new_path)
#   File.copy(old_path, new_path)

#   # File.delete(old_path)
#   # File.rename(old_path, old_path + ".old")
#   puts "[#{wn_id}/#{sname}/#{sn_id}] moved!"
# rescue ex
#   puts ex
# end
