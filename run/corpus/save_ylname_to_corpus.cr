ENV["CV_ENV"] = "production"
require "../../src/_data/_data"
require "../../src/zroot/corpus"

CORPUS = ZR::Corpus.new("yousuu/ylname")
CORPUS.init_dbs!(no_vdata: true)

LIMIT = 1000
QUERY = <<-SQL
  select encode(yl_id, 'hex') as yl_id, zname from yslists
  where id > $1 and id <= $1 + #{LIMIT}
  order by id asc
SQL

start = ARGV[0]?.try(&.to_i?) || 0
total = PGDB.query_one "select max(id) from yslists", as: Int32
limit = total // LIMIT

start.upto(limit) do |page|
  puts "- on page: #{page}/#{limit}"

  input = PGDB.query_all QUERY, page * LIMIT, as: {String, String}
  next if input.empty?

  saved = 0

  CORPUS.open_tx do
    input.each do |yl_id, ztext|
      ztext = CharUtil.to_canon(ztext)
      saved &+= 1 if !ztext.empty? && CORPUS.add_part!(yl_id, [ztext])[1]
    end
  end

  puts "  total: #{input.size}, saved: #{saved}"
end
