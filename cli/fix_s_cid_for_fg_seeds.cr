require "sqlite3"

INP = "var/chaps/infos"

def fix_seed(sname : String)
  `find '#{INP}/#{sname}' -name '*-trans.db' -delete`

  files = Dir.glob("#{INP}/#{sname}/*-infos.db")
  files.each do |file|
    puts file

    DB.open("sqlite3:#{file}") do |db|
      db.exec "begin"
      db.exec "update chaps set s_cid = ch_no where s_cid <> ch_no"
      db.exec "commit"
    end
  end
end

snames = Dir.children(INP)
snames.select!(&.[0].in?('_', '@'))
snames.each { |sname| fix_seed(sname) }
