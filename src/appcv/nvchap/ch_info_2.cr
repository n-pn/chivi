require "sqlite3"
require "../../outer/crorm"
require "../../_util/text_util"

module CV
  class ChTran2
    include Crorm::Model

    column chidx : Int32

    column title_cv : String = ""
    column chvol_cv : String = ""

    column title_vi : String = ""
    column chvol_vi : String = ""

    column url_slug : String = ""

    def convert!(cvmtl, title : String, chvol : String = "")
      self.title_cv = title.empty? "Thiếu chương": cvmtl.cv_title(title).to_txt
      self.chvol_cv = chvol.empty? "Chính văn": cvmtl.cv_title(chvol).to_txt
    end

    def converted?
      !self.title_cv.empty?
    end
  end

  class ChInfo2
    include Crorm::Model

    column chidx : Int32
    column schid : String

    column title : String = ""
    column chvol : String = ""

    column utime : Int64 = 0
    column uname : String = ""

    # column ctime : Int64 = 0
    # column privi : Int32 = 0

    column w_count : Int32 = 0
    column p_count : Int32 = 0

    column o_sname : String = ""
    column o_snvid : String = ""
    column o_chidx : Int32 = 0

    def initialize(chidx : Int32, schid : String = chidx.to_s)
      self.chidx = chidx
      self.schid = schid
    end

    def initialize(chidx : Int32, schid : String, title : String, chvol : String = "")
      self.chidx = chidx
      self.schid = schid
      set_title!(title, chvol)
    end

    def set_title!(title : String, chvol : String = "")
      self.title, self.chvol = TextUtil.format_title(title, chvol)
    end

    def as_mirror!(sname : String, snvid : String, offset = 0)
      if self.o_sname.empty?
        self.o_sname = sname
        self.o_snvid = snvid
        self.o_chidx = self.chidx
      end

      self.chidx += offset
    end

    def parse_seeds(rows : Array(String))
      self.chidx = rows[0].to_i
      self.schid = rows[1]
      self.title = rows[2]
      self.chvol = rows[3]
    end

    def parse_stats(rows : Array(String))
      self.chidx = rows[0].to_i
      self.schid = rows[1]

      self.utime = rows[2].to_i64
      self.uname = rows[3]

      self.w_count = rows[4].to_i
      self.p_count = rows[4].to_i
    end

    def parse_origs(rows : Array(String))
      self.chidx = rows[0].to_i
      self.schid = rows[1]

      self.o_sname = rows[2]
      self.o_snvid = rows[3]
      self.o_chidx = rows[4].to_i
    end

    def print_seeds(io : IO = STDOUT)
      {
        self.chidx, self.schid,
        self.title, self.chvol,
      }.join(io, '\t')

      io << '\n'
    end

    def print_stats(io : IO = STDOUT)
      {
        self.chidx, self.schid,
        self.utime, self.uname,
        self.w_count, self.p_count,
      }.join(io, '\t')

      io << '\n'
    end

    def print_origs(io : IO = STDOUT)
      {
        self.chidx, self.schid,
        self.o_sname, self.o_snvid, self.o_chidx,
      }.join(io, '\t')

      io << '\n'
    end
  end
end
