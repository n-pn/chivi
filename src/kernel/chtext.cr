require "colorize"
require "file_utils"
require "../../shared/zip_store"

class Chivi::Chtext
  alias Cache = Hash(String, self)
  CACHE_LIMIT = 1000

  @@front_cache = Cache.new
  @@back_cache = Cache.new

  def self.load_cached(seed : String, sbid : String, scid : String)
    file = "_db/zhtext/#{seed}/#{sbid}/#{scid}.txt"

    unless item = @@front_cache[file]?
      item = @@back_cache[file]? || new(file)

      @@front_cache[file] = item

      if @@front_cache.size >= CACHE_LIMIT
        @@back_cache = @@front_cache
        @@front_cache = Cache.new
      end
    end

    item
  end

  getter file : String
  property zh_data : Array(String) { load_data }

  property cv_text = ""
  property cv_time = 0_i64

  def initialize(@file : String)
    zip_file = "#{File.dirname(@file)}.zip"
    @zip_dir = ZipStore.new(zip_file)
  end

  def load_data : Array(String)
    puts "[CH_TEXT <#{@file}> loading...]".colorize.green
    @zip_dir.extract!(@file).try(&.split("\n")) || [] of String
  end

  def fix_zh_text! : Nil
    return unless @zh_data.first?.try(&.includes?('¦'))

    zh_data.map &.split(/[\tǁ]/).map(&.split('¦', 2)[0]).join
    save!
  end

  def save!(file : String = @file, mode : Symbol = :store) : Void
    FileUtils.mkdir_p(File.dirname(file))

    File.write(file, self)
    puts "[CH_TEXT <#{file}> saved]".colorize.yellow

    if mode == :archive
      @zip_dir.add_file!(file)
    end
  end

  def to_s(io : IO) : Nil
    zh_data.join(io, "\n")
  end
end
