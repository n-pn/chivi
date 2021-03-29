require "compress/gzip"

module CV::FileUtils
  extend self

  EXPIRY = Time.utc(2000, 1, 1)

  def read(file : String, expiry = EXPIRY)
    File.read(file) if recent?(file, expiry)
  end

  def read_gz(file : String, expiry = EXPIRY)
    gz_file = file + ".gz"

    if recent?(gz_file, expiry)
      File.open(gz_file) { |io|
        Compress::Gzip::Reader.open(io, &.gets_to_end)
      }
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
