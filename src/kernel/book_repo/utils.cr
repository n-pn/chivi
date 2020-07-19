require "../../engine"
require "../../lookup/*"
require "../../common/text_util"

module BookRepo::Utils
  extend self

  def cv_intro(lines : Array(String), dname : String)
    Engine.cv_plain(lines, dname).map(&.vi_text).join("\n")
  end

  def hanviet(label : String, titleize = true)
    output = Engine.hanviet(label, apply_cap: titleize).vi_text
    output = TextUtil.titleize(output) if titleize
    output
  end

  def fix_zh_title(title : String, author : String = "")
    title = TextUtil.fix_spaces(title).sub(/\(.+\)\s*$/, "").strip

    fix_map = LabelMap.zh_title
    fix_map.fetch("#{title}--#{author}") || fix_map.fetch(title) || title
  end

  def fix_zh_author(author : String, title : String = "")
    author = TextUtil.fix_spaces(author).sub(/\(.+\)|\.QD\s*$/, "").strip

    fix_map = LabelMap.zh_author
    fix_map.fetch("#{title}--#{author}") || fix_map.fetch(author) || author
  end

  def fix_zh_genres(zh_genres : Array(String), min_count = 1)
    counter = Hash(String, Int32).new { |h, k| h[k] = 0 }

    zh_genres.each do |genre|
      split_zh_genre(genre).each { |x| counter[x] += 1 }
    end

    counted = counter.to_a

    if min_count > 1
      selects = counted.select(&.[1].>= min_count)
      counted = selects unless selects.empty?
    end

    counted.sort_by(&.[1].-).map(&.[0])
  end

  def split_zh_genre(genre : String)
    genre = genre.sub(/小说$/, "") unless genre == "轻小说"

    if genres = LabelMap.zh_genre.fetch(genre)
      genres.split("¦")
    else
      ValueSet.skip_genres.upsert!(genre) if genre != "其他"
      [] of String
    end
  end

  def map_vi_genres(zh_genres : Array(String))
    return ["Loại khác"] if zh_genres.empty?
    zh_genres.map { |genre| LabelMap.vi_genre.fetch(genre).not_nil! }
  end

  def update_token(map : TokenMap, key : String, vals : Array(String))
    map.upsert!(key, vals.map { |x| TextUtil.slugify(x) })
  end

  def update_token(map : TokenMap, key : String, vals : String)
    map.upsert!(key, TextUtil.tokenize(vals))
  end

  def update_order(map : OrderMap, key : String, value : Int64)
    map.upsert!(key, value)
  end
end
