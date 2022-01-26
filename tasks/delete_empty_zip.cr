DIR = "var/chtexts"

Dir.children(DIR).each do |sname|
  dir = File.join(DIR, sname)
  snvids = Dir.children(dir)
  snvids.each do |snvid|
    files = Dir.glob("#{DIR}/#{sname}/#{snvid}/*.zip")
    files.each do |file|
      next unless File.size(file) == 0
      File.delete(file)
      puts "#{file} is deleted!"
    end
  end
end
