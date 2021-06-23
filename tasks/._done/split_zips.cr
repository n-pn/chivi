require "file_utils"

ZIP_DIR = "_db/chdata/zh_zips"
BAK_DIR = "_db/chdata/backups"
TXT_DIR = "_db/chdata/zh_txts"

def bak_path(zseed, snvid)
  File.join(DIR, "backups", zseed, "#{snvid}/")
end

def txt_path(zseed, snvid)
  File.join(DIR, "zh_txts", zseed, "#{snvid}/")
end

def unzip_file(inp_file, out_dir, delete = false)
  `unzip -o "#{inp_file}" -d "#{out_dir}"`
  FileUtils.mv(inp_file, inp_file.sub(ZIP_DIR, BAK_DIR)) if delete
end

def unzip_seed(zseed)
  FileUtils.mkdir_p(File.join(BAK_DIR, zseed))

  files = Dir.glob(File.join(ZIP_DIR, zseed, "*.zip"))

  files.each_with_index do |inp_file, idx|
    puts "- <#{idx}/#{files.size}> #{inp_file}"

    out_dir = File.join(TXT_DIR, zseed, File.basename(inp_file, ".zip"))
    unzip_file(inp_file, out_dir, delete: true)
  end
end

zseeds = ARGV.empty? ? Dir.children(ZIP_DIR) : ARGV
zseeds.each { |zseed| unzip_seed(zseed) }
