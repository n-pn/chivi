ENV["CV_ENV"] = "production"

require "../../src/_data/_data"
require "../../src/wnapp/data/chinfo"

INP = "var/wn_db/stems"
OUT = "var/up_db/stems"

TXT = "var/wnapp/chtext"
NLP = "var/wnapp/nlp_wn"

RAW = "var/up_db/texts"

input = PGDB.query_all "select wn_id, sname, s_bid from wnseeds where wn_id >= 0 and sname like '@%' and chap_total > 0", as: {Int32, String, String}

# snames = input.map(&.[1]).uniq!
# snames.each { |sname| Dir.mkdir_p("#{OUT}/#{sname}") }

# input.each do |wn_id, sname, sn_id|
#   old_path = "#{INP}/#{sname}/#{sn_id}.db3"
#   next unless File.file?(old_path)

#   new_path = "#{OUT}/#{sname}/#{sn_id}.db3"
#   File.delete?(new_path)
#   File.copy(old_path, new_path)

#   puts new_path
#   # File.delete(old_path)
#   # File.rename(old_path, old_path + ".old")
#   puts "[#{wn_id}/#{sname}/#{sn_id}] moved!"
# rescue ex
#   puts ex
# end

query = "select ch_no, cksum, sizes from chinfos where cksum <> ''"

input.group_by(&.[1]).each do |sname, group|
  out_dir = "#{RAW}/#{sname}"
  Dir.mkdir_p(out_dir)

  group.each do |wn_id, sname, sn_id|
    old_path = "#{INP}/#{sname}/#{sn_id}.db3"
    # new_path = "#{OUT}/#{sname}/#{sn_id}.db3"

    # next unless File.file?(old_path)

    # File.delete?(new_path)
    # File.copy(old_path, new_path)

    raw_dir = "#{RAW}/#{sname}/#{sn_id}"
    Dir.mkdir_p(raw_dir)

    existed = DB.open("sqlite3:#{old_path}?immutable=1") do |db|
      db.query_all query, as: {Int32, String, String}
    rescue
      [] of {Int32, String, String}
    end

    existed.each do |ch_no, cksum, sizes|
      0.upto(sizes.count(' ')) do |p_idx|
        inp_file = "#{TXT}/#{wn_id}/#{ch_no}-#{cksum}-#{p_idx}.txt"
        out_file = "#{raw_dir}/#{ch_no}-#{cksum}-#{p_idx}.raw.txt"
        File.copy(inp_file, out_file)
        puts out_file
      end

      Dir.glob("#{NLP}/#{wn_id}/#{ch_no}-#{cksum}*").each do |nlp_file|
        out_file = "#{raw_dir}/#{File.basename(nlp_file)}"
        File.copy(nlp_file, out_file)
        puts out_file
      end
    end
  end
end
