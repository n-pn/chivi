require "./m1_core"
require "../../mtapp/sp_core"
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
    load_tsv_hash("var/_conf/fixes/btitles_vi.tsv")
  end

  class_getter wn_authors : Hash(String, String) do
    load_tsv_hash("var/_conf/fixes/authors_vi.tsv")
  end

  def tl_author(author : String) : String
    self.wn_authors.fetch(author) { MT::SpCore.tl_hvname(author) }
  end

  BTITLE_PREFIX = {
    "华娱之"   => "C-biz: ",
    "韩娱之"   => "K-biz: ",
    "火影之"   => "NARUTO: ",
    "民国之"   => "Dân qQốc: ",
    "三国之"   => "Tam Quốc: ",
    "综漫之"   => "Tổng Mạn: ",
    "娱乐之"   => "Giải Trí: ",
    "重生之"   => "Trùng Sinh: ",
    "穿越之"   => "Xuyên Qua: ",
    "复活之"   => "Phục Sinh: ",
    "网游之"   => "Game Online: ",
    "异界之"   => "Thế Giới Khác: ",
    "哈利波特之" => "Harry Potter: ",
    "网游三国之" => "Tam Quốc OL: ",
  }

  BTITLE_RE = /^(#{BTITLE_PREFIX.keys.join('|')})(.+)/

  def tl_btitle(ztitle : String, wn_id : Int32 = 0)
    btitle = self.wn_btitles.fetch(ztitle) do
      engine = MtCore.init(wn_id)

      if match = ztitle.match(BTITLE_RE)
        _, prefix, ztitle = match
      end

      vtitle = engine.translate(ztitle)
      prefix ? "#{BTITLE_PREFIX[prefix]}#{vtitle}" : vtitle
    end

    TextUtil.titleize(btitle)
  end
end
