require "compress/gzip"

module CV::FileUtils
  extend self

  EXPIRY = Time.utc(2000, 1, 1)

  def read(file : String, expiry = EXPIRY)
    return unless recent?(file, expiry)
    return File.read(file) unless file.ends_with?(".gz")

    File.open(gz_file) do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end

  def read_gz(file : String, expiry = EXPIRY)
    gz_file = file + ".gz"

    if recent?(gz_file, expiry)
    elsif recent?(file, expiry)
      File.read(file)
    end
  end

  def save_gz(file : String, input : String)
    File.open(file + ".gz", "w") do |io|
      Compress::Gzip::Writer.open(io, &.print(input))
    end
  end

  def recent?(file : String, expiry : Time) : Bool
    return false unless stat = File.info?(file)
    stat.modification_time >= expiry
  end
end

# file = ".tmp/test.txt.gz"
# CV::FileUtils.save_gz(file, "test test test!")
# puts CV::FileUtils.read_gz(file)
