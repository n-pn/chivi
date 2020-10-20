require "../../engine"
require "../../_utils/text_util"
require "../filedb/*"

module BookDB::Utils
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
    title = TextUtil.fix_spaces(title).sub(/[（\(].+[\)）]\s*$/, "").strip

    fix_map = LabelMap.zh_title
    fix_map.fetch("#{title}--#{author}") || fix_map.fetch(title) || title
  end

  def fix_zh_author(author : String, title : String = "")
    author = TextUtil.fix_spaces(author).sub(/[（\(].+[\)）]|\.QD\s*$/, "").strip

    fix_map = LabelMap.zh_author
    fix_map.fetch("#{title}--#{author}") || fix_map.fetch(author) || author
  end

  def fix_zh_genres(zh_genres : Hash(String, String))
    counter = Hash(String, Int32).new { |h, k| h[k] = 0 }
    initial = [] of String

    zh_genres.each do |site, genre|
      next if genre.empty?

      genres = split_zh_genre(genre)
      genres.each { |x| counter[x] += 1 }

      initial = genres if initial.empty? || site == "yousuu"
    end

    selects = counter.to_a.select(&.[1].> 1)
    return initial if selects.empty?

    selects.sort_by(&.[1].-).map(&.[0])
  end

  def split_zh_genre(genre : String)
    genre = genre.sub(/小说$/, "") unless genre == "轻小说"

    if genres = LabelMap.zh_genre.fetch(genre)
      genres.split("¦")
    else
      if !genre.blank? || genre.includes?("其他")
        ValueSet.skip_genres.upsert!(genre)
      end

      [] of String
    end
  end

  def fake_rating(zh_author : String)
    voters_max = OrderMap.author_voters.value(zh_author) || 100_i64
    voters_min = voters_max // 2
    voters = Random.rand(voters_min..voters_max).to_i32

    scored_max = OrderMap.author_rating.value(zh_author) || 60_i64
    scored_min = scored_max &* 2 // 3

    scored = Random.rand(scored_min..scored_max)
    rating = (scored / 10).to_f32

    {voters, rating, scored * voters}
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
