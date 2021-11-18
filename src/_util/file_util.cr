require "icu"
require "compress/gzip"

module CV::FileUtil
  extend self

  CSDET = ICU::CharsetDetector.new

  def read_utf8(file : String | Path, encoding : String? = nil)
    File.open(file, "r") { |io| read_utf8(io, encoding: encoding) }
  end

  def read_utf8(io : IO, encoding : String? = nil, csdet_limit = 500)
    unless encoding
      str = io.read_string(csdet_limit)
      csm = csdet.detect(str)

      encoding = csm.encoding
      io.rewind
    end

    io.set_encoding(encoding, invalid: :skip)
    io.gets_to_end
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

  def mtime(file : String) : Time?
    File.info?(file).try(&.modification_time)
  end

  def fresh?(file : String, expiry : Time)
    return false unless mtime = self.mtime(file)
    mtime >= expiry
  end
end
