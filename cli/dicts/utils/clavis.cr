require "../../../src/utils/normalize"

class Clavis
  DIR = File.join("var", "libcv", "initial")

  def self.path_for(file : String)
    File.join(DIR, file)
  end

  def self.load(file : String, preload = true)
    new(path_for(file), preload: preload)
  end

  SEP_0 = "="
  SEP_1 = "/"

  getter data = Hash(String, Array(String)).new
  forward_missing_to @data

  def initialize(@file : String, preload = true)
    load!(@file) if preload && File.exists?(@file)
  end

  def load!(file : String = @file, mode = :keep_new)
    count = 0

    elapsed_time = Time.measure do
      File.each_line(file) do |line|
        key, vals = line.strip.split(SEP_0, 2)

        key = Utils.normalize(key).join("")
        vals =
          vals.split(/[\/\|]/)
            .map(&.strip)
            .reject(&.empty?)
            .reject(&.includes?(":"))

        upsert(key, vals, mode)
        count += 1
      rescue
        puts "- <old_dict> error parsing line ##{count}: `#{line}`.".colorize(:red)
      end
    end

    elapse_time = elapsed_time.total_milliseconds.round.to_i
    puts "- <old_dict> [#{file.colorize(:yellow)}] loaded, \
            lines: #{count.colorize(:yellow)}, \
            time: #{elapse_time.colorize(:yellow)}ms"
  end

  def upsert(key : String, new_vals : Array(String), mode = :keep_new)
    if old_vals = @data[key]?
      case mode
      when :keep_new
        @data[key] = new_vals
      when :old_first
        old_vals.concat(new_vals)
      when :new_first
        @data[key] = new_vals.concat(old_vals)
      else
        return
      end
    else
      @data[key] = new_vals
    end
  end

  def delete(key)
    @data.delete(key)
  end

  def save!(file : String = @file)
    File.open(file, "w") do |io|
      @data.each do |key, vals|
        io << key << SEP_0
        vals.uniq.join(io, SEP_1)
        io << "\n"
      end
    end

    puts "- <old_dict> [#{file.colorize(:yellow)}] saved, entries: #{size.colorize(:yellow)}."
  end
end
