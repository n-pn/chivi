require "../../src/zroot/corpus"

repo = ZR::Corpus.new("yousuu/yscrit")

lines = repo.zline_db.open_ro do |db|
  db.query_all "select zline from zlines order by rowid asc", as: String
end

lines.each_slice(10000).with_index do |group, index|
  dir = "var/zroot/corpus/yousuu/yscrit/#{index}"
  Dir.mkdir_p(dir)

  group.each_slice(50).with_index do |lines, page|
    File.write("#{dir}/#{page}.txt", lines.join('\n'))
  end

  puts "#{index} block saved"
end
