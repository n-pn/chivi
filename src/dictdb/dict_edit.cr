require "colorize"
require "file_utils"

# dict modification log
class DictEdit
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  class Edit
    def self.mtime(time = Time.utc)
      (time - EPOCH).total_minutes.to_i
    end

    def self.parse!(line : String)
      cols = line.split(SEP_0)

      mtime, udname, power, key = cols
      vals = cols.fetch(4, "")
      extra = cols.fetch(5, "")

      new(mtime.to_i, udname, power.to_i, key, vals, extra)
    end

    getter mtime : Int32   # time by total minutes since the EPOCH
    getter udname : String # user handle dname
    getter power : Int32   # entry lock level

    getter key : String
    getter vals : String
    getter extra : String

    def initialize(@mtime, @udname, @power, @key, @vals = "", @extra = "")
    end

    def to_s
      String.build { |io| to_s(io) }
    end

    def to_s(io : IO)
      {@mtime, @udname, @power, @key, @vals, @extra}.join(io, SEP_0)
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
    lines = File.read_lines(@file)

    lines.each do |line|
      append(Edit.parse!(line))
    rescue
      puts "- <dict_dlog> error parsing line: `#{line.colorize(:red)}`."
    end

    puts "- <dict_dlog> [#{@file.colorize.blue}] loaded \
            (entries: #{lines.size.colorize.blue})."
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

  def save!(sort : Bool = false)
    sort! if sort
    @list.uniq!

    File.open(@file, "w") do |io|
      @list.each { |item| io.puts(item) }
    end

    puts "- <dict_dlog> [#{@file.colorize.yellow}] saved \
            (entries: #{list.size.colorize.yellow})."
    self
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

  CACHE = {} of String => self

  def self.load(file : String, preload : Bool = true) : self
    CACHE[file] ||= new(file, preload)
  end

  @@hanviet : DictEdit? = nil
  @@generic : DictEdit? = nil
  @@combine : DictEdit? = nil
  @@suggest : DictEdit? = nil

  def self.hanviet
    @@hanviet ||= new(path_for("shared/hanviet"), true)
  end

  def self.generic
    @@generic ||= new(path_for("shared/generic"), true)
  end

  def self.combine
    @@combine ||= new(path_for("shared/combine"), true)
  end

  def self.suggest
    @@suggest ||= new(path_for("shared/suggest"), true)
  end

  def self.shared(dname : String)
    case dname
    when "hanviet" then hanviet
    when "generic" then generic
    when "combine" then combine
    when "suggest" then suggest
    else
      load(path_for("shared/#{dname}"), true)
    end
  end

  def self.unique(dname : String)
    load(path_for("unique/#{dname}"), true)
  end
end
