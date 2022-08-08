require "../tools/crorm/*"
require "../_util/text_util"
require "./ch_seed"

class CV::ChTran2
  include Crorm::Model

  column ch_no : Int32, primary: true
  column title : String = ""
  column chvol : String = ""
  column uslug : String = ""
  column fixed : Bool = false

  def convert!(cvmtl, title : String, chvol : String = "")
    self.title = title.empty? "Thiếu tựa": cvmtl.cv_title(title).to_txt
    self.chvol = chvol.empty? "Chính văn": cvmtl.cv_title(chvol).to_txt
  end
end

class CV::ChInfo2
  include Crorm::Model

  column ch_no : Int32, primary: true # chap number

  column title : String = ""
  column chvol : String = ""

  column p_len : Int32 = 0 # part count
  column c_len : Int32 = 0 # char count

  column utime : Int64 = 0
  column uname : String = ""

  column sn_id : Int32 # index of seed name
  column s_bid : Int32 # book original id
  column s_cid : Int32 # chap original id

  def initialize(sn_id : Int32, s_bid : Int32, cols : Array(String))
    self.sn_id = sn_id
    self.s_bid = s_bid

    self.ch_no = cols[0].to_i
    self.s_cid = cols[1].to_i

    self.title = cols[2]
    self.chvol = cols[3]

    return if cols.size < 8

    self.utime = cols[4].to_i64
    self.c_len = cols[5].to_i
    self.p_len = cols[6].to_i
    self.uname = cols[7]? || ""

    return if cols.size < 10

    self.sn_id, _ = ChSeed.map_sname(cols[8])
    self.s_bid = cols[9].to_i
  end

  def initialize(sn_id : Int32, s_bid : Int32, ch_no : Int32, s_cid : Int32 = ch_no)
    self.sn_id = sn_id
    self.s_bid = s_bid

    self.ch_no = ch_no
    self.s_cid = s_cid
  end

  def set_title!(title : String, chvol : String = "")
    self.title, self.chvol = TextUtil.format_title(title, chvol)
  end

  getter trans : Trans { trans!(MtCore.generic_mtl("combine")) }

  def trans!(cvmtl : MtCore) : Trans
    @trans = Trans.new(cmvtl, self.title, self.chvol)
  end

  ####

  struct Trans
    getter title : String
    getter chvol : String
    getter uslug : String

    def initialize(cvmtl, title : String, chvol : String = "")
      @title = title.empty? "Thiếu tựa": cvmtl.cv_title(title).to_txt
      @chvol = chvol.empty? "Chính văn": cvmtl.cv_title(chvol).to_txt
      @uslug = TextUtil.tokenize(title)[0..7].join('-')
    end
  end
end
