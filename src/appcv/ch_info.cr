require "crorm"
require "../_util/text_util"
require "../zhlib/models/v1_text"

# require "./_base"
require "./ch_seed"
require "./ch_text"

# require "./nv_info"

# class CV::ChTran2
#   include Crorm::Model

#   field ch_no : Int32, primary: true
#   field title : String = ""
#   field chvol : String = ""
#   field uslug : String = ""
#   field fixed : Bool = false

#   def convert!(cvmtl, title : String, chvol : String = "")
#     self.title = title.empty? "Thiếu tựa": cvmtl.cv_title(title).to_txt
#     self.chvol = chvol.empty? "Chính văn": cvmtl.cv_title(chvol).to_txt
#   end
# end

class CV::Chinfo
  include Crorm::Model
  @@table = "chinfos"

  field ch_no : Int32, primary: true # chap number

  field title : String = ""
  field chvol : String = ""

  field p_len : Int32 = 0 # part count
  field c_len : Int32 = 0 # char count

  field utime : Int64 = 0
  field uname : String = ""

  field sn_id : Int32 = 0 # index of seed name
  field s_bid : Int32 = 0 # book original id
  field s_cid : Int32 = 0 # chap original id

  def initialize(sn_id : Int32, s_bid : Int32, cols : Array(String))
    self.sn_id = sn_id
    self.s_bid = s_bid

    ch_no = cols[0].to_i
    self.ch_no = ch_no
    self.s_cid = cols[1].to_i? || ch_no

    self.title = cols[2]
    self.chvol = cols[3]

    return if cols.size < 7

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

  @[JSON::Field(ignore: true)]
  getter trans : Trans { trans!(MtCore.generic_mtl("combine")) }

  def trans!(cmvtl : MtCore) : Trans
    @trans = Trans.new(cmvtl, self.title, self.chvol)
  end

  def sname
    ChSeed.get_sname(self.sn_id)
  end

  @[JSON::Field(ignore: true)]
  getter chtext : ChText { ChText.load(self.sname, self.s_bid, self.ch_no!) }

  def text(cpart : Int16 = 0, mode : Int8 = 0, uname = "") : String
    return self.body_parts(mode, uname)[cpart]? || "" if self.utime == 0

    if cached = self.chtext.read(self.s_cid, cpart)
      text, utime = cached
      self.heal_stats(cpart &+ 1, utime) if self.utime < utime
    elsif mode < 1
      return ""
    end

    return text if mode < 2 && text
    pull_text(mode, uname).try(&.[cpart]?) || text || ""
  end

  def body_parts(mode : Int8 = 0, uname = "") : Array(String)
    if cached = self.chtext.read_all(self.s_cid, self.p_len)
      parts, utime, c_len = cached
      self.heal_stats(parts.size, utime, c_len)
    elsif mode < 1
      return [] of String
    end

    return parts if mode < 2 && parts
    pull_text(mode, uname) || parts || [] of String
  end

  def full_body : String
    String.build do |io|
      body_parts.each_with_index do |part, i|
        io << (i == 0 ? part : part.split('\n', 2).last)
      end
    end
  end

  def save_body(body : String, uname = "")
    self.c_len, body_parts = ZH::V1Text.split(body)
    self.p_len = body_parts.size
    self.utime = Time.utc.to_unix
    self.uname = uname

    self.chtext.save(self.s_cid, body_parts)
  end

  def save_text(content : Array(String), uname = "")
    self.chtext.save(self.s_cid, content)

    self.c_len = content.sum(&.size)
    self.p_len = content.size

    self.utime = Time.utc.to_unix
    self.uname = uname
  end

  def pull_text(mode : Int8 = 1, uname = "")
    flags = mode > 1 ? "-f" : ""
    lines = `bin/text_fetch #{sname} #{s_bid} #{s_cid} #{flags}`.lines

    self.c_len, output = ChUtil.split_parts(lines)
    self.chtext.save(self.s_cid, output)

    self.p_len = output.size
    self.utime = Time.utc.to_unix
    self.uname = uname

    output
  rescue err
    Log.error(exception: err) { [self.sname, self.s_bid, self.s_cid, self.ch_no] }
  end

  def heal_stats(p_len : Int32, utime : Int64, c_len = 0)
    self.p_len = p_len if p_len > self.p_len
    self.c_len = c_len if c_len > self.c_len
    self.utime = utime if utime > self.utime
  end

  def change_root!(chroot : Chroot, s_cid = self.ch_no!) : Nil
    self.s_cid = s_cid
    self.sn_id = chroot._repo.sn_id
    self.s_bid = chroot.s_bid
    @chtext = nil
  end

  ####

  struct Trans
    getter title : String
    getter chvol : String
    getter uslug : String

    def initialize(cvmtl, title : String, chvol : String = "")
      @title = title.empty? ? "Thiếu tựa" : cvmtl.cv_title(title).to_txt
      @chvol = chvol.empty? ? "Chính văn" : cvmtl.cv_title(chvol).to_txt
      @uslug = TextUtil.tokenize(@title)[0..7].join('-')
    end
  end
end
