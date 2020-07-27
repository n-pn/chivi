require "colorize"
require "file_utils"
require "../common/file_util"

require "./base_dict"
require "./dict_edit"

# dict modification log
class UserDict
  LABEL = "user_dict"

  getter file : String
  getter dict : BaseDict

  getter items = [] of DictEdit
  getter bests = {} of String => DictEdit
  getter hints = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }

  delegate size, to: @items
  delegate each, to: @items

  def initialize(@file, name : String, mode : Int32 = 0)
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
      else
        @hints[item.key].clear
      end
    end

    @dict.upsert(item.key, item.val, freeze: freeze)
    File.open(@file, "a", &.puts(item)) if freeze

    @items.push(item)
    @bests[item.key] = item
  end

  def add_hints(key : String, val : String)
    @hints[key].push(val)
  end

  def find(key : String)
    return @dict.find(key), @bests[key]?, @hints[key]?
  end

  def save!(file : String = @file) : Void
    @dict.save!

    @items.sort_by!(&.mtime).uniq!
    FileUtil.save(file, LABEL, @items.size) do |io|
      @items.each { |item| io.puts(item) }
    end
  end

  # class methods

  DIR = File.join("var", "dictdb")

  class_property ext = ENV["KEMAL_ENV"]? == "production" ? "log" : "test.log"

  def self.path_for(name : String)
    File.join(DIR, "#{name}.#{ext}")
  end

  CACHE = {} of String => UserDict

  def self.load(name : String, mode = 1)
    CACHE[name] ||= new(path_for(name), name, mode: mode)
  end

  def self.load!(name : String)
    load(name, mode: 2)
  end
end
