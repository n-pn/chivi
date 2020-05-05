module Utils
  def self.read_file(file : String, expiry : Time | Time::Span)
    return if outdated?(file, expiry)
    File.read(file)
  end

  def self.outdated?(file : String, span : Time::Span)
    outdated?(file, Time.utc - span)
  end

  def self.outdated?(file : String, etag : Time = Time.utc - 3.hours)
    return true unless File.exists?(file)
    etag > File.info(file).modification_time
  end
end
