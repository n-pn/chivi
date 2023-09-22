ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/zroot/corpus"

CORPUS = ZR::Corpus.new("wnovel/bintro")

LIMIT = 1000

QUERY = <<-SQL
  select id::text as wn_id, zintro from wninfos
  where id > $1 and id <= $1 + #{LIMIT}
  order by id asc
SQL

start = ARGV[0]?.try(&.to_i?) || 0
total = PGDB.query_one "select max(id) from wninfos", as: Int32
limit = total // LIMIT + 1

start.upto(limit) do |page|
  puts "- on page: #{page}/#{limit}"

  input = PGDB.query_all QUERY, page * LIMIT, as: {String, String}
  next if input.empty?

  saved = 0
  CORPUS.open_tx(vtran: false, ctree: false) do
    input.each do |wn_id, ztext|
      lines = ZR::Corpus.clean_lines(ztext.lines, to_canon: true, remove_blank: true)
      saved &+= 1 if !lines.empty? && CORPUS.add_part!(wn_id, lines)[1]
    end
  end
  puts "  total: #{input.size}, saved: #{saved}"
end
