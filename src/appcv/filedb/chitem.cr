require "json"

class CV::Chinfo
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
end
