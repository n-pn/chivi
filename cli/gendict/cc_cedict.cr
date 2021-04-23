require "json"
require "colorize"
require "http/client"
require "compress/zip"

require "./shared/qt_util"
require "./shared/qt_dict"

class CeEntry
  getter trad : String
  getter simp : String
  getter pinyin : String
  getter defins : String

  def initialize(@trad, @simp, @pinyin, @defins)
  end

  def to_s(io : IO) : Nil
    {@trad, @simp, @pinyin, @defins}.join(io, '\t')
  end

  def to_s : String
    String.build { |io| to_s(io) }
  end

  LINE_RE = /^(.+?) (.+?) \[(.+?)\] \/(.+)\/$/

  def self.parse(line : String)
    return nil if line.empty? || line[0] == '#'
    return nil unless match = line.strip.match(LINE_RE)

    _, trad, simp, pinyin, defins = match

    defins = cleanup(defins, simp)
    return nil if defins.empty?

    pinyin = QtUtil.fix_pinyin(pinyin)

    new(trad, simp, pinyin, defins)
  end

  def self.cleanup(entry : String, simp : String) : String
    entry.gsub(/\p{Han}+\|/, "") # remove hantrads
      .gsub(/(?<=\[)(.*?)(?=\])/) { |p| QtUtil.fix_pinyin(p) }
      .split("/").reject { |x| repeat_itself?(x, simp) } # clean trad simp
      .join("; ")
  end

  def self.repeat_itself?(entry : String, simp : String) : Bool
    return true if entry =~ /variant of #{simp}/
    return true if entry =~ /also written #{simp}/
    return true if entry =~ /see #{simp}/

    false
  end

  NOUN_FILE = QtUtil.path("_system/english-nouns.txt")
  VERB_FILE = QtUtil.path("_system/english-verbs.txt")
  ADJE_FILE = QtUtil.path("_system/english-adjectives.txt")

  NOUNS = Set(String).new File.read_lines(NOUN_FILE)
  VERBS = Set(String).new File.read_lines(VERB_FILE)
  ADJES = Set(String).new File.read_lines(ADJE_FILE)

  def is_noun?
    defins.split("; ").each do |x|
      return true if NOUNS.includes?(x) && !ADJES.includes?(x)
    end

    false
  end

  def is_verb?
    defins.split("; ").each do |x|
      words = x.split(" ")

      return false if words.size < 2
      return true if words[0] == "to"
    end

    false
  end

  def is_adje?
    defins.split("; ").each do |x|
      return true if ADJES.includes?(x)
    end

    false
  end
end

