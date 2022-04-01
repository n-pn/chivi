require "../shared/bootstrap"
DIR = "var/chtexts/users"

Dir.children(DIR).each do |bhash|
  idx_files = Dir.glob("#{DIR}/#{bhash}/*.tsv")

  if idx_files.empty?
    FileUtils.rm_rf("#{DIR}/#{bhash}") if ARGV.includes?("--delete")
    next
  end

  next unless nvinfo = CV::Nvinfo.find({bhash: bhash})
  puts nvinfo.vname

  idx_file = idx_files.sort_by { |x| File.basename(x, ".tsv").to_i.- }.first

  lines = File.read_lines(idx_file)
  lines.pop if lines.last.empty?

  nvseed = CV::Nvseed.load!(nvinfo, CV::SnameMap.map_int("users"))

  nvseed.chap_count = lines.size
  nvseed.last_schid = lines.last.split('\t')[1]
  nvseed.utime = File.info(idx_file).modification_time.to_unix

  puts [nvseed.chap_count, nvseed.last_schid, nvseed.utime]
  nvseed.save!
end
