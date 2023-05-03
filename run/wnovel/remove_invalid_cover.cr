require "colorize"
require "../../src/_data/_data"

input = PGDB.query_all <<-SQL, as: {Int32, String}
  select id, bcover from wninfos
  where scover <> '' and bcover <> ''
  order by id desc
SQL

w_size = 16
q_size = input.size

workers = Channel({Int32, String, Int32}).new(q_size)
results = Channel(Nil).new(w_size)

w_size.times do
  spawn do
    loop do
      wn_id, bcover, idx = workers.receive
      path = "var/files/covers/#{bcover}"

      if File.file?(path)
        ext = `gm identify "#{path}"`.split(/\s+/, 3)[1].downcase
      else
        ext = "none"
      end

      color = ext == "webp" ? :green : :red
      puts "- #{idx}/#{q_size} <#{wn_id}>: #{path} [#{ext}]".colorize(color)
      next if color == :green

      File.delete?(path)
      PGDB.exec "update wninfos set bcover = '' where id = $1", wn_id
    rescue err
      Log.error(exception: err) { err.message.colorize.red }
    ensure
      results.send(nil)
    end
  end
end

input.each_with_index(1) { |(wn_id, bcover), idx| workers.send({wn_id, bcover, idx}) }
q_size.times { results.receive }
