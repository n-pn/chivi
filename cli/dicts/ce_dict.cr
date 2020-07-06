require "json"
require "colorize"
require "http/client"
require "compress/zip"

require "./utils/common"
require "./utils/pinyin"

require "../../src/utils/normalize"
require "../../src/dictdb/dict_file"

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
    pinyin = Pinyin.to_tone(pinyin)

    new(trad, simp, pinyin, define)
  end

  def self.cleanup(entry, hanzi) : String
    entry.gsub(/\p{Han}+\|/, "")                            # remove hantrads
      .gsub(/(?<=\[)(.*?)(?=\])/) { |p| Pinyin.to_tone(p) } # number to tones
      .split("/").reject { |x| repeat_itself?(x, hanzi) }   # clean trad defs
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

  getter input = [] of Entry

  HANZIDB_FILE = Common.inp_path("_system/hanzidb.txt")
  HANZIDB_DICT = Common.load_legacy_dict!(HANZIDB_FILE)

  CE_DICT_FILE = Common.out_path("lookup/cc_cedict.dic")
  TRADSIM_FILE = Common.out_path("shared/tradsim.dic")
  PINYINS_FILE = Common.out_path("shared/pinyins.dic")

  def initialize
    read_zip.split("\n").each do |line|
      next unless entry = Entry.parse(line)
      @input << entry
    end

    puts "- input: #{@input.size} entries.".colorize(:cyan)
  end

  def read_zip : String
    puts "- reading zip file content...".colorize(:cyan)

    zip_file = Common.inp_path("_system/cedict.zip")

    if outdated?(zip_file)
      puts "- fetching latest CC_CEDICT from internet... ".colorize(:cyan)
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
    puts "\n- [Export ce_dict]".colorize(:cyan)
    dict = DictFile.new(CE_DICT_FILE)

    @input.each do |entry|
      Common.add_to_known(entry.simp)
      dict.upsert(entry.simp, "[#{entry.pinyin}] #{entry.define}")
    end

    Common.save_known_words!
    dict.save!
  end

  alias Counter = Hash(String, Int32)

  def is_trad?(input : String)
    input.includes?("old variant of") || input.includes?("archaic variant of")
  end

  def export_tradsim!
    puts "\n- [Export tradsim]".colorize(:cyan)

    counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }
    tswords = DictFile.new(Common.tmp_path("tradsimp-words.dict"))

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

    dict = DictFile.new(TRADSIM_FILE)

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
      next if simp.first == Common.convert(dict, item.key)
      dict.upsert(item.key, simp)
    end

    dict.save!
  end

  def export_pinyins!
    puts "\n- [Export pinyins]".colorize(:cyan)

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

    dict = DictFile.new(PINYINS_FILE)
    dict.load_legacy!(Common.inp_path("_system/pinyins.txt"))

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
