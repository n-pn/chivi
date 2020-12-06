require "colorize"
require "./vp_dict/*"

class Chivi::VpDict
  getter file : String # default read/save file
  getter size = 0      # dict size by unique keys

  getter dlock = 1 # default permission lock
  getter mtime = 0 # dict's modification time

  getter index = VpTrie.new   # fast trie lookup
  getter items = [] of VpTerm # all items loaded from files or memory

  def initialize(@file : String, @dlock : Int32 = 1)
  end

  def load!(file = @file) : Nil
    return unless File.exists?(file)

    label = File.basename(file)
    lines = 0

    elapse = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        upsert(VpTerm.parse(line, @dlock))
        lines += 1
      rescue err
        puts "[ERROR parsing <#{lines}> `#{label}`>: #{err}]".colorize.red
      end
    end

    elapse = elapse.total_milliseconds.round.to_i
    puts "<VP_DICT> [#{label}] loaded: #{lines} lines, elapse: #{elapse}ms".colorize.green

    # set mtime from file stats
    @mtime = VpTerm.mtime(File.info(file).modification_time) if @mtime == 0
  end

  def save!(file = @file, mode : Symbol = :full) : Nil
    label = File.basename(file)

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

    puts "<VP_DICT> [#{label}] saved: #{items.size} entries".colorize.yellow
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
      node.item = item = VpTerm.new(new_item.key, [] of String)
      item.plock = @dlock
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
