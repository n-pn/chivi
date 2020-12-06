class QtDict
  DIR = "_db/cvdict/_inits"

  def self.load(fname : String, preload = true)
    new("#{DIR}/#{fname}").tap { |x| x.load! if preload }
  end

  def self.vals(input : String, seps = /[\/\|]/)
  end

  SEP_0 = "="
  SEP_1 = "/"

  getter data = Hash(String, Array(String)).new
  forward_missing_to @data

  def initialize(@file : String)
  end

  def load!(file : String = @file, mode : Symbol = :keep_new)
    label = File.basename(file)
    lines = 0

    elapse = Time.measure do
      File.each_line(file) do |line|
        line = line.strip
        next if line.empty?

        key, vals = parse_line(line)
        upsert(key, vals, mode)

        lines += 1
      rescue err
        puts "[ERROR loading <#{label}>: #{err}, line: `#{line}`]".colorize.red
      end
    end

    elapse = elapse.total_milliseconds.round.to_i
    puts "<QT_DICT> [#{label}] loaded: #{lines} lines, time: #{elapse}ms".colorize.green
  end

  def save!(file : String = @file)
    File.open(file, "w") do |io|
      @data.each do |key, vals|
        io << key << SEP_0 << vals.uniq.join(SEP_1) << "\n"
      end
    end

    puts "<QT_DICT> [#{file}] saved, entries: #{@data.size}".colorize(:yellow)
  end

  def parse_line(line : String)
    key, value = line.split(SEP_0, 2)
    vals = value
      .split(/[\/|]/)
      .map(&.strip)
      .reject(&.empty?)

    {key, vals}
  end

  def upsert(key : String, new_vals : Array(String), mode : Symbol = :keep_new)
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