class CeInput
  CEDICT_URL = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"

  TSV_FILE = QtUtil.path("_system/cc-cedict.tsv")
  ZIP_FILE = QtUtil.path("_system/cc-cedict.zip")

  def self.load_data(tsv_file = TSV_FILE, expiry = 24.hours)
    entries = [] of CeEntry

    if file_outdated?(tsv_file, expiry)
      puts "\n[-- Reparsing data --]".colorize.cyan.bold

      extract_zip(expiry).each_line do |line|
        next unless entry = CeEntry.parse(line)
        entries << entry
      end

      File.open(tsv_file, "w") do |io|
        entries.each { |entry| io.puts(entry) }
      end
    else
      puts "\n[-- Loading cached --]".colorize.cyan.bold

      File.each_line(tsv_file) do |line|
        trad, simp, pinyin, defins = line.split('\t')
        entries << CeEntry.new(trad, simp, pinyin, defins)
      end
    end

    new(entries)
  end

  def self.extract_zip(expiry = 24.hours) : String
    if file_outdated?(ZIP_FILE, expiry)
      puts "- fetching latest CC_CEDICT from internet... ".colorize.light_cyan
      HTTP::Client.get(CEDICT_URL) { |res| File.write(ZIP_FILE, res.body_io) }
    end

    Compress::Zip::File.open(ZIP_FILE) do |zip|
      zip["cedict_ts.u8"].open(&.gets_to_end)
    end
  end

  def self.file_outdated?(file : String, expiry = 24.hours)
    return true unless File.exists?(file)
    File.info(file).modification_time < Time.utc - expiry
  end

  @entries = [] of CeEntry

  def initialize(@entries)
    puts "- input: #{@entries.size} entries.".colorize.light_cyan
  end

  def export_ce_dict!
    nouns = [] of String
    verbs = [] of String
    adjes = [] of String

    puts "\n[-- Export ce_dict --]".colorize.cyan.bold

    input = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

    @entries.each do |entry|
      if entry.is_noun?
        # puts "noun: #{entry.defins}"
        nouns << entry.simp
      end

      if entry.is_verb?
        puts "verb: #{entry.defins}"
        verbs << entry.simp
      end

      if entry.is_adje?
        # puts "adje: #{entry.defins}"
        adjes << entry.simp
      end

      input[entry.simp] << "[#{entry.pinyin}] #{entry.defins}"
    end

    File.write(QtUtil.path(".result/ce-nouns.txt"), nouns.uniq.join("\n"))
    File.write(QtUtil.path(".result/ce-verbs.txt"), verbs.uniq.join("\n"))
    File.write(QtUtil.path(".result/ce-adjes.txt"), adjes.uniq.join("\n"))

    output = CV::Vdict.load("cc_cedict", reset: true)

    input.each do |key, vals|
      QtUtil.lexicon.add(key)
      output.set(key, vals)
    end

    QtUtil.lexicon.save!
    output.save!(prune: false)
  end

  HANZIDB = QtDict.load("_system/hanzidb.txt")

  alias Counter = Hash(String, Int32)

  def is_trad?(input : String)
    input.includes?("old variant of") || input.includes?("archaic variant of")
  end

  def export_tradsim!
    puts "\n[-- Export tradsim --]".colorize.cyan.bold

    counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }
    tswords = QtDict.new(".result/tradsimp-words.txt")

    @entries.each do |entry|
      next if is_trad?(entry.defins)

      if entry.trad.size > 1
        tswords.set(entry.trad, [entry.simp], :old_first)
      end

      simps = entry.simp.split("")
      trads = entry.trad.split("")

      trads.each_with_index do |trad, i|
        counter[trad][simps[i]] += 1
      end
    end

    output = CV::Vdict.load("tradsim", reset: true)

    counter.each do |trad, counts|
      next if HANZIDB.has_key?(trad) || counts.has_key?(trad)

      best = counts.to_a.sort_by { |simp, count| -count }.map(&.first)
      output.set(trad, best)
    end

    puts "- trad chars count: #{output.size.colorize(:green)}"

    output.set("扶馀", ["扶余"])

    words = tswords.data.to_a.sort_by(&.[0].size)
    words.each do |key, vals|
      simp = vals.uniq
      next if simp.first == key

      convert = QtUtil.convert(output, key)
      next if simp.first == convert

      output.set(key, simp)
    end

    output.save!(prune: true)
  end

  def export_pinyins!
    puts "\n[-- Export pinyins --]".colorize.cyan.bold

    counter = Hash(String, Counter).new { |h, k| h[k] = Counter.new(0) }
    pywords = QtDict.new(".result/pinyins-words.txt")

    @entries.each do |entry|
      next if is_trad?(entry.defins)

      if entry.simp.size > 1
        pywords.set(entry.simp, [entry.pinyin], :old_first)
      end

      chars = entry.simp.split("")
      pinyins = entry.pinyin.split(" ")
      next if chars.size != pinyins.size

      chars.each_with_index do |char, i|
        next if char =~ /\P{Han}/
        counter[char][pinyins[i]] += 1
      end
    end

    output = CV::Vdict.load("binh_am", reset: true)

    HANZIDB.each do |key, vals|
      next if vals.empty? || vals.first.empty?
      output.set(key, vals)
    end

    counter.each do |char, counts|
      best = counts.to_a.sort_by { |pinyin, count| -count }.map(&.first)
      output.set(char, best.first(3))
    end

    extras = QtDict.load("_system/extra-pinyins.txt")
    extras.each do |key, vals|
      output.set(key, vals)
    end

    words = pywords.to_a.sort_by(&.[0].size)
    words.each do |key, vals|
      next if key.size > 4
      vals = vals.uniq

      convert = QtUtil.convert(output, key, " ")
      next if vals.first == convert

      output.set(key, vals)
    end

    output.save!(prune: true)
  end
end

# NOUN_FILE = QtUtil.path("_system/english-nouns.txt")
# NOUNS     = Set(String).new File.read_lines(NOUN_FILE)

# Dir.glob(QtUtil.path("_system/wordlists/names/**/*.txt")) do |file|
#   NOUNS.concat File.read_lines(file)
# end

# Dir.glob(QtUtil.path("_system/wordlists/nouns/*.txt")) do |file|
#   NOUNS.concat File.read_lines(file)
# end

# File.write(NOUN_FILE, NOUNS.to_a.join("\n"))

# VERB_FILE = QtUtil.path("_system/english-verbs.txt")
# VERBS     = Set(String).new File.read_lines(VERB_FILE)

# Dir.glob(QtUtil.path("_system/wordlists/verbs/*.txt")) do |file|
#   VERBS.concat File.read_lines(file)
# end

# File.write(VERB_FILE, VERBS.to_a.join("\n"))

# ADJE_FILE = QtUtil.path("_system/english-adjectives.txt")
# ADJES     = Set(String).new File.read_lines(ADJE_FILE)

# Dir.glob(QtUtil.path("_system/wordlists/adjectives/*.txt")) do |file|
#   ADJES.concat File.read_lines(file)
# end

# File.write(ADJE_FILE, ADJES.to_a.join("\n"))

cedict = CeInput.load_data(expiry: 24.hours)

cedict.export_ce_dict!
cedict.export_tradsim!
cedict.export_pinyins!
