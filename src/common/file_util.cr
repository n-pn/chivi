module FileUtil
  extend self

  EXPIRY = Time.utc(2000, 1, 1)

  def read(file : String, expiry : Time = EXPIRY)
    File.read(file) unless expire?(file, expiry)
  end

  def expire?(file : String, expiry : Time)
    return true unless File.exists?(file)
    File.info(file).modification_time < expiry
  end

  def each_line(file : String, label : String = "read_file")
    count = 0

    elapsed = Time.measure do
      File.each_line(file) do |line|
        yield(line)
        count += 1
      end
    end

    elapsed = elapsed.total_milliseconds.round.to_i
    puts "- <#{label.colorize.blue}> [#{file.colorize.blue}] loaded \
            (lines: #{count.colorize.blue}, \
            time: #{elapsed.colorize.blue}ms)."
  end

  def log_error(label : String, line : String, err : Exception)
    # TODO: using Log class?
    puts "- <#{label.colorize.red}> error parsing `#{line.colorize.red}`\
            : #{err.colorize.red}"
  end

  def append(file : String)
    File.open(file, "a") { |io| yield(io) }
    # TODO: printing something?
  end

  def save(file : String, label : String = "read_file", count : Int32 = 0)
    elapsed = Time.measure do
      File.open(file, "w") { |io| yield(io) }
    end

    elapsed = elapsed.total_milliseconds.round.to_i
    puts "- <#{label.colorize.green}> [#{file.colorize.green}] saved, \
            (entries: #{count.colorize.green}, \
            time: #{elapsed.colorize.green}ms)."
  end
end
