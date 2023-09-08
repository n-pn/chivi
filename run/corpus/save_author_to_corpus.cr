ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/zroot/corpus"

CORPUS = ZR::Corpus.new("wnovel/author")
CORPUS.init_zdata!

LIMIT = 1000

QUERY = <<-SQL
  select id::text as wn_id, author_zh as author from wninfos
  where id > $1 and id <= $1 + #{LIMIT}
  order by id asc
SQL

start = ARGV[0]?.try(&.to_i?) || 0
total = PGDB.query_one "select max(id) from wninfos", as: Int32
limit = total // LIMIT

start.upto(limit) do |page|
  puts "- on page: #{page}/#{limit}"

  input = PGDB.query_all QUERY, page * LIMIT, as: {String, String}
  next if input.empty?

  saved = 0

  CORPUS.open_tx do
    input.each do |wn_id, author|
      next if author.empty?
      author = CharUtil.to_canon(author)
      saved &+= 1 if CORPUS.add_part!(wn_id, [author])
    end
  end

  puts "  total: #{input.size}, saved: #{saved}"
end
