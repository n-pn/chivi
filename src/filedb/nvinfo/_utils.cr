require "../stores/*"
require "../../shared/core_utils"
require "../../shared/text_utils"
require "../../engine/convert"

module CV::Nvinfo::Utils
  extend self

  DIR = "_db/nvdata/nvinfos"
  ::FileUtils.mkdir_p("#{DIR}/tokens")
  ::FileUtils.mkdir_p("#{DIR}/intros")

  def map_file(name : String)
    "#{DIR}/#{name}.tsv"
  end

  def intro_file(slug : String, type : String = "vi")
    "#{DIR}/intros/#{slug}-#{type}.txt"
  end

  def value_map(name : String, mode : Int32 = 1)
    ValueMap.new(map_file(name), mode: mode)
  end

  def token_map(name : String, mode : Int32 = 1)
    TokenMap.new(map_file(name), mode: mode)
  end

  def order_map(name : String, mode : Int32 = 1)
    OrderMap.new(map_file(name), mode: mode)
  end

  def to_hanviet(input : String, caps : Bool = true)
    output = Convert.hanviet.translit(input, false).to_text
    caps ? TextUtils.titleize(output) : output
  end

  def cleanup_name(name : String)
    name.sub(/[（\(].+[\)）]$/, "").strip
  end

  def fix_map(name : String)
    ValueMap.new("src/filedb/_fixes/#{name}.tsv", mode: 2)
  end

  class_getter zh_authors : ValueMap { fix_map("zh_authors") }
  class_getter vi_authors : ValueMap { fix_map("vi_authors") }

  def fix_zh_author(author : String, btitle : String = "") : String
    # cleanup trashes
    author = cleanup_name(author).sub(/\.QD\s*$/, "")
    zh_authors.fval("#{btitle}  #{author}") || zh_authors.fval(author) || author
  end

  def fix_vi_author(zh_author : String) : String
    vi_authors.fval(zh_author) || to_hanviet(zh_author)
  end

  class_getter zh_btitles : ValueMap { fix_map("zh_btitles") }
  class_getter vi_btitles : ValueMap { fix_map("vi_btitles") }

  def fix_zh_btitle(btitle : String, author : String = "")
    btitle = cleanup_name(btitle)
    zh_btitles.fval("#{btitle}  #{author}") || zh_btitles.fval(btitle) || btitle
  end

  def fix_vi_btitle(zh_title : String)
    vi_btitles.fval(zh_title).try { |x| TextUtils.titleize(x) }
  end

  class_getter zh_bgenres : ValueMap { fix_map("zh_bgenres") }
  class_getter vi_bgenres : ValueMap { fix_map("vi_bgenres") }

  def fix_zh_genre(zh_genre : String) : Array(String)
    zh_bgenres.get(zh_genre) || [] of String
  end

  def fix_vi_genre(zh_genre : String) : String
    vi_bgenres.fval(zh_genre) || to_hanviet(zh_genre)
  end

  # fix novel name
  def fix_nvname(btitle : String, author : String)
    {fix_zh_btitle(btitle), fix_zh_author(author)}
  end
end
