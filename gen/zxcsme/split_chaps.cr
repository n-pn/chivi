require "colorize"
require "file_utils"
require "compress/zip"

ENV["CZ_DIR"] = "/mnt/serve/chivi.app/texts"

require "../../src/_util/file_util"
require "../../src/rdapp/data/czdata"

TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"
SAVE_DIR = "/mnt/serve/chivi.app/texts/!zxcs.me"

SKIP_CHOICE = ARGV.includes?("--skip")

def split_chaps!(fpath : String, label = "1/1")
  sn_id = File.basename(fpath, ".txt").to_i
  lines = File.read(fpath).split(/\R/)

  puts "\n- <#{label}> [#{fpath}] #{lines.size} lines".colorize.blue
  return unless chaps = split_chapters(sn_id, lines)

  mtime = File.info(fpath).modification_time.to_unix
  chaps = call_splitter(chaps, sn_id, mtime)

  return save_data!(fpath, chaps) if good_enough?(chaps)
  return puts "  -- Skipped".colorize.red if SKIP_CHOICE

  print "\nChoice (y: keep, r: redo, d: delete, else: exit): "

  STDIN.flush
  case STDIN.raw(&.read_char)
  when ' ', 'y' # is valid good
    save_data!(fpath, chaps)
  when 'f'
    chaps.shift
    chaps.each { |x| x.ch_no -= 1 }
    puts "\n - delete first chapter!".colorize.green
    save_data!(fpath, chaps)
  when 'r'
    puts "\n - Redo...!"
    split_chaps!(fpath, label)
  when 'x'
    puts "\n - Exiting!"
    exit(0)
  else
    puts "\n - Skipped!"
  end
end

def save_data!(fpath, chaps)
  db_path = fpath.sub(".txt", ".db3")
  RD::Czdata.db(db_path).open_tx { |db| chaps.each(&.upsert!(db: db)) }
  puts "\n\n- [#{db_path}] saved!".colorize.yellow
end

# ameba:disable Metrics/CyclomaticComplexity
def split_chapters(sn_id : Int32, lines : Array(String))
  case sn_id
  when 4683, 3868, 4314, 3199, 4942, 1552
    return split_blanks(lines)
  when 4219
    return split_nested(lines)
  when 3401
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
  return split_delimit(lines) if unnest_count == 0 && blanks_single > 0

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

    lines << line.tr("　", " ").strip
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
      lines << line.tr("　", " ").strip
    end
  end

  chaps << lines unless lines.empty?

  puts "-- [ splited delimit: #{chaps.size} chaps ]".colorize.cyan
  chaps
end

def call_splitter(input : Array(Array(String)), sn_id : Int32, mtime : Int64)
  while intro_name?(input.first)
    input.shift
  end

  chaps = [] of RD::Czdata
  chdiv = ""
  prev_was_chdiv = false

  input.each do |cbody|
    if cbody.size == 1
      raise "invalid #{cbody}" if prev_was_chdiv
      chdiv = cbody.first.strip
      prev_was_chdiv = true
      next
    end

    ch_no = chaps.size &+ 1
    prev_was_chdiv = false

    chaps << RD::Czdata.new(
      ch_no: ch_no,
      title: cbody[0],
      chdiv: chdiv,
      zorig: "!zxcs.me/#{sn_id}",
      mtime: mtime,
      ztext: cbody.join('\n'),
    )
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
  "【内容简介】",
}
INTRO_RE = Regex.new("#{INTROS.join('|')}")

def intro_name?(chap : Array(String))
  return true if chap.last =~ /^作者：/
  chap.first.starts_with?(INTRO_RE)
end

def good_enough?(infos : Array(RD::Czdata))
  last = infos.last
  return true if last.title.includes?("第#{last.ch_no}章")

  bads = [] of RD::Czdata

  infos.each do |cinfo|
    case cinfo.chdiv
    when "序", "外传", "番外", "外篇", "番外篇",
         "作品相关", "【作品相关】", .starts_with?('【')
      next
    else
      if cinfo.chdiv.size > 20
        bads << cinfo
        next
      end
    end

    case cinfo.title
    when .includes?(' '), .includes?("番外"), .starts_with?('【')
      next
    when .matches?(/^(契子|梗子|引言|结束语|引 子|开始|感言|前言|锲子|结语|楔子|作者的话|小结|故事简介|完本公告|完本说明)$/),
         .matches?(/(再见|外传|后话|封信|感言|开篇|自序)$/),
         .matches?(/作品相关|次卷预告|写在结束的话/),
         .matches?(/^【?(序|第|终卷|楔子|引子|尾声|番外|终章|末章|终曲|后记|后续|结局|最后|外篇|终局|特别篇|完本)/),
         .matches?(/^【?(前记|篇外|前言|后篇|外传|尾章|初章|引章|卷末|最终回|最终章|终结章|终之章|大结局|人物介绍|更新说明)/),
         .matches?(/^\d+、|^\d+$/),
         .matches?(/^[【\[\(]\d+[】\]\)]/),
         .matches?(/^章?[零〇一二两三四五六七八九十百千+]^/)
      next
    else
      bads << cinfo
    end
  end

  if bads.empty?
    puts "\nSeems good enough, skip checking!".colorize.green
    true
  elsif bads.size == 1 && bads.first.ch_no == 1
    infos.first(4).each do |cinfo|
      puts "\n-------"
      puts "title: #{cinfo.title.colorize.yellow}"
      puts "chdiv: #{cinfo.chdiv.colorize.yellow}"
      puts "ztext: #{cinfo.cbody.try(&.[0..300])}" if cinfo.ch_no == 1
      puts "ch_no: #{cinfo.ch_no.colorize.cyan}, zsize: #{cinfo.zsize.colorize.cyan}"
    end
    false
  else
    puts "\n- wrong format (#{bads.size}): ".colorize.red
    bads.first(20).each do |cinfo|
      puts "--"
      puts "title: #{cinfo.title.colorize.red}"
      puts "chdiv: #{cinfo.chdiv.colorize.red}"
      puts "ztext: #{cinfo.cbody.try(&.[0..20])}"
      puts "ch_no: #{cinfo.ch_no.colorize.cyan}, zsize: #{cinfo.zsize.colorize.cyan}"
    end

    false
  end
end

inputs = Dir.glob("#{TEXT_DIR}/*.txt")
inputs.reject! do |fpath|
  File.file?(fpath.sub(".txt", ".db3"))
end

inputs.each_with_index do |fpath, index|
  split_chaps!(fpath, "#{index}/#{inputs.size}")
rescue ex
  puts ex
end
