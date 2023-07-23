require "../src/_data/wnovel/wncata"

OLD = "var/chaps/infos"

def newer_file?(file_a : String, file_b : String)
  return true unless b_info = File.info?(file_b)
  File.info(file_a).modification_time > b_info.modification_time
end

def migrate_vi_db(new_sname : String, wn_id : Int32,
                  old_sname = new_sname, s_bid = wn_id)
  db_path = Wncata.db_path(wn_id, new_sname)
  Dir.mkdir_p(File.dirname(db_path))

  old_db_path = "#{OLD}/#{old_sname}/#{s_bid}.db"
  return if File.size(old_db_path) < 10

  return unless newer_file?(old_db_path, db_path)

  target = Wncata.load(wn_id, new_sname)
  target.import_old_vi_db(old_db_path)

  puts "- migrate from #{old_db_path} to #{target.db_path}"
rescue err
  puts [new_sname, wn_id]
end

def migrate_zh_db(new_sname : String, wn_id : Int32,
                  old_sname = new_sname, s_bid = wn_id)
  db_path = Wncata.db_path(wn_id, new_sname)
  Dir.mkdir_p(File.dirname(db_path))

  old_db_path = "#{OLD}/#{old_sname}/#{s_bid}-infos.db"
  return if File.size(old_db_path) < 10

  return unless newer_file?(old_db_path, db_path)

  target = Wncata.load(wn_id, new_sname)
  target.import_old_zh_db(old_db_path)

  puts "- migrate from #{old_db_path} to #{target.db_path}"
rescue err
  puts [new_sname, wn_id]
end

def import_all(new_sname : String, old_sname = new_sname)
  files = Dir.children("#{OLD}/#{old_sname}")
  puts "import from #{old_sname} to #{new_sname}: #{files.size} entries"

  files.each do |file|
    next unless file.ends_with?(".db")
    next unless file.ends_with?("-infos.db")
    wn_id = File.basename(file, "-infos.db").to_i
    next if wn_id < 1
    migrate_zh_db new_sname, wn_id, old_sname
  end
end

import_all("~draft", "_")

Dir.children(OLD).each do |fname|
  next unless fname.starts_with?('@')
  import_all(fname)
end
