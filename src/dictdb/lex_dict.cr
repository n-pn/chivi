require "colorize"

# dict with fixed content, like cc_cedict or trungviet
class FixDict
  SEP0 = "ǁ"
  SEP1 = "¦"

  class Node
    getter key : String
    getter vals = [] of String
    getter trie = {} of Char => Node

    def initialize(@key)
    end
  end

  getter file : String
  getter time = Time.utc

  getter data = Node.new("")
  getter size = 0

  def initialize(@file, preload : Bool = false)
    load!(@file) if preload && exists?
  end

  def time=(time : Time)
    @time = time if @time < time
  end

  def exists?
    File.exists?(@file)
  end

  def load!(file : String = @file) : Void
    count = 0

    elapsed_time = Time.measure do
      File.each_line(file) do |line|
        key, value = line.split(SEP0, 2)
        set(key, value)
      rescue
        puts "- <fix_dict> error parsing line `#{line}`.".colorize(:red)
      end
    end

    puts "- <fix_dict> [#{file.colorize(:yellow)}] loaded, \
    lines: #{count.size.colorize(:yellow)}, \
    time: #{elapsed_time.total_milliseconds.colorize(:yellow)}ms"

    self.time = File.info(file).modification_time
  end

  def set(key : String, value : String = "", mode = :old_first)
    set(key, value.empty? ? [""] : value.split(SEP1))
  end

  def set(key : String, vals : Array(String), mode = :old_first) : Void
    node = key.chars.reduce(@data) do |node, char|
      node.trie[char] ||= Node.new(node.key + char)
    end

    @size -= 1 if vals.empty?
    @size += 1 if node.vals.empty?

    case mode
    when :new_first
      # put new vals ontop
      node.vals = vals.concat(node.vals)
    when :keep_new
      # overwrite old vals
      nodes.vals = vals
    when :keep_old
      # only update if previous is empty
      nodes.vals = vals if node.vals.empty?
    else # :old_first
      # append new vals
      node.vals.concat(vals)
    end
  end
end
