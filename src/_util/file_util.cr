require "compress/gzip"

module FileUtil
  extend self

  def save_gz!(file : String, data : String)
    File.open(file, "w") do |io|
      Compress::Gzip::Writer.open(io, &.print(data))
    end
  end

  def read_gz!(file : String) : String
    File.open(file, "r") do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end

  @[AlwaysInline]
  def mtime(file : String) : Time?
    File.info?(file).try(&.modification_time)
  end

  @[AlwaysInline]
  def mtime_int(file : String) : Int64
    mtime(file).try(&.to_unix) || 0_i64
  end

  def fresh?(file : String, expiry : Time)
    self.mtime(file).try(&.>= expiry) || false
  end
end
