require "../../../src/_utils/normalize"

class Clavis
  SEP_0 = "="
  SEP_1 = "/"

  getter data = Hash(String, Array(String)).new
  forward_missing_to @data

  def initialize(@file : String, preload = true)
    load!(@file) if preload && File.exists?(@file)
  end

  def load!(file : String = @file)
    count = 0

    elapsed_time = Time.measure do
      File.each_line(file) do |line|
        key, vals = line.strip.split(SEP_0, 2)

        key = Utils.normalize(key).join("")
        vals = vals.split(/[\/\|]/)

        @data[key] = vals
        count += 1
      rescue
        puts "- <clavis> error parsing line `#{line}`.".colorize(:red)
      end
    end

    elapse_time = elapsed_time.total_milliseconds.round.to_i
    puts "- <clavis> [#{file.colorize(:yellow)}] loaded, \
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
        vals.join(io, SEP_1)
        io << "\n"
      end
    end

    puts "- <clavis> [#{file.colorize(:yellow)}] saved, entries: #{size.colorize(:yellow)}."
  end
end
