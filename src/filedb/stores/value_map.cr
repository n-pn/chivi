require "colorize"

class CV::ValueMap
  getter file : String

  getter data = {} of String => Array(String)
  getter upds = {} of String => Array(String)

  delegate size, to: @data
  delegate has_key?, to: @data
  delegate each, to: @data
  delegate reverse_each, to: @data
  delegate clear, to: @data

  def initialize(@file, mode : Int32 = 1)
    @label = "<#{{{ @type.stringify.underscore }}}> [#{File.basename(@file)}]"

    return if mode < 1
    load!(@file) if mode > 1 || File.exists?(@file)
  end

  def load!(file : String = @file) : Nil
    count = 0

    timer = Time.measure do
      File.each_line(file) do |line|
        cls = line.split('\t', 2)

        set(cls[0], cls[1]? || "")
        count += 1
      rescue err
        puts "- #{@label} error: #{err} on `#{line}`".colorize.red
      end
    end

    time = timer.total_milliseconds.round.to_i
    puts "- #{@label} loaded (lines: #{count}, time: #{time}ms)".colorize.blue
  end

  def add(key : String, vals : Array(String))
    return false unless set(key, vals)
    @upds[key] = vals
    true
  end

  def set(key : String, vals : String) : Bool
    set(key, vals.split('\t'))
  end

  def set(key : String, vals : Array(String)) : Bool
    return false if get(key) == vals
    @data[key] = vals
    true
  end

  def get(key : String) : Array(String)?
    @data[key]?
  end

  def del(key : String) : Nil
    @data.delete(key)
  end

  def fval(key : String)
    get(key).try(&.first?)
  end

  def unsaved
    @ups.size
  end

  def save!(out_file : String = @file, mode : Symbol = :full) : Nil
    case mode
    when :full
      puts "- #{@label} saved (entries: #{@data.size})".colorize.yellow
      File.open(out_file, "w") do |io|
        each do |key, vals|
          io << key << '\t' << vals.join('\t') << "\n"
        end
      end
    when :upds
      puts "- #{@label} updated (entries: #{@upds.size})".colorize.light_yellow
      File.open(out_file, "a") do |io|
        @upds.each do |key, vals|
          io << key << '\t' << vals.join('\t') << "\n"
        end
      end
    else
      raise "Unknown save mode `#{mode}`!"
    end

    @upds.clear
  rescue err
    puts "- #{@label} saves error: #{err}".colorize.red
  end
end

# test = CV::ValueMap.new(".tmp/value_map.tsv", mode: 2)
# test.set("a", "a")
# test.set("b", "b")
# test.save!
