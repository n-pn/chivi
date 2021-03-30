require "file_utils"

ZIP_DIR = "_db/chdata/zh_zips"
BAK_DIR = "_db/chdata/backups"
TXT_DIR = "_db/chdata/zh_txts"

def bak_path(sname, snvid)
  File.join(DIR, "backups", sname, "#{snvid}/")
end

def txt_path(sname, snvid)
  File.join(DIR, "zh_txts", sname, "#{snvid}/")
end

def unzip_file(inp_file, out_dir, delete = false)
  `unzip -o "#{inp_file}" -d "#{out_dir}"`
  FileUtils.mv(inp_file, inp_file.sub(ZIP_DIR, BAK_DIR)) if delete
end

def unzip_seed(sname)
  FileUtils.mkdir_p(File.join(BAK_DIR, sname))

  files = Dir.glob(File.join(ZIP_DIR, sname, "*.zip"))

  files.each_with_index do |inp_file, idx|
    puts "- <#{idx}/#{files.size}> #{inp_file}"

    out_dir = File.join(TXT_DIR, sname, File.basename(inp_file, ".zip"))
    unzip_file(inp_file, out_dir, delete: true)
  end
end

snames = ARGV.empty? ? Dir.children(ZIP_DIR) : ARGV
snames.each { |sname| unzip_seed(sname) }
