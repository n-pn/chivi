require "colorize"
require "file_utils"
require "compress/zip"

require "../../src/_util/file_util"
require "../../src/_util/char_util"
require "../../src/rdapp/data/chinfo"
require "../../src/rdapp/_raw/rmhost"

class Czinfo
  include Crorm::Model
  schema "chinfos", :sqlite, multi: true

  field ch_no : Int32, pkey: true
  field title : String
  field chdiv : String
  field mtime : Int64

  def initialize(@ch_no, @title, @chdiv, @mtime)
  end

  PATCH_SQL = <<-SQL
    insert into chinfos(ch_no, spath, ztitle, zchdiv, mtime)
    values ($1, $2, $3, $4, $5)
    SQL

  def upsert!(db, sname, sn_id)
    db.exec PATCH_SQL, @ch_no, "rm!zxcs.me/#{sn_id}/#{ch_no}", @title, @chdiv, @mtime
  end
end

struct Cinput
  property chdiv : String
  property lines : Array(String)
  getter title : String { lines[0]? || "" }

  def initialize(@chdiv, @lines)
  end
end

TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"
SAVE_DIR = "/www/chivi/xyz/seeds/zxcs.me/split"

SKIP_CHOICE = ARGV.includes?("--skip")

def split_chaps!(inp_file : String, label = "1/1")
  sn_id = File.basename(inp_file, ".txt")

  meta_file = File.join(SAVE_DIR, "#{sn_id}.jsonl")
  return if File.file?(meta_file)

  input = File.read(inp_file).split(/\R/)

  puts "\n- <#{label}> [#{TEXT_DIR}/#{sn_id}.txt] #{input.size} lines".colorize.yellow

  return unless chaps = split_chapters(sn_id, input)

  chaps = cleanup_chaps(chaps)
  mtime = File.info(inp_file).modification_time.to_unix

  infos = chaps.map_with_index(1) do |chap, idx|
    Czinfo.new(idx, chap.title, chap.chdiv, mtime)
  end

  save_dir = File.join(SAVE_DIR, sn_id)

  if good_enough?(infos)
    save_texts!(chaps, save_dir)
    File.write(meta_file, infos.map(&.to_json).join('\n'))
    return
  end

  return puts "  Skipped".colorize.red if SKIP_CHOICE

  print "\nChoice (r: redo, d: delete, s: delete + exit, else: keep): "

  STDIN.flush
  case char = STDIN.raw(&.read_char)
  when 'd', 's', 'r'
    FileUtils.rm_rf(save_dir)
    puts "\n\n- [#{save_dir}] deleted! (choice: #{char})".colorize.red

    if char == 'r'
      split_chaps!(inp_file, label)
    elsif char == 's'
      exit(0)
    end
  else
    save_texts!(chaps, save_dir)
    File.write(meta_file, infos.map(&.to_json).join('\n'))

    puts "\n\n- Entries [#{sn_id}] saved!".colorize.yellow
  end
end

def save_texts!(chaps, out_dir)
  Dir.mkdir_p(out_dir)
  chaps.each_with_index(1) do |cdata, ch_no|
    File.write("#{out_dir}/#{ch_no}.txt", cdata.lines.join('\n'))
  end
end

# ameba:disable Metrics/CyclomaticComplexity
def split_chapters(sn_id : String, lines : Array(String))
  case sn_id
  when "4683", "3868", "4314", "3199", "4942", "1552"
    return split_blanks(lines)
  when "3401"
    return split_delimit(lines)
  end

  blanks_single, blanks_double, blanks_count = 0, 0, 0
  unnest_count, nested_count = 0, 0

  lines.each_with_index do |line, idx|
    break if idx > 1000

    if line.empty?
      blanks_count += 1
      next
    end

    if blanks_count > 1
      blanks_double += 1
    elsif blanks_count > 0
      blanks_single += 1
    end

    blanks_count = 0

    if nested?(line)
      nested_count += 1
    else
      unnest_count += 1
    end
  end

  return split_blanks(lines) if blanks_double > 1
  return split_nested(lines) if nested_count > 1 && unnest_count > 1

  if unnest_count == 0
    return split_delimit(lines) if blanks_single > 0
  end

  puts "-- [ unsupported file format, skipping! ]".colorize.cyan
  nil
end

