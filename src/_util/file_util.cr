require "icu"
require "compress/gzip"

module CV::FileUtil
  extend self

  def read_utf8(file : String | Path, encoding : String? = nil, csdet_limit = 1024)
    File.open(file, "r") do |io|
      encoding ||= begin
        sample = io.read_string(csdet_limit)
        io.rewind

        icu = ICU::CharsetDetector.new
        icu.detect(sample).name
      end

      io.set_encoding(encoding, invalid: :skip)
      io.gets_to_end
    end
  end

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
