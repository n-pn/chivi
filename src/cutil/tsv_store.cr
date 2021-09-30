require "colorize"

class CV::TsvStore
  getter file : String
  getter data = {} of String => Array(String)
  getter upds = {} of String => Array(String)

  delegate size, to: @data
  delegate has_key?, to: @data
  delegate each, to: @data
  delegate reverse_each, to: @data
  delegate clear, to: @data
  delegate empty?, to: @data

  def initialize(@file, mode : Int32 = 1)
    return if mode < 1
    load!(@file) if mode > 1 || File.exists?(@file)
  end

  private def label(file : String = @file)
    "<tsv_store> [#{file}]"
  end

  def load!(file : String = @file) : Nil
    count = 0

    timer = Time.measure do
      File.each_line(file) do |line|
        cls = line.split('\t', 2)
        key = cls[0]

        if vals = cls[1]?
          set(key, vals.split('\t'))
        else
          delete(key)
        end

        count += 1
      rescue err
        puts "- #{label(file)} error: #{err} on `#{line}`".colorize.red
      end
    end

    time = timer.total_milliseconds.round.to_i
    puts "- #{label(file)} loaded (lines: #{count}, time: #{time}ms)".colorize.blue

    save!(clean: true) if @data.size != count
  end

  def vals
    @data.values
  end

  def get(key : String)
    unless value = @data[key]?
      value = yield
      set(value)
    end

    value
  end

  def get!(key : String)
    unless value = @data[key]?
      value = yield
      set!(key, value)
    end

    value
  end

  def set!(key : String, vals : Array(String)) : Bool
    return false unless set(key, vals)
    @upds[key] = vals
    true
  end

  def set!(key : String, val : String)
    set!(key, [val])
  end

  def set!(key : String, val)
    set!(key, [val.to_s])
  end

  def set(key : String, vals : Array(String)) : Bool
    return false if get(key) == vals
    @data[key] = vals
    true
  end

  def set(key : String, vals : String) : Bool
    set(key, vals.split('\t'))
  end

  def set(key : String, val)
    set(key, [val.to_s])
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

  def fval_alt(key : String, alt : String)
    fval(key) || fval(alt)
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

  def save!(clean : Bool = false) : Nil
    output = clean ? @data : @upds

    if output.empty?
      File.delete(@file) if @data.empty? && File.exists?(@file)
      return
    end

    File.open(@file, clean ? "w" : "a") do |file|
      output.each_with_index do |(key, vals), idx|
        file << '\n' if idx > 0 || !clean
        file << key << '\t' << vals.join('\t')
      end
    end

    state, color = clean ? {"saved", :yellow} : {"updated", :light_yellow}
    puts "- #{label} #{state} (entries: #{output.size})".colorize(color)

    @upds.clear
  rescue err
    puts "- #{@file} saves error: #{err}".colorize.red
  end

  def clear_all!
    @data.clear
    @upds.clear
  end
end

# test = CV::TsvStore.new(".tmp/tsv_store.tsv", mode: 2)
# test.set("a", "a")
# test.set("b", "b")
# test.save!