def split_blanks(input : Array(String))
  chaps = [] of Array(String)
  lines = [] of String

  empty_count = 0

  input.each do |line|
    line = line.tr("　", " ").strip

    if line.empty?
      empty_count += 1
      next
    end

    if empty_count > 1 && !lines.empty?
      chaps << lines
      lines = [] of String
    end

    empty_count = 0
    lines << line
  end

  chaps << lines unless lines.empty?

  chaps
end

def nested?(line : String)
  line =~ /^[　\s]{2,}/
end

def split_nested(input : Array(String))
  chaps = [] of Array(String)
  lines = [] of String

  input.each do |line|
    next if line.empty?

    unless lines.empty? || nested?(line)
      chaps << lines
      lines = [] of String
    end

    lines << line.strip
  end

  chaps << lines unless lines.empty?

  puts "-- [ splited nested: #{chaps.size} chaps ]".colorize.cyan
  chaps
end

def split_nested(input : Array(String))
  chaps = [] of Array(String)
  lines = [] of String

  input.each do |line|
    next if line.empty?

    unless lines.empty? || nested?(line)
      chaps << lines
      lines = [] of String
    end

    lines << line.strip
  end

  chaps << lines unless lines.empty?

  puts "-- [ splited nested: #{chaps.size} chaps ]".colorize.cyan
  chaps
end

def split_delimit(input : Array(String))
  chaps = [] of Array(String)
  lines = [] of String

  input.each do |line|
    if line.empty?
      if lines.size > 1
        chaps << lines
        lines = [] of String
      end
    else
      lines << line.strip
    end
  end

  chaps << lines unless lines.empty?

  puts "-- [ splited delimit: #{chaps.size} chaps ]".colorize.cyan
  chaps
end

def cleanup_chaps(input : Array(Array(String)))
  while intro_name?(input.first)
    input.shift
  end

  chaps = [] of Cinput
  chdiv = ""

  input.each do |lines|
    if lines.size == 1
      chdiv = lines.first
    else
      chaps << Cinput.new(chdiv.strip, lines.map(&.strip))
    end
  end

  chaps
end

INTROS = {
  "简介：",
  "介绍：",
  "内容概要：",
  "作品介绍",
  "作品简介",
  "作者简介",
  "内容简介",
  "内容介绍",
  "内容说明",
  "书籍介绍",
  "书籍简介",
  "小说简介",
}

def intro_name?(chap : Array(String))
  return true if chap.last =~ /^作者：/
  INTROS.any? { |x| chap.first.includes?(x) }
end

def good_enough?(infos : Array(Czinfo))
  last = infos.last
  return true if last.title.includes?("第#{last.ch_no}章")

  bads = [] of String

  infos.each do |cinfo|
    case cinfo.chdiv
    when "序", "外传", "番外", "外篇", "番外篇",
         "作品相关", "【作品相关】"
      next
    else
      if cinfo.chdiv.size > 20
        bads << "#{cinfo.title} -- #{cinfo.chdiv}"
        next
      end
    end

    case cinfo.title
    when "引言", "结束语", "引 子", "开始", "感言", "前言",
         "锲子", "结语", "楔子", "作者的话", "小结",
         .includes?("后记"),
         .includes?("完本了"),
         .includes?("作品相关"),
         .includes?("结束感言"),
         .includes?("完本感言"),
         .includes?("完结感言"),
         .includes?("完稿感言"),
         .includes?("完稿感言"),
         .includes?("结后感言"),
         .includes?("全本感言"),
         .includes?("次卷预告"),
         .includes?("写在结束的话"),
         .=~(/^【?(序|第|终卷|楔子|引子|尾声|番外|终章|末章|终曲|后记|后续|结局)/),
         .=~(/^【?(前记|篇外|前言|后篇|外传|尾章|初章|引章|卷末|最终回|最终章|终结章|终之章|大结局|人物介绍|更新说明)/),
         .=~(/^\d+、/),
         .=~(/^[【\[\(]\d+[】\]\)]/),
         .=~(/^章?[零〇一二两三四五六七八九十百千+]^/)
      next
    else
      bads << "#{cinfo.title} -- #{cinfo.chdiv}"
    end
  end

  if bads.empty?
    puts "\nSeems good enough, skip checking!".colorize.green
    true
  else
    puts "\n- wrong format (#{bads.size}): ", bads.first(30).join("\n\n").colorize.red
    false
  end
end

inp_files = Dir.glob("#{TEXT_DIR}/*.txt").sort_by! { |x| File.basename(x, ".txt").to_i.- }

inp_files.each_with_index do |inp_file, index|
  split_chaps!(inp_file, "#{index}/#{inp_files.size}")
end
