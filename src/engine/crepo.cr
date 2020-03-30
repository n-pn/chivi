require "colorize"
require "./cdict"

# Loading dicts
class CRepo
  class List
    alias CvMap = Hash(String, CDict)

    def initialize(@dir : String, preload = false)
      @dicts = CvMap.new
      @fixes = Hash(String, CvMap).new { |h, k| h[k] = CvMap.new }

      load_dir!(lazy: false) if preload
    end

    def load_dir!(lazy = true) : Void
      time1 = Time.monotonic

      files = Dir.glob(File.join(@dir, "*.dic"))
      count = files.size

      files.each do |file|
        name = File.basename(file, ".dic")

        count += load_fixes!(name, lazy)
        next if lazy && @dicts[name]?

        @dicts[name] = load_dic(name)
      end

      time2 = Time.monotonic
      elapsed = (time2 - time1).total_seconds

      puts "- Loaded [#{@dir.colorize(:yellow)}], files: #{count.colorize(:yellow)}, time: #{elapsed.colorize(:yellow)}s"
    end

    def load_fixes!(name : String, lazy = true)
      files = Dir.glob(File.join(@dir, "#{name}.*.fix"))

      files.each do |file|
        user = File.extname(File.basename(file, ".fix")).tr(".", "")
        next if lazy && @fixes[name][user]?
        @fixes[name][user] = load_fix(name, user)
      end

      files.size
    end

    def [](name : String)
      [get_dic(name)]
    end

    def [](name : String, user : String)
      [get_dic(name), get_fix(name, user)]
    end

    def get_dic(name : String)
      @dicts[name] ||= load_dic(name)
    end

    def get_fix(name : String, user = "admin")
      @fixes[name][user] ||= load_fix(name)
    end

    def all_fixes(name : String)
      @fixes[name]
    end

    def load_dic(name : String)
      CDict.new(File.join(@dir, "#{name}.dic"))
    end

    def load_fix(name : String, user : String = "admin")
      CDict.new(File.join(@dir, "#{name}.#{user}.dic"))
    end
  end

  getter system : List
  getter common : List
  getter unique : List

  def initialize(@dir : String = ".dic")
    @system = List.new(@dir)
    @common = List.new(File.join(@dir, "common"))
    @unique = List.new(File.join(@dir, "unique"))
  end

  alias Dicts = Array(CDict)

  @cc_cedict : Dicts? = nil
  @trungviet : Dicts? = nil
  @hanviet : Dicts? = nil
  @pinyin : Dicts? = nil
  @tradsim : Dicts? = nil

  def cc_cedict
    @cc_cedict ||= @system["cc_cedict"]
  end

  def trungviet
    @trungviet ||= @system["trungviet"]
  end

  def hanviet
    @hanviet ||= @system["hanviet"]
  end

  def pinyin
    @pinyin ||= @system["pinyin"]
  end

  def tradsim
    @tradsim ||= @system["tradsim"]
  end

  def generic(user : String = "admin")
    @common["generic", user]
  end

  def combine(user : String = "admin")
    @common["combine", user]
  end

  def suggest(user : String = "admin")
    @common["suggest", user]
  end

  def unique(name : String, user = "admin")
    @unique[name, user]
  end

  def for_convert(book : String? = nil, user = "admin")
    dicts = generic(user)

    if book
      dicts.concat(unique(book, user))
    else
      dicts.concat(combine(user))
    end

    dicts
  end
end
