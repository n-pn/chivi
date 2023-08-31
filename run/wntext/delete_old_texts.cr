OLD_DIR = "/mnt/serve/chivi.all/ztext"
NEW_DIR = "/2tb/var.chivi/zroot/wntext"

def delete_from(sname : String, sn_id : String)
  old_dir = "#{OLD_DIR}/#{sname}/#{sn_id}"
  new_dir = "#{NEW_DIR}/#{sname}/#{sn_id}"

  return unless File.directory?(old_dir)

  old_files = Dir.children(old_dir)
  new_files = Dir.children(new_dir)

  puts "- <#{sname}/#{sn_id}> new: #{new_files.size}, old: #{old_files.size}"
  return if new_files.empty? || old_files.empty?

  new_files.each do |new_file|
    cols = new_file.split('-')

    if cols.size != 3
      puts "invalid new_file: #{new_file}"
      File.delete("#{new_dir}/#{new_file}")
    else
      sc_id = cols[0]

      File.delete? "#{old_dir}/#{sc_id}.gbk"
      File.delete? "#{old_dir}/#{sc_id}.txt"
    end
  end

  old_files = Dir.children(old_dir)
  puts "  remain undeleted: #{old_files.size} files"
end

def delete_from(sname : String)
  Dir.each_child("#{NEW_DIR}/#{sname}") do |sn_id|
    delete_from(sname, sn_id)
  end
end

snames = ARGV.reject(&.starts_with?('-'))
all_snames = Dir.children(NEW_DIR)

if ARGV.includes?("--globs")
  snames.concat all_snames.select(&.starts_with?('!'))
end

if ARGV.includes?("--users")
  snames.concat all_snames.select(&.starts_with?('@'))
end

snames = all_snames if snames.empty?
snames.each { |sname| delete_from sname }
