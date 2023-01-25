require "sqlite3"
require "colorize"

def check(s_bid : String)
  puts "checking #{s_bid}"
  db_path = "var/chaps/infos/!hetushu/#{s_bid}-infos.db"

  unless File.file?(db_path)
    puts "#{db_path} is missing".colorize.red
    return
  end

  DB.open("sqlite3:#{db_path}") do |db|
    db.query_each "select s_cid, c_len from chaps" do |rs|
      s_cid, c_len = rs.read(Int32, Int32)

      txt_file = "var/chaps/bgtexts/hetushu/#{s_bid}/#{s_cid}.gbk"
      exists = File.file?(txt_file)

      if exists
        next if c_len > 0
        # puts "#{txt_file} need to be updated to db".colorize.yellow
      else
        puts "#{txt_file} is missing".colorize.red
        File.open("var/texts/hetushu-missing.tsv", "a") do |file|
          link = "https://www.hetushu.com/book/#{s_bid}/#{s_cid}.html"
          file.puts "#{link}\thetushu/#{s_bid}/#{s_cid}.html"
        end
      end
    end
  end
end

Dir.children("var/chaps/bgtexts/hetushu").each do |s_bid|
  check(s_bid)
end
