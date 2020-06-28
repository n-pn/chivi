module Utils
  alias Span = Time::Span | Time::MonthSpan

  def self.read_file(file : String, time : Time | Span)
    File.read(file) unless file_outdated?(file, time)
  end

  TIME_SPAN = 1.hours

  def self.file_outdated?(file : String, time : Span = TIME_SPAN)
    file_outdated?(file, Time.utc - time)
  end

  def self.file_outdated?(file : String, time : Time = Time.utc - TIME_SPAN)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end
end
