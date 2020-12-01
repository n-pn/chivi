require "colorize"
require "file_utils"

require "../../_utils/file_util"

require "./base_dict"
require "./user_dict/*"

# dict modification log
class Oldcv::Engine::UserDict
  LABEL = "user_dict"

  getter file : String
  getter dict : BaseDict

  getter power = 1 # minimum user power to have effective changes

  getter items = [] of DictEdit
  getter bests = {} of String => DictEdit
  getter hints = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

  delegate size, to: @items
  delegate each, to: @items

  def initialize(@file, name : String, mode : Int32 = 0, @power = 1)
    @dict = BaseDict.load(name, mode: 1)

    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      insert(DictEdit.parse!(line), freeze: false)
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def insert(item : DictEdit, freeze : Bool = false)
    if best = @bests[item.key]?
      raise "duplicate" if best.eql?(item) # prevent duplicate

      unless item.prevail?(best)
        add_hints(item.key, item.val)
        raise "power too low"
      end
    end

    if item.power < @power
      add_hints(item.key, item.val)
      raise "power too low"
    elsif best
      add_hints(item.key, best.val)
    end

    @dict.upsert(item.key, DictTrie.split(item.val, "/"), freeze: freeze)
    File.open(@file, "a", &.puts(item)) if freeze

    @items.push(item)
    @bests[item.key] = item
  end

  def add_hints(key : String, val : String)
    @hints[key].push(val)
  end

  def find(key : String)
    best = @bests[key]?

    {
      vals:  @dict.find(key).try(&.vals) || [] of String,
      mtime: best.try(&.utime) || 0,
      uname: best.try(&.uname) || "",
      power: best.try(&.power) || @power,
      hints: @hints[key]?.try(&.uniq.last(3)) || [] of String,
    }
  end

  def save!(file : String = @file) : Void
    @dict.save!

    @items.sort_by!(&.mtime).uniq!
    FileUtil.save(file, LABEL, @items.size) do |io|
      @items.each { |item| io.puts(item) }
    end
  end

  # class Oldcv::methods

  DIR = File.join("var", "libcv", "lexicon")

  class_property ext = ENV["KEMAL_ENV"]? == "production" ? "log" : "test.log"

  def self.path_for(name : String)
    File.join(DIR, "#{name}.#{ext}")
  end

  CACHE = {} of String => UserDict

  def self.load(name : String, mode = 1, power = 1)
    CACHE[name] ||= new(path_for(name), name, mode: mode, power: power)
  end

  def self.load!(name : String, power = 1)
    load(name, mode: 2, power: power)
  end
end
