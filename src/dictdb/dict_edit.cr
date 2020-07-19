require "colorize"
require "file_utils"
require "../common/file_util"

# dict modification log
class DictEdit
  LABEL = "dict_edit"
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  class Edit
    def self.mtime(time = Time.utc)
      (time - EPOCH).total_minutes.to_i
    end

    def self.parse!(line : String)
      cols = line.split(SEP_0)

      mtime, uname, power, key = cols
      vals = cols.fetch(4, "")
      extra = cols.fetch(5, "")

      new(mtime.to_i, uname, power.to_i, key, vals, extra)
    end

    getter mtime : Int32  # time by total minutes since the EPOCH
    getter uname : String # user handle dname
    getter power : Int32  # entry lock level

    getter key : String
    getter vals : String
    getter extra : String

    def initialize(@mtime, @uname, @power, @key, @vals = "", @extra = "")
    end

    def to_s
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO)
      {@mtime, @uname, @power, @key, @vals, @extra}.join(io, SEP_0)
    end

    def puts(io : IO)
      to_s(io)
      io << "\n"
    end

    def better_than?(other : Edit)
      return @mtime >= other.mtime if @power == other.power
      @power > other.power
    end
  end

  getter file : String
  getter time = EPOCH

  getter list = [] of Edit
  getter best = {} of String => Edit

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
      insert(Edit.parse!(line))
    rescue err
      FileUtil.log_error(LABEL, line, err)
    end
  end

  def sort! : Void
    @list.sort_by!(&.mtime)
  end

  def insert!(item : Edit)
    append!(item)
    insert(item)
  end

  def append!(item : Edit)
    File.open(@file, "a") { |io| item.puts(io) }
  end

  def insert(item : Edit) : Void
    insert(item.key, item.power) { item }
  end

  def insert(key : String, power = 0)
    if best = find(key)
      return if best.power > power
    end

    item = yield
    @list << item
    @best[key] = item
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
    File.join(DIR, "#{dname}.#{scope}.log")
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

  class_getter hanviet : DictEdit { preload!("hanviet") }
  class_getter generic : DictEdit { preload!("generic") }
  class_getter suggest : DictEdit { preload!("suggest") }
  class_getter combine : DictEdit { preload!("combine") }

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
