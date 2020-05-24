require "colorize"
require "./cv_dict"

# Loading dicts
class CvRepo
  class List
    alias CvMap = Hash(String, CvDict)

    def initialize(@dir : String, preload = false)
      @dicts = CvMap.new
      load_dir!(lazy: false) if preload
    end

    def load_dir!(lazy = true) : Void
      time1 = Time.monotonic

      files = Dir.glob(File.join(@dir, "*.dic"))
      count = 0

      files.each do |file|
        name = File.basename(file, ".dic")
        next if lazy && @dicts[name]?
        count += 1
        @dicts[name] = load(name)
      end

      time2 = Time.monotonic
      elapsed = (time2 - time1).total_seconds

      puts "- Loaded [#{@dir.colorize(:yellow)}], files: #{count.colorize(:yellow)}, time: #{elapsed.colorize(:yellow)}s"
    end

    def [](name : String)
      get(name)
    end

    def [](name : String, user : String)
      get("#{name}.#{user}")
    end

    def get(name : String)
      @dicts[name] ||= load(name)
    end

    def load(name : String)
      CvDict.new(File.join(@dir, "#{name}.dic"))
    end
  end

  getter system : List
  getter shared_base : List
  getter shared_user : List
  getter unique_base : List
  getter unique_user : List

  def initialize(@dir : String = ".dic")
    @system = List.new(@dir)
    @shared_base = List.new(File.join(@dir, "shared_base"))
    @shared_user = List.new(File.join(@dir, "shared_user"))
    @unique_base = List.new(File.join(@dir, "unique_base"))
    @unique_user = List.new(File.join(@dir, "unique_user"))
  end

  alias Dicts = Array(CvDict)

  @cc_cedict : CvDict? = nil
  @trungviet : CvDict? = nil
  @hanviet : CvDict? = nil
  @pinyins : CvDict? = nil
  @tradsim : CvDict? = nil

  def cc_cedict
    @cc_cedict ||= @system["cc_cedict"]
  end

  def trungviet
    @trungviet ||= @system["trungviet"]
  end

  def hanviet
    @hanviet ||= @system["hanviet"]
  end

  def pinyins
    @pinyins ||= @system["pinyins"]
  end

  def tradsim
    @tradsim ||= @system["tradsim"]
  end

  def generic(user : String = "local")
    [@shared_base["generic"], @shared_user["generic", user]]
  end

  def combine(user : String = "local")
    [@shared_base["combine"], @shared_user["combine", user]]
  end

  def suggest(user : String = "local")
    [@shared_base["suggest"], @shared_user["suggest", user]]
  end

  def unique(name : String, user = "local")
    [@unique_base[name], @unique_user[name, user]]
  end

  def for_convert(book : String? = nil, user = "local")
    dicts = generic(user)

    if book
      dicts.concat(unique(book, user))
    else
      dicts.concat(combine(user))
    end

    dicts
  end
end
