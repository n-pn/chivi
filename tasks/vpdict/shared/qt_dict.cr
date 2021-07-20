class QtDict
  DIR = "_db/vpinit"

  def self.load(fname : String, preload : Bool = true)
    new(File.join(DIR, fname), preload: preload)
  end

  SEP_0 = "="
  SEP_1 = "/"

  getter data = Hash(String, Array(String)).new
  # delegate each, to: @data
  # delegate each, to: @data
  # delegate has_key?, to: @data
  forward_missing_to @data

  def initialize(@file : String, preload : Bool = false)
    load!(@file) if preload && File.exists?(@file)
  end

  def fval(key : String)
    @data[key]?.try(&.first?)
  end

  def load!(file : String = @file, mode : Symbol = :keep_new)
    label = File.basename(file)
    lines = 0

    tspan = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.empty?

        key, vals = parse_line(line)
        set(key, vals, mode)

        lines += 1
      rescue err
        puts "[ERROR loading <#{label}>: #{err}, line: `#{line}`]".colorize.red
      end
    end

    tspan = tspan.total_milliseconds.round.to_i
    puts "- <qt_dict> [#{label}] loaded: #{lines} lines, time: #{tspan}ms".colorize.green
  end

  def save!(file : String = @file)
    tspan = Time.measure do
      File.open(file, "w") do |io|
        @data.each do |key, vals|
          io << key << SEP_0 << vals.uniq.join(SEP_1) << "\n"
        end
      end
    end

    label = File.basename(file)
    tspan = tspan.total_milliseconds.round.to_i
    puts "- <qt_dict> [#{label}] saved: #{@data.size} entries, time: #{tspan}ms".colorize.yellow
  end

  def parse_line(line : String)
    key, value = line.split(SEP_0, 2)
    vals = value
      .split(/[\/|]/)
      .map(&.strip)
      .reject(&.empty?)

    {key, vals}
  end

  def set(key : String, new_vals : Array(String), mode : Symbol = :keep_new)
    unless old_vals = @data[key]?
      old_vals = [] of String
    end

    @data[key] =
      case mode
      when :keep_new
        new_vals
      when :old_first
        old_vals.concat(new_vals).uniq
      when :new_first
        new_vals.concat(old_vals).uniq
      else
        old_vals.empty? ? new_vals : old_vals
      end
  end
end
