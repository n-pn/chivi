require "./lexicon/*"

# Loading dicts

class LxRepo
  alias LxHash = Hash(String, LxDict)

  getter roots : LxHash
  getter users : Hash(String, LxHash)

  def initialize(@dir : String, preload : Bool = false)
    @roots = LxHash.new
    @users = Hash(String, LxHash).new { |h, k| h[k] = LxHash.new }

    load_all! if preload
  end

  def load_all! : Void
    time1 = Time.monotonic
    load_root_dicts!
    load_user_dicts!
    time2 = Time.monotonic
    elapsed = (time2 - time1).total_seconds

    puts "- Loaded all `#{@dir.colorize(:yellow)}`, time: #{elapsed.colorize(:yellow)}s"
  end

  def load_root_dicts! : Void
    root_files = Dir.glob(File.join(@dir, "*.dic"))
    root_files.each do |file|
      name = File.basename(file, ".dic")
      @roots[name] = load_root(name)
    end
  end

  def load_user_dicts!(name : String? = nil) : Void
    glob = name ? "#{name}.*.fix" : "*.*.fix"

    user_files = Dir.glob(File.join(@dir, glob))
    user_files.each do |file|
      name, user = File.basename(file, ".fix").split(".", 2)
      @users[name][user] = load_user(name)
    end
  end

  def users(name : String)
    load_user_dicts!(name)
    @users[name]
  end

  def [](name : String)
    load_root(name)
  end

  def [](name : String, user : String)
    load_user(name, user)
  end

  def load_root(name : String)
    @roots[name] ||= LxDict.load(File.join(@dir, "#{name}.dic"))
  end

  def load_user(name : String, user = "local")
    @users[name][user] ||= LxDict.load(File.join(@dir, "#{name}.#{user}.fix"))
  end
end

module Lexicon
  DIR = "data/lx_dicts"

  @@HOME = LxRepo.new(DIR)
  @@CORE = LxRepo.new(File.join(DIR, "core"))
  @@BOOK = LxRepo.new(File.join(DIR, "book"))

  @@cc_cedict : LxDict? = nil
  @@trungviet : LxDict? = nil

  def self.cc_cedict
    @@cc_cedict ||= @@HOME["cc_cedict"]
  end

  def self.trungviet
    @@trungviet ||= @@HOME["trungviet"]
  end

  def self.pinyins(user : String = "local")
    {@@CORE["pinyins"], @@CORE["pinyins", user]}
  end

  def self.tradsim(user : String = "local")
    {@@CORE["tradsim"], @@CORE["tradsim", user]}
  end

  def self.hanviet(user : String = "local")
    {@@CORE["hanviet"], @@CORE["hanviet", user]}
  end

  def self.generic(user : String = "local")
    {@@CORE["generic"], @@CORE["generic", user]}
  end

  def self.combine(user : String = "local")
    {@@CORE["combine"], @@CORE["combine", user]}
  end

  def self.suggest(user : String = "local")
    {@@CORE["suggest"], @@CORE["suggest", user]}
  end

  def self.special(dict : String = "tong-hop", user = "local")
    {@@BOOK[dict], @@BOOK[dict, user]}
  end

  def self.for_convert(name : String = "tong-hop", user : String = "local")
    [generic(user), combine(user), special(name, user)]
  end
end
