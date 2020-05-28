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

  getter base_dict : List
  getter core_root : List
  getter core_user : List
  getter book_root : List
  getter book_user : List

  def initialize(@dir : String = ".dic")
    @base_dict = List.new(@dir)

    @core_root = List.new(File.join(@dir, "core_root"))
    @core_user = List.new(File.join(@dir, "core_user"))
    @book_root = List.new(File.join(@dir, "book_root"))
    @book_user = List.new(File.join(@dir, "book_user"))
  end

  alias Dicts = Array(CvDict)

  @cc_cedict : CvDict? = nil
  @trungviet : CvDict? = nil

  def cc_cedict
    @cc_cedict ||= @base_dict["cc_cedict"]
  end

  def trungviet
    @trungviet ||= @base_dict["trungviet"]
  end

  def pinyins(user : String = "local")
    {@core_root["pinyins"], @core_user["pinyins", user]}
  end

  def tradsim(user : String = "local")
    {@core_root["tradsim"], @core_user["tradsim", user]}
  end

  def hanviet(user : String = "local")
    {@core_root["hanviet"], @core_user["hanviet", user]}
  end

  def generic(user : String = "local")
    {@core_root["generic"], @core_user["generic", user]}
  end

  def combine(user : String = "local")
    {@core_root["combine"], @core_user["combine", user]}
  end

  def suggest(user : String = "local")
    {@core_root["suggest"], @core_user["suggest", user]}
  end

  def book(dict : String = "tong-hop", user = "local")
    {@book_root[dict], @book_user[dict, user]}
  end

  def for_convert(dict : String = "tong-hop", user : String = "local")
    [generic(user), combine(user), book(dict, user)]
  end
end
