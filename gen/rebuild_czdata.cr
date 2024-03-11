require "../src/rdapp/data/czdata"

DIR = "/2tb/zroot/wn_db"

all_snames = Dir.children(DIR)
snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--users")
  users = all_snames.select(&.starts_with?('@'))
  snames.concat users
end

DELETE = ARGV.includes?("--delete")

snames.each do |sname|
  old_paths = Dir.glob("#{DIR}/#{sname}/*-zdata.v1.db3")

  old_paths.each do |old_path|
    czdata = RD::Czdata.load_old_db(old_path)

    RD::Czdata.db(old_path.sub(".v1.db3", ".db3")).open_tx do |db|
      czdata.each(&.upsert!(db: db))
    end

    puts "#{old_path}: #{czdata.size} exported"

    if DELETE
      File.delete(old_path)
    else
      File.rename(old_path, old_path + ".old")
    end
  end
end
