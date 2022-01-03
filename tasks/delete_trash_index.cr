DIR = "var/chtexts"

snames = Dir.children(DIR)
snames.each do |sname|
  dir = File.join(DIR, sname)
  snvids = Dir.children(dir)

  snvids.each do |snvid|
    files = Dir.glob("#{dir}/#{snvid}/*.tsv")

    files.each do |file|
      next unless is_trash?(file)

      File.delete(file)
    end
  end
end

def is_trash?(file : String)
  return false if file.size >= 5000
  return true unless fline = File.read_lines(file).find { |x| !x.empty? }

  chidx = fline.split('\t', 2).first.to_i
  pgidx = File.basename(file, ".tsv").to_i

  (chidx - 1) // 128 != pgidx
end
