require "json"

class CV::ChItem
  include JSON::Serializable

  property chidx : Int32
  property schid : String

  @[JSON::Field(ignore: true)]
  property title_zh = ""
  @[JSON::Field(ignore: true)]
  property chvol_zh = ""

  property utime = 0_i64
  property chars = 0
  property parts = 0

  property uname = ""
  property privi = 0

  property title : String? = nil
  property chvol : String? = nil
  property uslug : String? = nil

  def self.from_tsv(list : Array(String))
    new(list[0].to_i, list[1]).tap do |x|
      break if list.size < 4

      x.title_zh = list[2]
      x.chvol_zh = list[3]

      break if list.size < 7

      x.utime = list[4].to_i64
      x.chars = list[5].to_i
      x.parts = list[6].to_i

      break if list.size < 9

      x.uname = list[7]
      x.privi = list[8].to_i
    end
  end

  def initialize(@chidx, @schid = @chidx.to_s)
  end

  def to_tsv(io : IO)
    io << @chidx << '\t' << @schid

    return if @title_zh.empty?
    io << '\t' << @title_zh << '\t' << @chvol_zh

    return if @utime == 0
    io << '\t' << @utime << '\t' << @chars << '\t' << @parts

    return if @uname.empty?
    io << '\t' << @uname << '\t' << @privi
  end

  def trans!(cvmtl : MtCore)
    @title = cvmtl.cv_title(@title_zh).to_s
    @chvol = @chvol.empty? ? "Chính văn" : cvmtl.cv_title(@chvol_zh).to_s
    @uslug = TextUtils.tokenize(@title).first(10).join("-")

    self
  end
end
