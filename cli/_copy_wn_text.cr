require "sqlite3"
require "colorize"

TXT_DIR = "var/texts/rgbks"

def copy_book(sname : String, s_bid : String)
  queue = [] of {String, String}

  out_dir = "#{TXT_DIR}/#{sname}/#{s_bid}"
  Dir.mkdir_p(out_dir)

  db_path = "sqlite3:var/chaps/infos/#{sname}/#{s_bid}.db"
  DB.open(db_path) do |db|
    db.query_each "select ch_no, _path from chaps" do |rs|
      ch_no, _path = rs.read(Int32, String)
      next unless _path[0]?.in?('+', '!', '@')

      inp_path = "#{TXT_DIR}/#{_path.split(':').first}.gbk"
      out_path = "#{out_dir}/#{ch_no}.gbk"
      next if File.file?(out_path)

      queue << {inp_path, out_path}
    end
  end

  return if queue.empty?

  puts "#{sname}/#{s_bid}: #{queue.size}"

  workers = Channel({String, String, Int32}).new(queue.size)

  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        inp_file, out_file, idx = workers.receive

        if !File.file?(inp_file)
          puts "#{inp_file} not existed, skipping!".colorize.red
        else
          File.link(inp_file, out_file)
          puts "#{idx}/#{queue.size}: #{inp_file} => #{out_file}".colorize.green
        end
      rescue err
        puts err, out_file
      ensure
        results.send(nil)
      end
    end
  end

  queue.each_with_index(1) { |(inp_file, out_file), idx| workers.send({inp_file, out_file, idx}) }
  queue.size.times { results.receive }
end

copy_book(ARGV[0], ARGV[1])
