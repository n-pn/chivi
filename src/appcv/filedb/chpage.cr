require "json"
require "file_utils"
require "../../cutil/ram_cache"

class CV::Chpage
  include JSON::Serializable

  getter chidx : Int32
  getter schid : String

  property title : String
  property chvol : String
  property uslug : String

  property utime : Int64
  property chars : Int32
  property parts : Int32

  def initialize(parts : Array(String), @chidx)
    @schid = parts[0]

    @title = parts[1]? || ""
    @chvol = parts[2]? || ""

    @utime = parts[3]?.try(&.to_i64?) || 0_i64
    @chars = parts[4]?.try(&.to_i?) || 0
    @parts = parts[5]?.try(&.to_i?) || 0

    @uslug = parts[6]? || ""
  end

  def to_s(io : IO)
    {@schid, @title, @chvol, @utime, @chars, @parts, @uslug}.join(io, "\t")
  end

  def trans!(cvmtl : MtCore)
    @title = cvmtl.cv_title(@title).to_s
    @chvol = @chvol.empty? ? "Chính văn" : cvmtl.cv_title(@chvol).to_s
    @uslug = TextUtils.tokenize(@title).first(10).join("-")

    self
  end

  ##################################

  PSIZE = 32
  VPDIR = "_db/chtran"

  STALE = 24.hours
  CACHE = RamCache(String, Array(self)).new(2048, STALE)

  def self.pgidx(index : Int32)
    index // PSIZE
  end

  def self.init_page!(chlist, cvmtl, pgidx)
    chpage = [] of Chpage

    start = pgidx * PSIZE
    (start + 1).upto(start + PSIZE) do |chidx|
      break unless chinfo = chlist.get(chidx.to_s)
      chpage << Chpage.new(chinfo, chidx).trans!(cvmtl)
    end

    chpage
  end

  def self.load_page!(sname : String, snvid : String, pgidx : Int32)
    file = path(sname, snvid, pgidx)

    CACHE.get(file) do
      if fresh?(file)
        lines = File.read_lines(file)
        lines.map_with_index(pgidx * PSIZE + 1) { |x, i| new(x.split("\t"), i) }
      else
        yield.tap { |x| save!(file, x) }
      end
    end
  end

  def self.load_last!(sname : String, snvid : String, total : Int32)
    file = path(sname, snvid, -1)

    CACHE.get(file) do
      if fresh?(file)
        lines = File.read_lines(file)
        lines.map_with_index(0) { |x, i| new(x.split("\t"), total - i) }
      else
        yield.tap { |x| save!(file, x) }
      end
    end
  end

  def self.save!(file : String, data : Array(self)) : Nil
    FileUtils.mkdir_p(File.dirname(file))
    File.write(file, data.map(&.to_s).join("\n"))
  end

  private def self.fresh?(file : String, stale = STALE)
    stale = Time.utc - stale if stale.is_a?(Time::Span)
    File.info?(file).try(&.modification_time.>= stale) || false
  end

  def self.forget!(sname : String, snvid : String, pgidx : Int32)
    file = path(sname, snvid, pgidx)
    CACHE.delete(file)
    File.delete(file) if File.exists?(file)
  end

  def self.path(sname : String, snvid : String, pgidx : Int32)
    return "#{VPDIR}/#{sname}/#{snvid}/#{pgidx}.tsv"
  end
end
