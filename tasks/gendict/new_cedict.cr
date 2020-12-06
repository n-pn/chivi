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
end

class CeInput
  CEDICT_URL = "https://www.mdbg.net/chinese/export/cedict/cedict_1_0_ts_utf-8_mdbg.zip"

  TSV_FILE = QtUtil.inp_path("_system/cc-cedict.tsv")
  ZIP_FILE = QtUtil.inp_path("_system/cc-cedict.zip")

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
    puts "\n[-- Export ce_dict --]".colorize.cyan.bold

    input = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

    @entries.each do |entry|
      input[entry.simp] << "[#{entry.pinyin}] #{entry.defins}"
    end

    output = Chivi::VpDict.new(Chivi::Library.file_path("cc_cedict"))

    input.each do |key, vals|
      output.upsert(Chivi::VpTerm.new(key, vals))
    end

    output.save!
  end
end

cedict = CeInput.load_data(expiry: 24.hours)

cedict.export_ce_dict!
