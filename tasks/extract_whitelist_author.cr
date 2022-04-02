inp_file = "var/_common/miscs/nvinfos.tsv"

out_data = Set(String).new

File.read_lines(inp_file).each_with_index do |line, idx|
  _, author = line.split('\t', 2)
  out_data << author
rescue err
  puts [line, idx, err.message]
end

File.write("var/_common/authors.txt", out_data.join("\n"))
