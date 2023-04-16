# require "../shared/bootstrap"
# DIR = "var/chaps/texts/users"

# Dir.children(DIR).each do |bhash|
#   idx_files = Dir.glob("#{DIR}/#{bhash}/*.tsv")

#   if idx_files.empty?
#     FileUtils.rm_rf("#{DIR}/#{bhash}") if ARGV.includes?("--delete")
#     next
#   end

#   next unless nvinfo = CV::Wninfo.find({bhash: bhash})
#   nvseed = CV::Chroot.load!(nvinfo, "users")

#   list_file = idx_files.sort_by { |x| File.basename(x, ".tsv").to_i }.last
#   last_chap = CV::ChList.new(list_file).data.max_by(&.[0])[1]

#   nvseed.chap_count = last_chap.chidx
#   nvseed.last_schid = last_chap.schid
#   nvseed.utime = last_chap.stats.utime

#   nvseed.save!
#   nvinfo.tap(&.add_nvseed(nvseed.zseed)).save!

#   puts [nvinfo.vname, nvseed.chap_count, nvseed.last_schid, nvseed.utime]
# end
