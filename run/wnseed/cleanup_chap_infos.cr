INP = "var/chaps/infos"
childs = Dir.children(INP).map! { |x| "#{INP}/#{x}" }.select! { |x| File.directory?(x) }

childs.each do |child|
  `find '#{child}' -type f -name '*-trans.db' -delete`

  files = Dir.glob("#{child}/*-infos")
  files.each do |file|
    next unless File.file?(file.sub("-infos", ".db"))
    puts "deleting: #{file}"
    File.delete(file)
  end
end
