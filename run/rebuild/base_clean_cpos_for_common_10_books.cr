out_file = File.open("var/dicts/_temp/ctag_in_10_books_cleaned.tsv", "w")
at_exit { out_file.close }

File.each_line("var/dicts/_temp/ctag_in_10_books.tsv") do |line|
  cols = line.split('\t')
  zstr = cols.shift

  vals = cols.map do |col|
    ztag, occu = col.split(':', 2)
    {ztag, occu.to_i}
  end

  vals.sort_by!(&.[1].-)

  # sum = vals.sum(&.[1])
  min = vals.first[1] // 20
  min = 5000 if min > 5000

  vals.reject!(&.[1].< min)

  out_file << zstr << '\t' << vals.join(' ', &.[0]) << '\n'
end

# output.each do |zstr, count|
#   out_file << zstr

#   count.each do |ztag, occu|
#     out_file << '\t' << ztag << ':' << occu
#   end

#   out_file << '\n'
# end
