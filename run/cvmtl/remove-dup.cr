ARGV.each do |file|
  file = "var/cvmtl/inits/#{file}"
  next unless File.exists?(file)

  lines = File.read_lines(file)

  xx = 0

  lines.uniq! do |line|
    if line.empty? || line[0] == '#'
      xx += 1
      xx.to_s
    else
      line
    end
  end

  File.write(file + ".1", lines.join("\n"))
end
