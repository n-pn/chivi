require "sqlite3"

DIR = "var/dicts/entdb"

def extract(out_name, ent_name)
  puts "#{ent_name} => #{out_name}"
  DB.open("sqlite3:#{DIR}/#{out_name}.dic") do |db|
    db.exec "attach database '#{DIR}/0_rest.dic' as src"
    op = ent_name.ends_with?('%') ? "like" : "="
    db.exec "create table if not exists ent_freqs as select * from src.ent_freqs where false"
    db.exec "insert into ent_freqs select * from src.ent_freqs where etag #{op} '#{ent_name}'"
    db.exec "delete from src.ent_freqs where etag #{op} '#{ent_name}'"
  end
end

extract("business", "business.%")
