module Utils
  alias TimeSpan = Time::Span | Time::MonthSpan

  def self.read_file(file : String)
    File.read(file) if File.exists?(file)
  end

  def self.read_file(file : String, time : Time | TimeSpan)
    File.read(file) unless file_outdated?(file, time)
  end

  def self.file_outdated?(file : String, span : TimeSpan)
    file_outdated?(file, Time.utc - span)
  end

  def self.file_outdated?(file : String, time : Time)
    return true unless File.exists?(file)
    File.info(file).modification_time < time
  end
end
