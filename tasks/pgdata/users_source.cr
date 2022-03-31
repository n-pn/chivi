require "../shared/bootstrap"
DIR = "var/chtexts/users"

Dir.children(DIR).each do |bhash|
  idx_files = Dir.glob("#{DIR}/#{bhash}/*.tsv")

  if idx_files.empty?
    FileUtils.rm_rf("#{DIR}/#{bhash}") if ARGV.includes?("--delete")
    next
  end

  next unless nvinfo = CV::Nvinfo.find({bhash: bhash})
  puts nvinfo.bname

  idx_file = idx_files.sort_by { |x| File.basename(x, ".tsv").to_i.- }.first

  lines = File.read_lines(idx_file)
  lines.pop if lines.last.empty?

  zhbook = CV::Nvseed.load!(nvinfo, CV::SeedUtil.map_id("users"))

  zhbook.chap_count = lines.size
  zhbook.last_schid = lines.last.split('\t')[1]
  zhbook.mftime = File.info(idx_file).modification_time.to_unix

  puts [zhbook.chap_count, zhbook.last_schid, zhbook.mftime]
  zhbook.save!
end
