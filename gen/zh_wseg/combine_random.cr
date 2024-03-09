DIR = "/www/chivi/freqs"

all_book = Hash(String, Int32).new(0)
per_book = Hash(String, Int32).new(0)

fpaths = Dir.glob("#{DIR}/random/*.tsv")

fpaths.each do |fpath|
  File.each_line(fpath) do |line|
    word, _, freq = line.partition('\t')
    all_book[word] &+= freq.to_i
    per_book[word] &+= 1
  end
end

File.open("#{DIR}/random-all_book.tsv", "w") do |file|
  all_book.to_a.sort_by!(&.[1].-).each do |word, freq|
    file << word << '\t' << freq << '\n'
  end
end

File.open("#{DIR}/random-per_book.tsv", "w") do |file|
  per_book.to_a.sort_by!(&.[1].-).each do |word, freq|
    file << word << '\t' << freq << '\n'
  end
end
