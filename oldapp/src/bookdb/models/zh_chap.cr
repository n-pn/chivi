require "json"

class ZhChap
  include JSON::Serializable

  getter csid = ""
  property title = ""
  property volume = ""

  def initialize(@csid : String, @title : String, @volume : String)
  end
end

class ZhList
  DIR = File.join("data", "zh_lists")

  def self.files : Array(String)
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.load!(site : String, bsid : String)
    new(site, bsid, preload: true)
  end

  getter site : String
  getter bsid : String

  getter file : String

  getter data = [] of ZhChap

  def initialize(@site : String, @bsid : String, preload : Bool = false)
    @file = File.join(DIR, "#{@site}.#{@bsid}.json")

    load!(@file) if preload
  end

  include Enumerable(ZhChap)
  delegate each, to: @data

  def load! : ZhList
    if File.exists?(@file)
      @data = Array(ZhChap).from_json(File.read(@file))
      puts "- loaded zh_list `#{@file}`".colorize(:cyan)
    else
      puts "- zh_list `#{@file} not found!`".colorize(:cyan)
    end

    self
  end

  def cached?
    File.exists?(@file)
  end

  def save! : ZhList
    File.write(@file, @data.to_json)

    self
  end
end
