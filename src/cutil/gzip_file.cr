require "compress/gzip"

class CV::GzipFile
  getter file : String

  def initialize(@file, @data = nil)
  end

  def read : String
    @data ||= File.open(@file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end

  def read(ttl : Time::Span | Month::Span)
    read(Time.utc - ttl)
  end

  def read(ttl = Time.utc(2021, 1, 1))
    state = check_state(ttl)
    return self.read if state == State::Fresh

    self.save!(yield)
    @data.not_nil!
  rescue
    state == Expire ? self.read : raise "File not found!"
  end

  enum State
    Fresh; Expire; Missing
  end

  def check_state(ttl : Time) : State
    return State::Missing unless stat = File.info?(file)
    stat.modification_time < expiry ? State::Expire : State::Fresh
  end

  def save!(@data : String)
    File.open(@file, "w") do |io|
      Compress::Gzip::Writer.open(io, &.print(@data))
    end
  end
end

# file = ".tmp/test.txt.gz"
# CV::FileUtils.save_gz(file, "test test test!")
# puts CV::FileUtils.read_gz(file)
