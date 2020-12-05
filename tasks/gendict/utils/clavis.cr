class Clavis
  DIR = "_db/cvdict/_inits"

  def self.load(fname : String, preload = true)
    new("#{DIR}/#{fname}").tap { |x| x.load! if preload }
  end

  def self.vals(input : String, seps = /[\/\|]/)
    input
      .split(seps)
      .map(&.strip)
      .reject(&.empty?)
      .reject(&.includes?(":"))
  end

  SEP_0 = "="
  SEP_1 = "/"

  getter data = Hash(String, Array(String)).new
  forward_missing_to @data

  def initialize(@file : String)
  end

  def load!(file = @file, mode = :keep_new)
    label = File.basename(file)
    lines = 0

    elapse = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.empty?

        key, value = line.split(SEP_0)
        upsert(key, Clavis.vals(value), mode)

        lines += 1
      rescue err
        puts "[<#{label}> error parsing ##{lines} `#{line}`: #{err}".colorize.red
      end
    end

    elapse = elapse.total_milliseconds.round.to_i
    puts "[CLAVIS: #{file} loaded: #{lines} lines, time: #{elapse}ms]".colorize.green
  end

  def save!(file : String = @file)
    File.open(file, "w") do |io|
      @data.each do |key, vals|
        io << key << SEP_0 << vals.uniq.join(SEP_1) << "\n"
      end
    end

    puts "[CLAVIS: #{file}] saved, entries: #{size}]".colorize(:yellow)
  end

  def upsert(key : String, new_vals : Array(String), mode = :keep_new)
    unless old_vals = @data[key]?
      old_vals = [] of String
    end

    @data[key] =
      case mode
      when :keep_new
        new_vals
      when :old_first
        old_vals.concat(new_vals)
      when :new_first
        new_vals.concat(old_vals)
      else
        old_vals.empty? ? new_vals : old_vals
      end
  end
end
