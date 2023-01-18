require "crorm"

require "../../_util/text_util"

class WN::ChInfo
  include Crorm::Model

  @@table = "chaps"

  field ch_no : Int32 # chaper index number
  field s_cid : Int32 # chapter fname in disk/remote

  field title : String = "" # chapter title
  field chdiv : String = "" # volume name

  field mtime : Int64 = 0   # last modification time
  field uname : String = "" # last modified by username

  field c_len : Int32 = 0 # chars count
  field p_len : Int32 = 0 # parts count

  field _path : String = "" # file locator
  field _flag : Int32 = 0   # marking states

  def initialize(@ch_no, @s_cid, @title, @chdiv = "")
  end

  def uslug
    tokens = TextUtil.tokenize(self.title)
    tokens.empty? ? "-" : tokens.first(7).join('-')
  end

  def to_json(jb : JSON::Builder)
    # FIXME: rename json fields

    jb.object {
      jb.field "chidx", self.ch_no
      jb.field "schid", self.s_cid

      jb.field "title", self.title
      jb.field "chvol", self.chdiv
      jb.field "uslug", self.uslug

      jb.field "chars", self.c_len
      jb.field "parts", self.p_len

      jb.field "utime", self.mtime
      jb.field "uname", self.uname
      # jb.field "sname", self.sname
    }
  end
end
