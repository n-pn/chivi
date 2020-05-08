module Utils
  alias Span = Time::Span | Time::MonthSpan

  def self.read_file(file : String, time : Time | Span)
    File.read(file) unless outdated?(file, time)
  end

  TIME_SPAN = 1.hours

  def self.outdated?(file : String, time : Span = TIME_SPAN)
    outdated?(file, Time.utc - time)
  end

  def self.outdated?(file : String, time : Time = Time.utc - TIME_SPAN)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end
end
