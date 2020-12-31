require "colorize"
require "./vp_dict/*"

class CV::VpDict
  getter file : String    # default read/save file
  getter size : Int32 = 0 # dict size by unique keys

  getter dtype : Int32 = 0 # dict type
  getter dlock : Int32 = 1 # default permission lock
  getter mtime : Int32 = 0 # dict's modification time

  getter index = VpTrie.new   # fast trie lookup
  getter items = [] of VpTerm # all items loaded from files or memory

  def initialize(@file : String, @dtype = 0, @dlock = 1, preload : Bool = true)
    load!(@file) if preload && File.exists?(file)
  end

  def load!(file = @file) : Nil
    label = File.basename(file)
    lines = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        upsert(VpTerm.parse(line, dtype: @dtype, dlock: @dlock))
        lines += 1
      rescue err
        puts "[ERROR parsing <#{lines}> `#{label}`>: #{err}]".colorize.red
      end
    end

    tspan = tspan.total_milliseconds.round.to_i
    puts "<VP_DICT> [#{label}] loaded: #{lines} lines, time: #{tspan}ms".colorize.green

    # set mtime from file stats
    @mtime = VpTerm.mtime(File.info(file).modification_time) if @mtime == 0
  end

  def save!(file = @file, mode : Symbol = :full) : Nil
    label = File.basename(file)

    tspan = Time.measure do
      File.open(file, "w") do |io|
        case mode
        when :full
          @items.each(&.println(io, @dlock))
        when :best
          @index.each(&.println(io, @dlock))
        else
          raise "Unsupported write mode <#{mode}>!"
        end
      end
    end

    tspan = tspan.total_milliseconds.round.to_i
    puts "<VP_DICT> [#{label}] saved: #{items.size} entries, time: #{tspan}ms".colorize.yellow
  end

  def upsert(key : String, vals : Array(String), attr : String = "")
    upsert(VpTerm.new(key, vals, attr, dtype: @dtype, plock: @dlock))
  end

  # return old entry if exists
  def upsert(new_item : VpTerm) : Tuple(Bool, VpTerm?)
    @items << new_item
    @mtime = new_item.mtime if @mtime < new_item.mtime

    # find existing node or force creating new one
    node = @index.find!(new_item.key)

    if item = node.item
      {item.merge!(new_item), item}
    else
      item = VpTerm.new(new_item.key, [] of String, dtype: @dtype, plock: @dlock)

      node.item = item
      @size += 1

      {item.merge!(new_item), nil}
    end
  end

  # save to disk, return old entry if exists
  def upsert!(new_item : VpTerm) : Tuple(Bool, VpTerm?)
    File.open(@file, "a") { |io| item.println(io, @dlock) }
    upsert(item)
  end

  def find(key : String) : VpTerm?
    @index.find(key).try(&.item)
  end

  delegate scan, to: @index
  delegate each, to: @index
end
