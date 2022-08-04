require "../src/bdata/ch_repo_2"

DIR = "var/chtexts"

def init_repo(sname : String)
  dir = "#{DIR}/#{sname}"
  ids = Dir.children(dir).map(&.to_i).sort!

  q_size = ids.size
  w_size = 6

  inp_ch = Channel(Int32).new(q_size)
  res_ch = Channel(Nil).new(w_size)

  spawn do
    ids.each { |id| inp_ch.send(id) }
  end

  w_size.times do
    spawn do
      loop do
        repo = CV::ChRepo2.new(sname, inp_ch.receive, reset: true)
        Log.info { [sname, repo.s_bid, repo.count] }
      ensure
        res_ch.send(nil)
      end
    end
  end

  q_size.times { res_ch.receive }
end

ARGV.each { |sname| init_repo(sname) }
