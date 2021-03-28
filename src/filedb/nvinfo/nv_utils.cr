require "../../libcv/cvmtl"
require "../../tabkv/value_map"
require "../../utils/text_utils"

module CV::NvUtils
  extend self

  def to_hanviet(input : String, caps : Bool = true)
    return input if input =~ /^[\w\s_.]+$/

    output = Cvmtl.hanviet.translit(input, false).to_s
    caps ? TextUtils.titleize(output) : output
  end

  def cleanup_name(name : String)
    name.sub(/[（\(].+[\)）]$/, "").strip
  end

  def fix_map(name : String)
    ValueMap.new("src/filedb/_fixes/#{name}.tsv", mode: 2)
  end

  class_getter authors_zh : ValueMap { fix_map("authors_zh") }
  class_getter authors_vi : ValueMap { fix_map("authors_vi") }
  class_getter btitles_zh : ValueMap { fix_map("btitles_zh") }
  class_getter btitles_vi : ValueMap { fix_map("btitles_vi") }
  class_getter bgenres_zh : ValueMap { fix_map("bgenres_zh") }
  class_getter bgenres_vi : ValueMap { fix_map("bgenres_vi") }

  def fix_labels(btitle : String, author : String)
    {fix_btitle_zh(btitle, author), fix_author_zh(author, btitle)}
  end

  def fix_btitle_zh(btitle : String, author : String = "")
    btitle = cleanup_name(btitle)
    btitles_zh.fval("#{btitle}  #{author}") || btitles_zh.fval(btitle) || btitle
  end

  def fix_btitle_vi(btitle_zh : String)
    return to_hanviet(btitle_zh) unless btitle_vi = btitles_vi.fval(btitle_zh)
    TextUtils.titleize(btitle_vi)
  end

  def fix_author_zh(author : String, btitle : String = "") : String
    # cleanup trashes
    author = cleanup_name(author).sub(/\.QD\s*$/, "")
    authors_zh.fval("#{btitle}  #{author}") || authors_zh.fval(author) || author
  end

  def fix_author_vi(author_zh : String) : String
    authors_vi.fval(author_zh) || to_hanviet(author_zh)
  end

  def fix_genre_zh(zh_genre : String) : Array(String)
    bgenres_zh.get(zh_genre) || [] of String
  end

  def fix_genre_vi(zh_genre : String) : String
    bgenres_vi.fval(zh_genre) || to_hanviet(zh_genre)
  end
end
