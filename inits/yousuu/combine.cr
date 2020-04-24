require "json"
require "colorize"
require "file_utils"

require "../../src/entity/ybook"

files = Dir.glob("data/txt-inp/yousuu/serials/*.json")
puts "- input: #{files.size} entries".colorize(:blue)

inputs = Hash(String, Array(YBook)).new { |h, k| h[k] = [] of YBook }

files.each do |file|
  data = File.read(file)

  if data.includes?("{\"success\":true,")
    book = YBook.load(data)
    next if book.title.empty? || book.author.empty?

    inputs[book.label] << book
  elsif data.includes?("未找到该图书")
    # puts "- [#{file}] is 404!".colorize(:blue)
  else
    puts "- [#{file}] malformed!".colorize(:red)
    File.delete(file)
  end
rescue err
  puts "#{file} err: #{err}".colorize(:red)
  puts data
end

output = [] of YBook

inputs.map do |slug, books|
  books = books.sort_by { |x| {x.hidden, -x.mtime} }
  first = books.first

  books[1..].each { |other| first.merge(other) }
  next if first.tally < 50

  output << first
end

File.write("data/txt-tmp/yousuu/serials.json", output.to_pretty_json)
