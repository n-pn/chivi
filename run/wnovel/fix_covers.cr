require "colorize"
require "../../src/_data/_data"
require "../../src/_util/hash_util"

def cache_cover(scover : String) : String
  bcover = HashUtil.digest32(scover, 8)
  `./bin/bcover_cli -i '#{scover}' -n '#{bcover}'`
  $?.success? ? "#{bcover}.webp" : ""
end

input = PGDB.query_all <<-SQL, as: {Int32, String}
  select id, scover from nvinfos
  where scover <> '' and bcover = ''
SQL

input.shuffle!

w_size = 16
q_size = input.size

workers = Channel({Int32, String, Int32}).new(q_size)
results = Channel(Nil).new(w_size)

w_size.times do
  spawn do
    loop do
      wn_id, scover, idx = workers.receive
      bcover = cache_cover(scover)
      PGDB.exec "update nvinfos set bcover = $1 where id = $2", bcover, wn_id
      puts "- #{idx}/#{q_size} <#{wn_id}> #{scover.colorize.blue} => [#{bcover.colorize.yellow}]"
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

input.each_with_index(1) { |(wn_id, scover), idx| workers.send({wn_id, scover, idx}) }
q_size.times { results.receive }
