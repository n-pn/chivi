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
end
