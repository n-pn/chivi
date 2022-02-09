require "json"
require "../../_util/text_utils"

class CV::ChInfo
  include JSON::Serializable

  property chidx : Int32
  property schid : String

  @[JSON::Field(ignore: true)]
  property z_title = ""
  @[JSON::Field(ignore: true)]
  property z_chvol = ""

  property utime = 0_i64 # chapter modified at
  property chars = 0     # char count
  property parts = 0     # chapter splitted parts
  property uname = ""    # user name

  property title = "Thiếu chương"
  property chvol = "Chính văn"
  property uslug = "thieu-chuong"

  property o_sname = ""
  property o_snvid = ""
  property o_chidx = 0

  def initialize(argv : Array(String))
    @chidx = argv[0].to_i
    @schid = argv[1]

    return if argv.size < 4
    @z_title = argv[2]
    @z_chvol = argv[3]

    return if argv.size < 7
    @utime = argv[4].to_i64
    @chars = argv[5].to_i
    @parts = argv[6].to_i
    @uname = argv[7]? || ""

    return if argv.size < 11
    @o_sname = argv[8]
    @o_snvid = argv[9]
    @o_chidx = argv[10].to_i
  end

  def initialize(@chidx, @schid = chidx.to_s)
  end

  def initialize(@chidx, @schid, title : String, chvol = "")
    @z_title, @z_chvol = TextUtils.format_title(title, chvol)
    @z_chvol = @z_chvol.sub(/\s{2,}/, " ")
  end

  # delegate empty?, to: @z_title

  def invalid?
    @z_title.empty?
  end

  def get(chidx : Int32)
    @data[chidx]? || ChInfo.new(chidx)
  end

  def trans!(cvmtl : MtCore) : Nil
    return if self.invalid?
    @title = cvmtl.cv_title(@z_title).to_s
    @chvol = @z_chvol.empty? ? "Chính văn" : cvmtl.cv_title(@z_chvol).to_s
    @uslug = TextUtils.tokenize(@title).first(10).join("-")
  end

  def equal?(other : self)
    @schid == other.schid && @z_title == other.z_title && @z_chvol == other.z_chvol
  end

  def pgidx : Int32
    (self.chidx - 1) // 128
  end

  def chap_url(part = 0)
    String.build do |io|
      io << @uslug << '-' << @chidx
      if part != 0 && @parts > 1
        io << '.' << part % @parts
      end
    end
  end

  # for sname == "users" only, avoid overwrite previous uploaded entry by increase
  # last digit of schid by one
  # schid initialized by multiple chidx by 10
  def bump_version!
    version = @schid.to_i % 10
    version = version < 10 ? version + 1 : 0
    @schid = (chidx * 10 + version).to_s
  end

  def to_s
    String.build { |io| to_s(io) }
  end

  def to_s(io : IO)
    io << @chidx << '\t' << @schid

    return if @z_title.empty?
    io << '\t' << @z_title << '\t' << @z_chvol

    return if @utime == 0 && @o_sname.empty?
    io << '\t' << @utime << '\t' << @chars << '\t' << @parts

    return if @uname.empty? && @o_sname.empty?
    io << '\t' << @uname

    return if @o_sname.empty?
    io << '\t' << @o_sname << '\t' << @o_snvid << '\t' << @o_chidx
  end

  def make_copy!(sname : String, snvid : String, chidx = self.chidx) : self
    copy = self.dup

    copy.o_sname = sname
    copy.o_snvid = snvid
    copy.o_chidx = chidx

    copy
  end
end
