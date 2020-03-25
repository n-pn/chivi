require "colorize"
require "benchmark"

require "../dict"

class Chivi::DictRepo
  alias DictList = Hash(String, Dict)
  alias UserList = Hash(String, DictList)

  property dicts : DictList
  property fixes : UserList

  def initialize(@dir : String, preload = false)
    @dicts = DictList.new
    @fixes = UserList.new { |h, k| h[k] = DictList.new }

    load_dir!(lazy: false) if preload
  end

  def load_dir!(lazy = true)
    count = 0

    rtime = Benchmark.realtime do
      Dir[File.join(@dir, "*.dic")].each do |file|
        name = File.basename(file, ".dic")

        count += load_fixes!(name, lazy)
        next if lazy && @dicts[name]?

        count += 1
        @dicts[name] = load_dic(name)
      end
    end

    puts "- Loaded #{count} files in #{rtime.total_seconds}s".colorize(:blue)
  end

  def load_fixes!(name : String, lazy = true)
    count = 0

    Dir[File.join(@dir, "#{name}.*.fix")].each do |file|
      puts file

      user = File.extname(File.basename(file, ".fix")).tr(".", "")

      next if lazy && @fixes[name][user]?

      count += 1
      @fixes[name][user] = load_fix(name, user)
    end

    count
  end

  def [](name : String, user = "admin") : Array(Dict)
    [get_dic(name), get_fix(name, user)]
  end

  def get_dic(name : String) : Dict
    @dicts[name] ||= load_dic(name)
  end

  def get_fix(name : String, user = "admin") : Dict
    @fixes[name][user] ||= load_fix(name, user)
  end

  def all_fix(name : String) : MHash
    @fixes[name]
  end

  def load_dic(name : String)
    Dict.new(File.join(@dir, "#{name}.dic"))
  end

  def load_fix(name : String, user : String = "root")
    Dict.new(File.join(@dir, "#{name}.#{user}.fix"))
  end
end
