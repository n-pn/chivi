require "colorize"

class CV::ValueMap
  @@klass = "value_map"

  getter file : String

  getter data = {} of String => Array(String)
  getter upds = {} of String => Array(String)

  delegate size, to: @data
  delegate has_key?, to: @data
  delegate each, to: @data
  delegate reverse_each, to: @data
  delegate clear, to: @data

  def initialize(@file, mode : Int32 = 1)
    return if mode < 1
    load!(@file) if mode > 1 || File.exists?(@file)
  end

  def label_for(file : String = @file)
    dir = File.basename(File.dirname(file))
    "<#{@@klass}> [#{dir}/#{File.basename(file, ".tsv")}]"
  end

  def load!(file : String = @file) : Nil
    count = 0
    label = label_for(file)

    timer = Time.measure do
      File.each_line(file) do |line|
        cls = line.split('\t', 2)
        key = cls[0]

        if vals = cls[1]?
          upsert(key, vals.split('\t'))
        else
          delete(key)
        end

        count += 1
      rescue err
        puts "- #{label} error: #{err} on `#{line}`".colorize.red
      end
    end

    time = timer.total_milliseconds.round.to_i
    puts "- #{label} loaded (lines: #{count}, time: #{time}ms)".colorize.blue
    save!(mode: :full) if @data.size != count
  end

  def vals
    @data.values
  end

  def upsert!(key : String, vals : Array(String))
    return false unless upsert(key, vals)
    @upds[key] = vals
    true
  end

  def upsert!(key : String, val : String)
    upsert!(key, [val])
  end

  def upsert!(key : String, val)
    upsert!(key, [val.to_s])
  end

  def upsert(key : String, vals : Array(String)) : Bool
    return false if get(key) == vals
    @data[key] = vals
    true
  end

  def upsert(key : String, vals : String) : Bool
    upsert(key, vals.split('\t'))
  end

  def get(key : String) : Array(String)?
    @data[key]?
  end

  def delete(key : String) : Bool
    !!@data.delete(key)
  end

  def delete!(key : String) : Nil
    return unless delete(key)
    File.open(@file, "a") { |io| io.puts(key) }
  end

  def fval(key : String)
    get(key).try(&.first?)
  end

  def ival(key : String, df : Int32 = 0)
    fval(key).try(&.to_i?) || df
  end

  def ival_64(key : String, df : Int64 = 0_i64)
    fval(key).try(&.to_i64?) || df
  end

  def unsaved
    @upds.size
  end

  def save!(out_file : String = @file, mode : Symbol = :full) : Nil
    label = label_for(file)

    case mode
    when :full
      puts "- #{label} saved (entries: #{@data.size})".colorize.yellow
      File.open(out_file, "w") do |io|
        each do |key, vals|
          io << key << '\t' << vals.join('\t') << "\n"
        end
      end
    when :upds
      return if upds.size == 0

      puts "- #{label} updated (entries: #{@upds.size})".colorize.light_yellow
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
    puts "- #{out_file} saves error: #{err}".colorize.red
  end
end

# test = CV::ValueMap.new(".tmp/value_map.tsv", mode: 2)
# test.upsert("a", "a")
# test.upsert("b", "b")
# test.save!
