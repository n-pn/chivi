require "colorize"
require "file_utils"
require "compress/zip"

ENV["CZ_DIR"] = "/mnt/serve/chivi.app/texts"

require "../../src/_util/file_util"
require "../../src/rdapp/data/czdata"

TEXT_DIR = "/www/chivi/xyz/seeds/zxcs.me/texts"
SAVE_DIR = "/mnt/serve/chivi.app/texts/!zxcs.me"

SKIP_CHOICE = ARGV.includes?("--skip")

def split_chaps!(sn_id : Int32, label = "1/1")
  inp_file = "#{TEXT_DIR}/#{sn_id}.txt"
  input = File.read(inp_file).split(/\R/)

  puts "\n- <#{label}> [#{inp_file}] #{input.size} lines".colorize.yellow
  return unless chaps = split_chapters(sn_id, input)

  mtime = File.info(inp_file).modification_time.to_unix
  chaps = export_chaps(chaps, sn_id, mtime)

  repo = RD::Czdata.db("!zxcs.me/#{sn_id}")
  repo.open_tx { |db| chaps.each(&.upsert!(db: db)) }

  return if good_enough?(chaps)
  return puts "  Skipped".colorize.red if SKIP_CHOICE
  print "\nChoice (y: keep, r: redo, d: delete, else: exit): "

  STDIN.flush
  case char = STDIN.raw(&.read_char)
  when 'r'
    puts "\n - redoing..."
    split_chaps!(sn_id, label) # redo
  when ' ', 'y'
    puts "\n\n- Keeping [#{sn_id}] result".colorize.yellow
  else
    File.delete(repo.db_path)
    puts "\n\n- [#{repo.db_path}] deleted! (choice: #{char})".colorize.red
    exit(0) unless char == 'd'
  end
end

# ameba:disable Metrics/CyclomaticComplexity
def split_chapters(sn_id : Int32, lines : Array(String))
  case sn_id
  when 4683, 3868, 4314, 3199, 4942, 1552
    return split_blanks(lines)
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

def export_chaps(input : Array(Array(String)), sn_id : Int32, mtime : Int64)
  while intro_name?(input.first)
    input.shift
  end

  chaps = [] of RD::Czdata
  chdiv = ""
  prev_was_chdiv = false

  input.each do |cbody|
    if cbody.size == 1
      raise "invalid #{cbody}" if prev_was_chdiv

      chdiv = CharUtil.to_canon(cbody.first.strip)
      prev_was_chdiv = true
      next
    end

    ch_no = chaps.size &+ 1
    prev_was_chdiv = false

    chaps << RD::Czdata.new(
      ch_no: ch_no,
      cbody: cbody,
      chdiv: chdiv,
      uname: "!zxcs.me",
      zorig: "#{sn_id}/#{ch_no}",
      mtime: mtime
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
  "内容简介",
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
         "作品相关", "【作品相关】"
      next
    else
      if cinfo.chdiv.size > 20
        bads << cinfo
        next
      end
    end

    case cinfo.title
    when .matches?(/^(梗子|引言|结束语|引 子|开始|感言|前言|锲子|结语|楔子|作者的话|小结|故事简介|完本公告|完本说明)$/),
         .matches?(/后记|完本了|作品相关|结束感言|完本感言|完结感言|完稿感言|结后感言|全本感言|次卷预告|写在结束的话/),
         .matches?(/^【?(序|第|终卷|楔子|引子|尾声|番外|终章|末章|终曲|后记|后续|结局)/),
         .matches?(/^【?(前记|篇外|前言|后篇|外传|尾章|初章|引章|卷末|最终回|最终章|终结章|终之章|大结局|人物介绍|更新说明)/),
         .matches?(/^\d+、/),
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
  else
    puts "\n- wrong format (#{bads.size}): ".colorize.red
    bads.first(10).each do |cinfo|
      meta = {title: cinfo.title, chdiv: cinfo.chdiv, ch_no: cinfo.ch_no, sizes: cinfo.sizes}
      puts meta.to_pretty_json.colorize.red
    end

    false
  end
end

inputs = Dir.glob("#{TEXT_DIR}/*.txt").map { |x| File.basename(x, ".txt").to_i }
exists = Dir.glob("#{SAVE_DIR}/*-ztext.db3").map { |x| File.basename(x, "-ztext.db3").to_i }.to_set

inputs.reject!(&.in?(exists)).sort_by!(&.-)

inputs.each_with_index do |sn_id, index|
  split_chaps!(sn_id, "#{index}/#{inputs.size}")
end
