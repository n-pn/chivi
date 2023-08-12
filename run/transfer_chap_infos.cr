require "colorize"
require "../src/zroot/chlist"

INP = "var/zroot/remote"

def transfer_file(sname : String, inp_path : String)
  sn_id = File.basename(inp_path, ".db3")
  chlist = ZR::Chlist.new(sname, sn_id)

  chlist.zinfo_db.open_tx do |db|
    db.exec "attach database 'file:#{inp_path}?immutable=1' as src"
    db.exec <<-SQL
      replace into chinfos(ch_no, rpath, s_cid, title, chdiv)
      select ch_no, cpath as rpath, s_cid, ctitle as title, subdiv as chdiv
      from src.chaps
      SQL
  end

  File.rename(inp_path, inp_path + ".old")
end

def transfer(sname : String)
  inp_files = Dir.glob("#{INP}/#{sname}/*.db3")
  return if inp_files.empty?

  Dir.mkdir_p(ZR::Chlist.seed_path(sname))

  q_size = inp_files.size
  w_size = 6
  w_size = q_size if w_size > q_size

  puts "- #{sname}: #{q_size} entries"

  # inp_files.each_with_index(1) do |inp_file, index|
  #   transfer_file(sname, inp_file)
  #   puts "- <#{index}/#{q_size}: #{inp_file.colorize.green}"
  # rescue ex
  #   puts "- <#{index}/#{q_size}: #{inp_file} error: #{ex.colorize.red}"
  # end

  workers = Channel({String, Int32}).new(w_size)
  results = Channel(String).new(q_size)

  spawn do
    inp_files.each_with_index(1) { |inp_file, index| workers.send({inp_file, index}) }
  end

  w_size.times do
    spawn do
      loop do
        inp_file, index = workers.receive
        transfer_file(sname, inp_file)
        results.send("- <#{index}/#{q_size}: #{inp_file.colorize.green}")
      rescue ex
        results.send("- <#{index}/#{q_size}: #{inp_file} error: #{ex.colorize.red}")
      end
    end
  end

  q_size.times { puts results.receive }
end

snames = ARGV.select!(&.starts_with?('!'))
snames = Dir.children(INP) if snames.empty?
snames.each { |sname| transfer(sname) }
