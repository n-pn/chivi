ENV["CV_ENV"] = "production"
require "../../src/_data/_data"

require "../../src/zroot/corpus"

LIMIT = 500

CORPUS = ZR::Corpus.new("yousuu/yscrits")

SELECT_QUERY = <<-SQL
  select encode(yc_id, 'hex') as yc_id, ztext from yscrits
  where id >= $1 and id < $1 + #{LIMIT}
SQL

start_page = ARGV[0]?.try(&.to_i?) || 0

(start_page..).each do |page|
  puts "- on page: #{page}"
  start = page * LIMIT

  input = PGDB.query_all SELECT_QUERY, start, as: {String, String}
  break if input.empty?

  CORPUS.open_tx
  saved = 0

  input.each do |yc_id, ztext|
    lines = ZR::Corpus.clean_lines(ztext.lines, to_canon: true, remove_empty: true)
    saved &+= 1 if !lines.empty? && CORPUS.add_part!(yc_id, lines)
  end

  CORPUS.close_tx
  puts "  total: #{input.size}, saved: #{saved}"
end
