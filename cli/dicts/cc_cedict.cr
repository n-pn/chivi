require "json"
require "colorize"
require "http/client"
require "compress/zip"

require "./utils/common"
require "./utils/pinyin"

require "../../src/library/base_dict"
require "../../src/_utils/normalize"

class Entry
  getter trad : String
  getter simp : String
  getter pinyin : String
  getter define : String

  def initialize(@trad, @simp, @pinyin, @define)
  end

  LINE_RE = /^(.+?) (.+?) \[(.+?)\] \/(.+)\/$/

  def self.parse(line : String)
    return nil if line.empty? || line[0] == '#'
    return nil unless match = line.strip.match(LINE_RE)

    _, trad, simp, pinyin, define = match

    define = cleanup(define, simp)
    return nil if define.empty?

    trad = Utils.normalize(trad).join
    simp = Utils.normalize(simp).join
    pinyin = Utils.pinyin_to_tone(pinyin)

    new(trad, simp, pinyin, define)
  end

  def self.cleanup(entry, hanzi) : String
    entry.gsub(/\p{Han}+\|/, "") # remove hantrads
      .gsub(/(?<=\[)(.*?)(?=\])/) { |p| Utils.pinyin_to_tone(p) }
      .split("/").reject { |x| repeat_itself?(x, hanzi) } # clean trad hanzi
      .join("; ")
  end

  def self.repeat_itself?(entry : String, hanzi : String) : Bool
    return true if entry =~ /variant of #{hanzi}/
    return true if entry =~ /also written #{hanzi}/
    return true if entry =~ /see #{hanzi}/

    false
  end
end

class CE_DICT
  CEDICT_URL = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"

  HANZIDB_FILE = Utils.inp_path("initial/hanzidb.txt")
  HANZIDB_DICT = BaseDict.read!(HANZIDB_FILE, legacy: true)

  getter input = [] of Entry

  def initialize
    puts "\n[-- Loading input --]".colorize.cyan.bold

    read_zip.split("\n").each do |line|
      next unless entry = Entry.parse(line)
      @input << entry
    end

    puts "- input: #{@input.size} entries.".colorize.light_cyan
  end

  def read_zip : String
    zip_file = Utils.inp_path("initial/cc-cedict.zip")

    if outdated?(zip_file)
      puts "- fetching latest CC_CEDICT from internet... ".colorize.light_cyan
      HTTP::Client.get(CEDICT_URL) { |res| File.write(zip_file, res.body_io) }
    end

    Compress::Zip::File.open(zip_file) do |zip|
      zip["cedict_ts.u8"].open { |io| io.gets_to_end }
    end
  end

  def outdated?(zip_file : String)
    return true unless File.exists?(zip_file)
    File.info(zip_file).modification_time < Time.utc - 24.hours
  end

  def export_ce_dict!
    puts "\n[-- Export ce_dict --]".colorize.cyan.bold

    dict = BaseDict.load("cc_cedict", mode: 0)
    ondicts = Utils.ondicts_words

    @input.each do |entry|
      ondicts.upsert(entry.simp) if Utils.has_hanzi?(entry.simp)
      dict.upsert(entry.simp, "[#{entry.pinyin}] #{entry.define}")
    end

    dict.save!
    ondicts.save!
  end

  alias Counter = Hash(String, Int32)

  def is_trad?(input : String)
    input.includes?("old variant of") || input.includes?("archaic variant of")
  end

  def export_tradsim!
    puts "\n[-- Export tradsim --]".colorize.cyan.bold

    counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }
    tswords = BaseDict.new(Utils.inp_path("autogen/tradsimp-words.dict"))

    @input.each do |entry|
      next if is_trad?(entry.define)

      if entry.trad.size > 1
        tswords.upsert(entry.trad) { |node| node.vals << entry.simp }
      end

      simps = entry.simp.split("")
      trads = entry.trad.split("")

      trads.each_with_index do |trad, i|
        counter[trad][simps[i]] += 1
      end
    end

    dict = BaseDict.load("_tradsim", mode: 0)

    counter.each do |trad, counts|
      best = counts.to_a.sort_by { |simp, count| -count }.map(&.first)
      next if best.includes?(trad) || HANZIDB_DICT.has_key?(trad)
      dict.upsert(trad, best) unless trad == best.first
    end

    puts "- trad chars count: #{dict.size.colorize(:green)}"

    dict.upsert("扶馀", "扶余") # add exception

    words = tswords.to_a.sort_by(&.key.size)
    words.each do |item|
      simp = item.vals.uniq
      next if simp.size > 1 || simp.first == item.key
      next if simp.first == Utils.convert(dict, item.key)
      dict.upsert(item.key, simp)
    end

    dict.save!
  end

  def export_pinyins!
    puts "\n[-- Export pinyins --]".colorize.cyan.bold

    counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }

    @input.each do |entry|
      # next if is_trad?(entry.define)

      chars = entry.simp.split("")
      pinyins = entry.pinyin.split(" ")
      next if chars.size != pinyins.size

      chars.each_with_index do |char, i|
        next if char =~ /\P{Han}/
        counter[char][pinyins[i]] += 1
      end
    end

    dict = BaseDict.load("_binh_am", mode: 0)
    dict.load!(Utils.inp_path("initial/extra-pinyins.txt"), legacy: true)

    HANZIDB_DICT.each do |entry|
      dict.upsert(entry.key, entry.vals) unless entry.vals.first.empty?
    end

    counter.each do |char, counts|
      best = counts.to_a.sort_by { |pinyin, count| -count }.map(&.first)
      dict.upsert(char, best.first(4))
    end

    dict.save!
  end
end

ce_dict = CE_DICT.new
ce_dict.export_ce_dict!
ce_dict.export_tradsim!
ce_dict.export_pinyins!
