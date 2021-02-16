require "colorize"
require "file_utils"

INP = "_db/chdata/zhtexts"

OUT_ZIP = "_db/chdata/zh_zips"
OUT_TXT = "_db/chdata/zh_txts"

def move_seed(sname : String)
  dir = File.join(INP, sname)

  paths = Dir.children(dir)
  paths.each_with_index(1) do |path, idx|
    path = File.join(dir, path)

    if File.directory?(path)
      out_path = path.sub(INP, OUT_TXT)
    elsif path.ends_with?(".zip")
      out_path = path.sub(INP, OUT_ZIP)
    else
      next
    end

    puts "- <#{idx}/#{paths.size}> #{path} => #{out_path}".colorize.blue

    FileUtils.mkdir_p(File.dirname(out_path))
    FileUtils.mv(path, out_path)

    # break if idx > 1
  end
end

Dir.children(INP).each do |sname|
  move_seed(sname)
end
