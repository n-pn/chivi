require "../tools/crorm/*"
require "../_util/text_util"
require "../appcv/shared/sname_map"

module CV
  class ChTran2
    include Crorm::Model

    column ch_no : Int16, primary: true
    column title : String = ""
    column chvol : String = ""
    column uslug : String = ""
    column fixed : Bool = false

    def convert!(cvmtl, title : String, chvol : String = "")
      self.title = title.empty? "Thiếu tựa": cvmtl.cv_title(title).to_txt
      self.chvol = chvol.empty? "Chính văn": cvmtl.cv_title(chvol).to_txt
    end

    def translated?
      !title.empty?
    end
  end

  class ChInfo2
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

    def initialize(sn_id : Int32, s_bid : Int32, ch_no : Int32, s_cid : Int32 = ch_no)
      self.sn_id = sn_id
      self.s_bid = s_bid

      self.ch_no = ch_no
      self.s_cid = s_cid
    end

    def initialize(sn_id : Int32, s_bid : Int32, rows : Array(String))
      self.sn_id = sn_id
      self.s_bid = s_bid

      self.ch_no = rows[0].to_i
      self.s_cid = rows[1].to_i

      self.title = rows[2]
      self.chvol = rows[3]

      if rows.size > 7
        self.utime = rows[4].to_i64

        self.c_len = rows[5].to_i
        self.p_len = rows[6].to_i

        self.uname = rows[7]? || ""
      end

      if rows.size > 9
        self.sn_id = SnameMap.sn_id(rows[8])
        self.s_bid = rows[9].to_i
      end
    end

    def set_title!(title : String, chvol : String = "")
      self.title, self.chvol = TextUtil.format_title(title, chvol)
    end
  end
end
