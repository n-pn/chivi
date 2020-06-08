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

  def self.shared(dict : String = "combine", user = "local")
    {@@CORE[dict], @@CORE[dict, user]}
  end

  def self.unique(dict : String = "tonghop", user = "local")
    {@@BOOK[dict], @@BOOK[dict, user]}
  end

  def self.for_convert(name : String = "tonghop", user : String = "local")
    [generic(user), combine(user), unique(name, user)]
  end

  def self.upsert(key : String, val : String = "", dict : String = "tonghop", user : String = "local") : Void
    case dict
    when "generic"
      # prevent missing translation
      if key.size == 1 && val.empty?
        hanviet_root, hanviet_user = hanviet(user)
        if hanviet = hanviet_user.find(key) || hanviet_root.find(key)
          val = hanviet.vals.first
        end
      end
      upsert_shared(key, val, "generic", user, mode: :new_first)
    when "hanviet"
      return if key.size == 1 && val.empty?
      upsert_shared(key, val, "hanviet", user, mode: :new_first)
    when "suggest", "combine", "pinyins", "tradsim"
      upsert_shared(key, val, dict, user, mode: :new_first)
    else
      dict = "tonghop" if dict.empty?
      upsert_unique(key, val, dict, user, mode: :new_first)
    end
  end

  def self.upsert_unique(key : String, val = "", dict = "tonghop", user = "local", mode = :new_first)
    root_dict, user_dict = unique(dict, user)

    user_dict.set(key, val, mode: mode)
    if user == "local" || user == "admin"
      root_dict.set(key, val, mode: mode)
    end

    if val.empty?
      upsert_shared(key, val, "combine", user, mode: :keep_new)
    else
      upsert_shared(key, val, "suggest", user, mode: :new_first)
    end
  end

  def self.upsert_shared(key : String, val = "", dict = "tonghop", user = "local", mode = :new_first)
    root_dict, user_dict = shared(dict, user)

    user_dict.set(key, val, mode: mode)
    if user == "local" || user == "admin"
      root_dict.set(key, val, mode: mode)
    end
  end

  def self.search_unique(term : String, dict : String = "tonghop", user = "local")
    special_root, special_user = unique(dict, user)
    combine_root, combine_user = shared("combine", user)

    vals = [] of String
    time : Time? = nil

    if item = special_user.find(term)
      vals.concat(item.vals)
      time = item.updated_at
    end

    if item = special_root.find(term)
      vals.concat(item.vals)
    end

    if item = combine_user.find(term)
      vals.concat(item.vals)
    end

    if item = combine_root.find(term)
      vals.concat(item.vals)
    end

    {vals, time}
  end

  def self.search_shared(term : String, dict : String = "generic", user = "local")
    root_dict, user_dict = shared(dict, user)

    vals = [] of String
    time : Time? = nil

    if item = user_dict.find(term)
      vals.concat(item.vals)
      time = item.updated_at
    end

    if item = root_dict.find(term)
      vals.concat(item.vals)
    end

    {vals, time}
  end
end
