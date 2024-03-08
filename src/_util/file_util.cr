require "icu"
require "compress/gzip"

module FileUtil
  @[AlwaysInline]
  def self.read(fpath : String | Path, ttl : Time = Time.utc - 10.years, encoding : String? = nil)
    self.read_utf8(fpath, encoding: encoding) if self.status(fpath, ttl: ttl) > 0
  end

  @[AlwaysInline]
  def self.status(fpath : String, ttl : Time = Time.utc - 10.years)
    mtime = self.mtime(fpath)
    !mtime ? -1 : mtime > ttl ? 1 : 0
  end

  @[AlwaysInline]
  def self.mtime(fpath : String | Path) : Time?
    File.info?(fpath).try(&.modification_time)
  end

  @[AlwaysInline]
  def self.mtime_int(fpath : String | Path) : Int64
    self.mtime(fpath).try(&.to_unix) || 0_i64
  end

  CSDET = ICU::CharsetDetector.new

  def self.read_utf8(path : String | Path, encoding : String? = nil)
    File.open(path, "r") do |file|
      encoding ||= begin
        head = file.read_string({file.size, 512}.min)
        file.rewind
        CSDET.detect(head).name
      end

      file.set_encoding(encoding, invalid: :skip)
      file.gets_to_end
    end
  end

  def self.save_gz!(file : String, data : String)
    File.open(file, "w") do |io|
      Compress::Gzip::Writer.open(io, &.print(data))
    end
  end

  def self.read_gz!(file : String) : String
    File.open(file, "r") do |io|
      Compress::Gzip::Reader.open(io, &.gets_to_end)
    end
  end
end
