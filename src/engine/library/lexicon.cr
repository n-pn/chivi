require "colorize"
require "./lexicon/*"

class Chivi::Lexicon
  getter file : String # default read/save file
  getter size = 0      # dict size by unique keys

  getter dlock = 1 # default permission lock
  getter mtime = 0 # dict's modification time

  getter index = VpTrie.new   # fast trie lookup
  getter items = [] of VpItem # all items loaded from files or memory

  def initialize(@file : String, @dlock : Int32 = 1)
  end

  def load!(file = @file) : Nil
    label = File.basename(file)
    lines = 0

    elapse = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.blank?

        upsert(VpItem.parse(line, @dlock))
        lines += 1
      rescue err
        puts "[ERROR parsing <#{lines}> `#{label}`>: #{err}]".colorize.red
      end
    end

    elapse = elapse.total_milliseconds.round.to_i
    puts "[DICT <#{label}> loaded: #{lines} lines, elapse: #{elapse}ms]".colorize.green

    # set mtime from file stats
    @mtime = VpItem.mtime(File.info(file).modification_time) if @mtime == 0
  end

  def save!(file = @file) : Nil
    label = File.basename(file)

    File.open(file, "a") do |io|
      @items.each do |item|
        item.println(io, @dlock)
      end
    end

    puts "[DICT <#{label}> saved: #{items.size} entries]".colorize.yellow
  end

  # return old entry if exists
  def upsert(new_item : VpItem) : VpItem?
    @items << new_item
    @mtime = new_item.mtime if @mtime < new_item.mtime

    node = @index.find!(key) # find existing node or force creating new ones

    if old_item = node.item
      old_item.merge!(new_item)
    else
      item = VpItem.new(new_item.key, [""]) # treat non existing entries as deleted one

      item.plock = @dlock
      item.merge!(new_item) # only merge if new_item has better plock

      node.item = item
      @size += 1
    end

    old_item
  end

  # save to disk, return old entry if exists
  def upsert!(new_item : VpItem) : VpItem?
    File.open(@file, "a") { |io| item.println(io, @dlock) }
    upsert(item)
  end

  def find(key : String) : VpItem?
    @index.find(key).try(&.item)
  end

  delegate scan, to: @index
  delegate each, to: @index
end
