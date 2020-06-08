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
    {@@CORE["pinyins", user], @@CORE["pinyins"]}
  end

  def self.tradsim(user : String = "local")
    {@@CORE["tradsim", user], @@CORE["tradsim"]}
  end

  def self.hanviet(user : String = "local")
    {@@CORE["hanviet", user], @@CORE["hanviet"]}
  end

  def self.generic(user : String = "local")
    {@@CORE["generic", user], @@CORE["generic"]}
  end

  def self.combine(user : String = "local")
    {@@CORE["combine", user], @@CORE["combine"]}
  end

  def self.suggest(user : String = "local")
    {@@CORE["suggest", user], @@CORE["suggest"]}
  end

  def self.shared(dict : String = "combine", user = "local")
    {@@CORE[dict, user], @@CORE[dict]}
  end

  def self.unique(dict : String = "tonghop", user = "local")
    {@@BOOK[dict, user], @@BOOK[dict]}
  end

  def self.for_convert(name : String = "tonghop", user : String = "local")
    [generic(user), combine(user), unique(name, user)]
  end

  def self.upsert_unique(key : String, val : String = "", dict = "tonghop", user = "local", mode = :new_first)
    user_dict, root_dict = unique(dict, user)

    user_dict.set(key, val, mode: mode)
    if user == "local" || user == "admin"
      root_dict.set(key, val, mode: mode)
    end
  end

  def self.upsert_shared(key : String, val : String = "", dict = "tonghop", user = "local", mode = :new_first)
    user_dict, root_dict = shared(dict, user)

    user_dict.set(key, val, mode: mode)
    if user == "local" || user == "admin"
      root_dict.set(key, val, mode: mode)
    end
  end

  def self.search_unique(term : String, dict : String = "tonghop", user = "local")
    vals = [] of String
    time : Time? = nil

    unique(dict, user).each do |dict|
      if item = dict.find(vals)
        vals.concat(iteml.vals)
        time ||= item.updated_at
      end
    end

    {vals.uniq, time.try(&.to_unix_ms)}
  end

  def self.search_shared(term : String, dict : String = "generic", user = "local")
    vals = [] of String
    time : Time? = nil

    shared(dict, user).each do |dict|
      if item = dict.find(vals)
        vals.concat(iteml.vals)

        time ||= item.updated_at
      end
    end

    {vals.uniq, time.try(&.to_unix_ms)}
  end
end
