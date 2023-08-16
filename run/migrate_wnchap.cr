require "../src/wnapp/data/chinfo"

OLD_DIR = "/2tb/app.chivi/var/zchap/infos"

def import_seed(sname : String)
  Dir.mkdir_p("var/zroot/wnchap/#{sname}")

  files = Dir.glob("#{OLD_DIR}/#{sname}/*.db")

  files.each do |old_db|
    sn_id = File.basename(old_db, ".db").sub("-infos", "")

    if WN::Chinfo.init!(sname, sn_id)
      puts "- imported #{old_db}".colorize.green
    else
      puts "- not imported #{old_db}".colorize.blue
    end
  rescue ex
    puts "#{old_db} error: #{ex}".colorize.red
  end
end

snames = ARGV.reject(&.starts_with?('-'))
snames = Dir.children(OLD_DIR) if snames.empty?

snames.select!(&.starts_with?('@')) if ARGV.includes?("--user")
snames.select!(&.starts_with?('!')) if ARGV.includes?("--glob")

snames.each { |sname| import_seed sname }
