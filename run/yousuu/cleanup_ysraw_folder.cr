DIR = "var/ysraw/crits-by-list"

dirs = Dir.children(DIR)

dirs.each do |dir|
  next if dir.size == 24
  puts dir
  `rm -rf '#{DIR}/#{dir}'`
end
