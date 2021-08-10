require "../shared/seed_data"

SEED = "_db/chseed/chivi"
TRAN = "_db/chtran/chivi"

Dir.children(SEED).each do |bhash|
  FileUtils.rm_rf("#{TRAN}/#{bhash}")

  idx_file = "#{SEED}/#{bhash}/_id.tsv"
  unless File.exists?(idx_file)
    FileUtils.rm_rf("#{SEED}/#{bhash}")
    next
  end

  next unless cvbook = CV::Cvbook.load!(bhash)
  puts cvbook.bname

  lines = File.read_lines(idx_file)
  lines.pop if lines.last.empty?

  zhbook = CV::Zhbook.load!(cvbook, 0)

  zhbook.chap_count = lines.size
  zhbook.last_schid = lines.last.split('\t').first
  zhbook.mftime = File.info(idx_file).modification_time.to_unix
  zhbook.save!
end
