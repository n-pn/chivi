require "colorize"
require "file_utils"
require "../common/file_util"

require "./base_dict"
require "./dict_edit"

# dict modification log
class UserDict
  LABEL = "user_dict"

  getter file : String
  getter time = DictEdit::EPOCH

  getter dict : BaseDict
  getter list = [] of DictEdit
  getter best = {} of String => DictEdit

  delegate size, to: @list
  delegate each, to: @list

  def initialize(@file, name : String, mode : Int32 = 0)
    @dict = BaseDict.load(name, mode: 1)

    return if mode == 0
    load!(@file) if mode == 2 || File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    FileUtil.each_line(file, LABEL) do |line|
      insert(DictEdit.parse!(line))
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def sort! : Void
    @list.sort_by!(&.mtime)
  end

  def insert!(item : DictEdit)
    append!(item)
    insert(item)
  end

  def append!(item : DictEdit)
    File.open(@file, "a") { |io| item.puts(io) }
  end

  def insert(item : DictEdit)
    if best = find(item.key)
      return if best.power > item.power
    end

    @dict.upsert(item.key, item.val)
    @list << item
    @best[item.key] = item
  end

  def find(key : String)
    @best[key]?
  end

  def save!(file : String = @file, sort : Bool = false) : Void
    sort! if sort
    @list.uniq!

    @dict.save!
    FileUtil.save(file, LABEL, @list.size) do |io|
      @list.each { |item| io.puts(item) }
    end
  end

  # class methods

  DIR = File.join("var", "dictdb")
  EXT = ENV["KEMAL_ENV"]? == "production" ? "log" : "test.log"

  def self.path_for(name : String)
    File.join(DIR, "#{name}.#{EXT}")
  end

  CACHE = {} of String => UserDict

  def self.load(name : String, mode = 1)
    CACHE[name] ||= new(path_for(name), name, mode: mode)
  end

  def self.load!(name : String)
    load(name, mode: 2)
  end
end
