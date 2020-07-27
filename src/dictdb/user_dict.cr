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

  getter list = [] of DictEdit
  getter best = {} of String => DictEdit

  delegate size, to: @list
  delegate each, to: @list

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(file)
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

    @list << item
    @best[item.key] = item
  end

  def find(key : String)
    @best[key]?
  end

  def save!(sort : Bool = false) : Void
    sort! if sort
    @list.uniq!

    FileUtil.save(file, LABEL, @list.size) do |io|
      @list.each { |item| io.puts(item) }
    end
  end

  # class methods

  DIR = File.join("var", "dictdb")
  FileUtils.mkdir_p(File.join(DIR, "unique"))

  @@scope = ENV["KEMAL_ENV"]? == "production" ? "appcv" : "local"

  def self.set_scope!(scope : String)
    @@scope = scope
  end

  def self.path_for(dname : String, scope = @@scope)
    File.join(DIR, "#{dname}.#{scope}.fix")
  end

  def self.load!(name : String)
    new(path_for(name), preload: true)
  end

  def self.read(file : String)
    new(file, preload: true)
  end

  CACHE = {} of String => self

  def self.preload!(name : String) : self
    CACHE[name] ||= load!(name)
  end

  def self.load_unique(dname : String)
    preload!("unique/#{dname}")
  end

  class_getter hanviet : UserDict { preload!("hanviet") }
  class_getter generic : UserDict { preload!("generic") }
  class_getter suggest : UserDict { preload!("suggest") }
  class_getter combine : UserDict { preload!("combine") }

  def self.load_unsure(dname : String)
    case dname
    when "hanviet" then hanviet
    when "generic" then generic
    when "combine" then combine
    when "suggest" then suggest
    else                load_unique(dname)
    end
  end
end
