INP = "var/wnapp/chtext"
OUT = "var/texts/wn~avail"

wn_ids = Dir.children(INP)

wn_ids.each do |wn_id|
  old_files = Dir.glob("#{INP}/#{wn_id}/*.txt")
  next if old_files.empty?
  old_size = old_files.size

  new_files = Dir.glob("#{OUT}/#{wn_id}/*.raw.txt").map! { |x| File.basename(x, ".raw.txt") }.to_set

  old_files.select! { |x| File.basename(x, ".txt").in?(new_files) }
  old_files.each { |file| File.delete(file) }

  puts "#{wn_id}: #{old_files.size} deleted, remain: #{old_size - old_files.size}"
end
