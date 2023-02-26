require "./m1_core"
require "../../mt_sp/sp_core"
require "../../_util/text_util"

module M1::TlUtil
  extend self

  def load_tsv_hash(path : String)
    hash = {} of String => String

    File.each_line(path) do |line|
      rows = line.split('\t')
      key = rows[0]
      if val = rows[1]?
        hash[key] = val
      else
        hash.delete(key)
      end
    end

    hash
  end

  class_getter wn_btitles : Hash(String, String) do
    load_tsv_hash("var/books/fixes/btitles_zh.tsv")
  end

  class_getter wn_authors : Hash(String, String) do
    load_tsv_hash("var/books/fixes/authors_zh.tsv")
  end

  def tl_author(author : String) : String
    self.wn_authors.fetch(author) { to_hanviet(author, w_cap: true) }
  end

  def tl_btitle(btitle : String, wn_id : Int32 = 0)
    output = self.wn_btitles.fetch(btitle) { cv_btitle(btitle, wn_id) }
    TextUtil.titleize(output)
  end

  BTITLE_PREFIX = {
    "华娱之"   => "C-biz: ",
    "韩娱之"   => "K-biz: ",
    "火影之"   => "NARUTO: ",
    "民国之"   => "Dân quốc: ",
    "三国之"   => "Tam Quốc: ",
    "综漫之"   => "Tổng mạn: ",
    "娱乐之"   => "Giải trí: ",
    "重生之"   => "Trùng sinh: ",
    "穿越之"   => "Xuyên qua: ",
    "复活之"   => "Phục sinh: ",
    "网游之"   => "Game online: ",
    "异界之"   => "Thế giới khác: ",
    "哈利波特之" => "Harry Potter: ",
    "网游三国之" => "Tam Quốc game online: ",
  }

  BTITLE_RE = /^(#{BTITLE_PREFIX.keys.join('|')})(.+)/

  def cv_btitle(input : String, wn_id : Int32 = 0)
    if input =~ BTITLE_RE
      prefix = BTITLE_PREFIX[$1]
      input = $2
    end

    vname = MtCore.init(wn_id).translate(input)
    prefix ? prefix + vname : vname
  end

  def to_hanviet(input : String, w_cap : Bool = true)
    return input unless input.matches?(/\p{Han}/)

    output = SP::MtCore.tl_sinovi(input, false)
    w_cap ? TextUtil.titleize(output) : output
  end
end
