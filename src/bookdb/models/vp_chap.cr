require "json"

class VpChap
  include JSON::Serializable

  getter csid = ""
  property title = ""
  property volume = ""
  property urlslug = ""

  def initialize(@csid : String, @title : String, @volume : String)
    make_slug!
  end

  def make_slug!(words : Int32 = 12) : Void
    return if @title.empty?
    slug = Utils.slugify(@title, no_accent: true)
    @urlslug = slug.split("-").first(words).join("-")
  end
end

class VpList
  DIR = File.join("data", "vp_lists")

  def self.files : Array(String)
    Dir.glob(File.join(DIR, "*.json"))
  end

  def self.load!(site : String, bsid : String, user : String = "local")
    new(site, bsid, user, preload: true)
  end

  getter site : String
  getter bsid : String
  getter user : String

  getter file : String

  getter data = [] of VpChap

  def initialize(@site : String, @bsid : String, @user : String, preload : Bool = false)
    @file = File.join(DIR, "#{@site}.#{@bsid}.#{@user}.json")

    load!(@file) if preload
  end

  include Enumerable(VpChap)
  delegate each, to: @data

  def load! : VpList
    if File.exists?(@file)
      @data = Array(VpChap).from_json(File.read(@file))
      puts "- loaded vp_list `#{@file}`".colorize(:cyan)
    else
      puts "- vp_list `#{@file} not found!`".colorize(:cyan)
    end

    self
  end

  def cached?
    File.exists?(@file)
  end

  def save! : VpList
    File.write(@file, @data.to_json)

    self
  end
end
