def clean(file : String)
  encoding = file.ends_with?("gbk") ? "GB18030" : "UTF-8"
  lines = File.open(file, "r", encoding: encoding, &.gets_to_end).lines

  output = String.build do |io|
    io << lines.shift << '\n'

    c_len = lines.sum(&.size)

    if c_len <= 4500
      limit = c_len
    else
      p_len = (c_len - 1) // 3000 + 1
      limit = c_len // p_len
    end

    count = 0

    lines.each do |line|
      if count > limit
        io << '\n'
        count = 0
      end

      io << '\n' << line
      count += line.size
    end
  end

  if file.ends_with?("gbk")
    File.write(file, output.encode("GB18030"), encoding: "GB18030")
  else
    File.write(file, output)
  end
end

ARGV.each { |file| clean(file) }

# - missing meta file for var/texts/.cache/hetushu/4450/3306816.html.gz
