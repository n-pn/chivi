require "colorize"
require "file_utils"

# dict modification log
class CvDlog
  EPOCH = Time.utc(2020, 1, 1)
  SEP_0 = "ǁ"

  class Item
    def self.mtime(time = Time.utc)
      (time - EPOCH).total_minutes.to_i
    end

    getter mtime : Int32   # time by total minutes since the EPOCH
    getter udname : String # user handle dname
    getter power : Int32   # entry lock level

    getter key : String
    getter vals : String
    getter extra : String

    def self.parse!(line : String)
      cols = line.split(SEP_0)

      mtime, udname, power, key = cols
      vals = cols.fetch(4, "")
      extra = cols.fetch(5, "")

      new(mtime.to_i, udname, power.to_i, key, vals, extra)
    end

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

    def better_than?(other : Item)
      return @mtime >= other.mtime if @power == other.power
      @power > other.power
    end
  end

  getter file : String
  getter time = EPOCH

  getter logs = [] of Item
  getter best = {} of String => Item

  delegate size, to: @logs
  delegate each, to: @logs

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def exists?
    File.exists?(file)
  end

  def load!(file : String = @file) : Void
    lines = File.read_lines(@file)

    lines.each do |line|
      append(Item.parse!(line))
    rescue
      puts "- <cv_dlog> error parsing line: `#{line.colorize(:red)}`."
    end

    puts "- <cv_dlog> [#{@file.colorize(:cyan)}] loaded \
            (#{lines.size.colorize(:cyan)} entries)."
  end

  def sort! : Void
    @logs.sort_by!(&.mtime)
  end

  def insert!(item : Item)
    append!(item)
    insert(item)
  end

  def append!(item : Item)
    File.open(@file, "a") { |io| item.puts(io) }
  end

  def insert(item : Item) : Void
    insert(item.key, item.power) { item }
  end

  def insert(key : String, power = 0)
    if best = find(key)
      return if best.power > power
    end

    item = yield
    @logs << item
    @best[key] = item
  end

  def find(key : String)
    @best[key]?
  end

  def save!(sort : Bool = false)
    sort! if sort
    @logs.uniq!

    File.open(@file, "w") do |io|
      @logs.each { |item| io.puts(item) }
    end

    puts "- <cv_dlog> [#{@file.colorize(:cyan)}] saved."
    self
  end

  # class methods

  DIR = File.join("var", "dict_dlogs")
  FileUtils.mkdir_p(File.join(DIR, "lookup"))
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

  @@hanviet : CvDlog? = nil
  @@generic : CvDlog? = nil
  @@combine : CvDlog? = nil
  @@suggest : CvDlog? = nil

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
