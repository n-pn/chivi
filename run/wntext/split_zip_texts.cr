require "colorize"

INP = "/2tb/var.chivi/_prev/ztext"
ZIP = "/www/chivi/xyz/wn/texts/zip"
MNT = "/www/chivi/xyz/wn/texts/mnt"

def split_and_zip(sname : String, sb_id : String)
  zip_dir = "#{ZIP}/#{sname}"
  Dir.mkdir_p(zip_dir)

  mnt_dir = "#{MNT}/#{sname}/#{sb_id}"
  Dir.mkdir_p(mnt_dir)
  File.touch("#{mnt_dir}/.keep")

  zip_file = "#{ZIP}/#{sname}/#{sb_id}.zip"
  puts `fuse-zip -o nonempty "#{zip_file}" "#{mnt_dir}"`

  inp_dir = "#{INP}/#{sname}/#{sb_id}"
  files = Dir.glob("#{inp_dir}/*.gbk")
  puts "#{inp_dir}: #{files.size}"

  files.each do |file|
    split_and_write(file, mnt_dir)
  rescue
    puts file.colorize.red
  end

  puts `fusermount -u "#{mnt_dir}"`
end

def split_and_write(file_path : String, mnt_dir : String)
  sc_id = File.basename(file_path, ".gbk")
  return if File.exists?("#{mnt_dir}/#{sc_id}.0.gbk")

  ztext = File.read(file_path, encoding: "GB18030")
  parts = ztext.split("\n\n")

  title = parts[0]

  parts[1..].each_with_index do |part, idx|
    File.open("#{mnt_dir}/#{sc_id}.#{idx}.gbk", "w", encoding: "GB18030") do |file|
      file << title
      file << " [#{idx + 1}/#{parts.size &- 1}]" if parts.size > 2
      file << '\n' << part
    end
  end
end

# seeds = Dir.children(INP).select!(&.starts_with?('@'))
seeds = ARGV

seeds.each do |sname|
  Dir.children("#{INP}/#{sname}").each do |sb_id|
    next if sb_id.includes?('.')

    split_and_zip sname, sb_id
  end
end
