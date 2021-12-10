require "../shared/seed_data"

DIR = "var/chtexts/chivi"

Dir.children(DIR).each do |bhash|
  idx_files = Dir.glob("#{DIR}/#{bhash}/*.tsv")

  if idx_files.empty?
    FileUtils.rm_rf("#{DIR}/#{bhash}") if ARGV.includes?("--delete")
    next
  end

  next unless cvbook = CV::Cvbook.find({bhash: bhash})
  puts cvbook.bname

  idx_file = idx_files.sort_by { |x| File.basename(x, ".tsv").to_i.- }.first

  lines = File.read_lines(idx_file)
  lines.pop if lines.last.empty?

  zhbook = CV::Zhbook.load!(cvbook, 0)

  zhbook.chap_count = lines.size
  zhbook.last_schid = lines.last.split('\t')[1]
  zhbook.mftime = File.info(idx_file).modification_time.to_unix

  puts [zhbook.chap_count,
        zhbook.last_schid,
        zhbook.mftime]

  zhbook.save!
end
