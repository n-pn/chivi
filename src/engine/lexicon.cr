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
    @@roots[name] ||= LxDict.load(File.join(@dir, "#{name}.dic"))
  end

  def load_user(name : String, user = "local")
    @@users[name][user] ||= LxDict.load(File.join(@dir, "#{name}.#{user}.fix"))
  end
end

class Lexicon
  getter home : LxRepo
  getter core : LxRepo
  getter book : LxRepo

  def initialize(@dir : String = ".dic", preload : Bool = false)
    @home = LxRepo.new(@dir, preload)
    @core = LxRepo.new(File.join(@dir, "core"), preload)
    @book = LxRepo.new(File.join(@dir, "book"), preload)
  end

  @cc_cedict : LxDict? = nil
  @trungviet : LxDict? = nil

  def cc_cedict
    @cc_cedict ||= @home["cc_cedict"]
  end

  def trungviet
    @trungviet ||= @home["trungviet"]
  end

  def pinyins(user : String = "local")
    {@core["pinyins"], @core["pinyins", user]}
  end

  def tradsim(user : String = "local")
    {@core["tradsim"], @core["tradsim", user]}
  end

  def hanviet(user : String = "local")
    {@core["hanviet"], @core["hanviet", user]}
  end

  def generic(user : String = "local")
    {@core["generic"], @core["generic", user]}
  end

  def combine(user : String = "local")
    {@core["combine"], @core["combine", user]}
  end

  def suggest(user : String = "local")
    {@core["suggest"], @core["suggest", user]}
  end

  def book(dict : String = "tong-hop", user = "local")
    {@book[dict], @book[dict, user]}
  end

  def for_convert(dict : String = "tong-hop", user : String = "local")
    [generic(user), combine(user), book(dict, user)]
  end
end
