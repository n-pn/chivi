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

  def fix_file(name : String)
    "src/kernel/_fixes/#{name}.tsv"
  end

  def to_hanviet(input : String, caps : Bool = true)
    output = Convert.hanviet.translit(input, false).to_text
    caps ? TextUtils.titleize(output) : output
  end

  def cleanup_name(name : String)
    name.sub(/[（\(].+[\)）]$/, "").strip
  end

  class_getter zh_authors : ValueMap { ValueMap.new(fix_file("zh_authors")) }
  class_getter vi_authors : ValueMap { ValueMap.new(fix_file("vi_authors")) }

  def fix_zh_author(author : String, btitle : String = "") : String
    # cleanup trashes
    author = cleanup_name(author).sub(/\.QD\s*$/, "")
    zh_authors.fval("#{btitle}  #{author}") || zh_authors.fval(author) || author
  end

  def fix_vi_author(zh_author : String) : String
    vi_authors.fval(zh_author) || to_hanviet(zh_author)
  end

  class_getter zh_btitles : ValueMap { ValueMap.new(fix_file("zh_btitles")) }
  class_getter vi_btitles : ValueMap { ValueMap.new(fix_file("vi_btitles")) }

  def fix_zh_btitle(btitle : String, author : String = "")
    btitle = cleanup_name(btitle)
    zh_btitles.fval("#{btitle}  #{author}") || zh_btitles.fval(btitle) || btitle
  end

  def fix_vi_btitle(zh_title : String)
    vi_btitles.fval(zh_title).try { |x| TextUtils.titleize(x) }
  end

  class_getter zh_bgenres : ValueMap { ValueMap.new(fix_file("zh_bgenres")) }
  class_getter vi_bgenres : ValueMap { ValueMap.new(fix_file("vi_bgenres")) }

  def fix_zh_genre(zh_genre : String) : Array(String)
    zh_genre = zh_genre.sub(/小说$/, "") unless zh_genre == "轻小说"
    zh_bgenres.get(zh_genre) || [] of String
  end

  def fix_vi_genre(zh_genre : String) : String
    vi_bgenres.fval(zh_genre) || to_hanviet(zh_genre)
  end

  def fix_name(btitle : String, author : String)
    btitle = fix_zh_btitle
    author = fix_zh_author

    {btitle, author, CoreUtils.digest("#{btitle}--#{author}")}
  end
end
