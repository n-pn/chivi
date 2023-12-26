require "sqlite3"
require "colorize"
require "../../src/_util/char_util"
require "../../src/_util/chap_util"

record Cztext, ch_no : Int32, zchdiv : String, cksum : String, mtime : Int64 do
  include DB::Serializable
end

def export(db_path : String)
  txt_dir = db_path.sub("stems", "texts").sub("-cinfo.db3", "")
  files = Dir.glob("#{txt_dir}/*.raw.txt")
  return if files.empty?

  cinfos = DB.open("sqlite3:#{db_path}?immutable=1") do |db|
    query = "select ch_no, cksum, zchdiv, mtime from chinfos"
    db.query_all(query, as: Cztext).to_h { |x| {"#{x.ch_no}-#{x.cksum}", x} }
  end

  puts "#{db_path}: #{cinfos.size} files"
  return if cinfos.empty?

  sname = File.basename(File.dirname(db_path)).sub(/^wn|rm|up/, "")
  sn_id = File.basename(db_path, "-cinfo.db3")

  input = files.group_by do |file|
    File.basename(file).sub(/-\d+\.raw\.txt$/, "")
  end

  out_dir = "/2tb/zroot/ztext/#{sname}/#{sn_id}"
  Dir.mkdir_p(out_dir)

  input.each do |index, files|
    unless cinfo = cinfos[index]?
      puts "#{txt_dir}/#{index} is unmapped"
      next
    end

    parts, _, _ = ChapUtil.split_cztext(read_files(files).lines)

    out_file = "#{out_dir}/#{cinfo.ch_no}0.zh"
    File.open(out_file, "w") do |file|
      file.puts "///#{cinfo.zchdiv}"
      file << parts
    end

    utime = Time.unix(cinfo.mtime)
    File.utime(utime, utime, out_file)
  rescue ex
    puts files, ex.colorize.red
  end

  `zip -FSrjyomq '#{out_dir}.zip' '#{out_dir}'`
end

def read_files(files : Array(String))
  files.sort_by! do |file|
    file.split(/\D+/, remove_empty: true).last.to_i
  end

  files.shift if files[0].ends_with?("0.raw.txt")

  String.build do |io|
    files.each_with_index(1) do |file, i|
      raise "invalid #{file}" unless file.ends_with?("#{i}.raw.txt")

      data = File.read(file)
      data = data.sub(/^.+\n/, "") if i > 1
      io << CharUtil.normalize(data)
    end
  end
end

# export "/2tb/var.chivi/stems/up@Nipin/3-cinfo.db3"
# exit

INP = "/2tb/var.chivi/stems"

snames = ARGV.reject(&.starts_with?('-'))

if ARGV.includes?("--up")
  snames.concat Dir.children(INP).select(&.starts_with?("up"))
end

if ARGV.includes?("--rm")
  snames.concat Dir.children(INP).select(&.starts_with?("rm"))
end

snames.each do |sname|
  files = Dir.glob("#{INP}/#{sname}/*-cinfo.db3")
  puts "#{sname}: #{files.size} files"

  files.each do |file|
    export(file)
  rescue ex
    puts ex.colorize.red
  end
end
