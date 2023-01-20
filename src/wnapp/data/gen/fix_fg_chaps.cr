require "sqlite3"
require "colorize"

snames = Dir.children("var/chaps/infos")
snames.reject!(&.[0].in?('!', '+'))
snames.sort!.each { |sname| fix_all(sname) }

def fix_all(sname : String)
  files = Dir.glob("var/chaps/infos/#{sname}/*-infos.db")
  puts [sname, files.size]

  workers = Channel({String, Int32}).new(files.size)

  threads = 6
  results = Channel(Nil).new(threads)

  threads.times do
    spawn do
      loop do
        file, idx = workers.receive
        fix_one(file)
        puts " - <#{idx}/#{files.size}> [#{file}]"
      rescue err
        puts "#{file}, #{err.message} ".colorize.red
      ensure
        results.send(nil)
      end
    end
  end

  files.each_with_index(1) { |file, idx| workers.send({file, idx}) }
  files.size.times { results.receive }

  files.each { |file| fix_one(file) }
end

def fix_one(file : String)
  puts file
  old_file = file.sub("chaps/infos", "chaps/infos-fg")
  mtime = File.info(old_file).modification_time
  File.utime(mtime, mtime, file)

  # DB.open("sqlite3:#{file}") do |db|
  #   data = db.query_all "select ch_no, _path from chaps where _path like 'bg%'", as: {Int32, String}
  #   return if data.empty?

  #   data.map! do |ch_no, path|
  #     _, sname, s_bid, chidx, s_cid = path.split(':')
  #     sname = sname[0] == '@' ? "+" + sname[1..] : "!" + sname
  #     path = "#{sname}/#{s_bid}/#{s_cid}:#{chidx}"

  #     {ch_no, path}
  #   end

  #   db.exec "pragma synchronous = normal"
  #   db.exec "begin"
  #   data.each do |ch_no, path|
  #     db.exec "update chaps set _path = ? where ch_no = ?", path, ch_no
  #   end
  #   db.exec "commit"
  # rescue
  #   File.delete(file)
  # end
end
