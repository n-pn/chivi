ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/zroot/corpus"

CORPUS = ZR::Corpus.new("yousuu/yscrit")

LIMIT = 1000

QUERY = <<-SQL
  select encode(yc_id, 'hex') as yc_id, ztext from yscrits
  where id > $1 and id <= $1 + #{LIMIT}
  order by id asc
SQL

start = ARGV[0]?.try(&.to_i?) || 0

total = PGDB.query_one "select max(id) from yscrits", as: Int32
limit = total // LIMIT

start.upto(limit) do |page|
  puts "- on page: #{page}/#{limit}"

  input = PGDB.query_all QUERY, page * LIMIT, as: {String, String}
  next if input.empty?

  saved = 0

  CORPUS.open_tx(vtran: false, ctree: false) do
    input.each do |yc_id, ztext|
      lines = ZR::Corpus.clean_lines(ztext.lines, to_canon: true, remove_blank: true)
      saved &+= 1 if !lines.empty? && CORPUS.add_part!(yc_id, lines)[1]
    end
  end

  puts "  total: #{input.size}, saved: #{saved}"
end
