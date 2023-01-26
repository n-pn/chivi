def copy_seed(sname : String)
  Dir.glob("var/chaps/infos/#{sname}/*-infos.db").each do |file|
    puts file
    s_bid = File.basename(file, "-infos.db")
    Process.run("./bin/copy_book_text", args: {sname, s_bid}, output: :inherit)
  end
end

copy_seed("_")

# snames = ARGV
snames = Dir.children("var/chaps/infos")

snames.each do |sname|
  copy_seed(sname) if sname[0] == '@'
end
