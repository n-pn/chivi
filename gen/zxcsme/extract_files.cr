require "colorize"
require "file_utils"
require "compress/zip"

require "../../src/_util/file_util"
require "../../src/_util/char_util"
require "../../src/rdapp/data/chinfo"
require "../../src/rdapp/_raw/rmhost"

RARS_DIR = "/www/chivi/xyz/seeds/zxcs.me/_rars"
TEMP_DIR = "/www/chivi/xyz/seeds/zxcs.me/_temp"
TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"

FILE_RE_1 = /《(.+)》.+作者：(.+)\./
FILE_RE_2 = /《(.+)》(.+)\.txt/

def read_clean(inp_file : String)
  lines = FileUtil.read_utf8(inp_file).strip.split(/\R/)

  if lines.first.starts_with?("===")
    lines.shift

    while line = lines.shift?
      break if line.starts_with?("===")
    end

    if lines.last.starts_with?("===")
      lines.pop

      while line = lines.pop?
        break if line.starts_with?("===")
      end
    end
  end

  if match = FILE_RE_1.match(inp_file) || FILE_RE_2.match(inp_file)
    _, title, author = match
  else
    puts "invalid file name!".colorize.red
    exit 0
  end

  if lines[1].matches?(/^作者[[:punct:]]/)
    lines.shift
    lines.shift
  end

  while garbage?(lines.first, title, author)
    lines.shift
  end

  while garbage_end?(lines.last)
    lines.pop
  end

  lines
end

def garbage?(line : String, title : String, author : String)
  return true if garbage_end?(line)

  {
    /^#{title}/,
    /《#{title}》/,
    /书名[[:punct:]]/,
    /作者[[:punct:]]/,
    /^分类[[:punct:]]/,
    /^字数[[:punct:]]/,
  }.any?(&.matches?(line))
end

def garbage_end?(line : String)
  line.empty? || line.starts_with?("更多精校小说")
end

def extract_rar!(rar_file : String, label = "1/1")
  sn_id = File.basename(rar_file, ".rar")
  out_path = "#{TEXT_DIR}/#{sn_id}.txt"

  return if File.exists?(out_path)
  puts "\n- <#{label}> extracting #{rar_file.colorize.blue}"

  tmp_dir = "#{TEMP_DIR}/#{sn_id}"
  Dir.mkdir_p(tmp_dir)

  `unrar e -o+ "#{rar_file}" #{tmp_dir}`
  txt_path = Dir.glob("#{tmp_dir}/*.{txt,TXT}").first

  lines = read_clean(txt_path).join("\n")
  File.write(out_path, lines)

  FileUtils.rm_rf(tmp_dir)
  out_path
rescue err
  puts err
end

inputs = Dir.glob("#{RARS_DIR}/*.rar")

inputs.sort_by! { |x| File.basename(x, ".rar").to_i.- }

inputs.each_with_index(1) do |rar_file, idx|
  next unless file = extract_rar!(rar_file, label: "#{idx}/#{inputs.size}")
  puts "#{file} saved!"
end

`python3 run/zxcsme/fix_mtime.py`
