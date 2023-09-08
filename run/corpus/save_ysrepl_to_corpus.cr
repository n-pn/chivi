ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/zroot/corpus"

CORPUS = ZR::Corpus.new("yousuu/ysrepl")
CORPUS.init_zdata!

LIMIT = 1000

QUERY = <<-SQL
  select encode(yr_id, 'hex') as yr_id, ztext from ysrepls
  where id > $1 and id <= $1 + #{LIMIT}
  order by id asc
SQL

start = ARGV[0]?.try(&.to_i?) || 0

total = PGDB.query_one "select max(id) from ysrepls", as: Int32
limit = total // LIMIT

start.upto(limit) do |page|
  puts "- on page: #{page}/#{limit}"

  input = PGDB.query_all QUERY, page * LIMIT, as: {String, String}
  next if input.empty?

  saved = 0

  CORPUS.open_tx do
    input.each do |yr_id, ztext|
      lines = ZR::Corpus.clean_lines(ztext.lines, to_canon: true, remove_empty: true)
      saved &+= 1 if !lines.empty? && CORPUS.add_part!(yr_id, lines)
    end
  end

  puts "  total: #{input.size}, saved: #{saved}"
end
