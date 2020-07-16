require "json"
require "colorize"

require "../engine"
require "../lookup/*"

require "../common/text_util"
require "../bookdb/book_info"

module BookManage
  extend self

  delegate get, to: BookInfo
  delegate get!, to: BookInfo

  def find(slug : String)
    return unless ubid = LabelMap.mapping.fetch(slug)
    BookInfo.get(ubid)
  end

  def upsert!(source : YsSerial, force = false, flush = true)
    info = find_or_create(source.title, source.author)
    rebuild_identity!(info, force)
    set_intro(info, source.intro, force: force)

    info.shield = 2 if input.shielded

    info.voters = input.scorerCount
    info.rating = (input.score * 10).round / 10
    info.fix_weight

    info.save! if info.changed? && flush
  end

  def upsert!(source : SeedInfo, force = false, flush = true)
    info = find_or_create(source.title, source.author)
    rebuild_identity!(info, force)
    set_intro(info, source.intro, force: force)

    info.save! if info.changed? && flush
  end

  def find_or_create(title : String, author : String)
    title = fix_title
    author = fix_author

    raise "book title on blacklist" if blacklist?(title)
    info = BookUtil.preload_or_create!(title, author)

    update_token(TokenMap.zh_title, info.ubid, title)
    update_token(TokenMap.zh_author, info.ubid, author)

    info
  end

  def fix_title(title : String)
    title = TextUtil.fix_spaces(title).sug(/\(.+\)\s*$/, "").strip
    LabelMap.zh_title.fetch(title) || title
  end

  def fix_author(author : String, title : String = "")
    author = TextUtil.fix_spaces(author).sug(/\(.+\)|\.QD\s*$/, "").strip
    return author unless matcher = LabelMap.zh_author.fetch(author)

    items = matcher.split("¦")
    match_author = items[0]

    return match_author unless match_tile = items[1]?
    match_title == title ? match_author : author
  end

  def blacklist?(title : String)
    # TODO: check by both author and book title
    ValueSet.skip_titles.includes?(title)
  end

  def rebuild_identity!(info : BookInfo, force = false)
    set_hv_title(info, force: force)
    set_vi_title(info, force: force)
    set_vi_author(info, force: force)

    map_slug(info, force: force)
    set_slug(info, TextUtil.slugify(info.hv_title)) if force
  end

  def set_hv_title(info : BookInfo, hv_title = "", force = false)
    return unless force || info.hv_title.empty?
    hv_title = to_hanviet(info.zh_title) if hv_title.empty?

    update_token(TokenMap.hv_title, info.ubid, hv_title)
    info.hv_title = hv_title
  end

  def set_vi_title(info : BookInfo, vi_title = "", force = false)
    return unless force || info.vi_title.empty?

    if vi_title.empty?
      vi_title = LabelMap.fetch(info.vi_title) || info.hv_title
      vi_title = to_hanviet(info.zh_title) if vi_title.empty?
      vi_title = TextUtil.titleize(vi_title)
    end

    update_token(TokenMap.vi_title, info.ubid, vi_title)
    info.vi_title = vi_title
  end

  def set_vi_author(info : BookInfo, vi_author = "", force = false)
    return unless force || info.vi_author.empty?

    if vi_author.empty?
      unless vi_author = LabelMap.fetch(info.vi_author)
        vi_author = TextUtil.titleize(to_hanviet(info.zh_author))
      end
    end

    update_token(TokenMap.vi_author, info.ubid, vi_author)
    info.vi_author = vi_author
  end

  private def to_hanviet(title : String)
    Engine.hanviet(title, apply_cap: true).vi_text
  end

  def map_slug(info : BookInfo, new_slug : String = "", force = false)
    return info.slug unless force || info.slug.empty?

    if !new_slug.empty?
      raise "slug used by other book!" unless set_slug(info, new_slug)
      return new_slug
    end

    raise "vi_title is empty" if info.vi_title.empty?
    raise "vi_author is empty" if info.vi_author.empty?

    title_slug = TextUtil.slugify(info.vi_title)
    return title_slug if set_slug(title_slug, info.sbid)

    author_slug = TextUtil.slugify(info.vi_author)
    full_slug = "#{title_slug}--#{author_slug}"
    return full_slug if set_slug(full_slug, info.sbid)

    raise "can not find an unique slug for this book"
  end

  def set_slug(info : BookInfo, slug : String) : String?
    unless old_ubid = LabelMap.mapping.fetch(slug)
      LabelMap.upsert(slug, info.ubid)
      info.slug = slug
    else
      slug if old_ubid == info.ubid
    end
  end

  def set_intro(info : BookInfo, zh_intro = "", force = false)
    return unless force || info.zh_intro.empty?
    info.vi_intro = cv_intro(zh_intro, info.ubid)
    info.zh_intro = zh_intro
  end

  def set_vi_intro(info : BookInfo, vi_intro = "", force = false)
    return unless force || info.vi_intro.empty?
    vi_intro = cv_intro if vi_intro.empty?
    info.vi_intro = vi_intro
  end

  private def cv_intro(input : String, ubid : String)
    cv_lines = Engine.cv_plain(input.split("\n"), ubid)
    vi_intro = cv_lines.map(&.vi_text).join("\n")
  end

  def set_voters(info : BookInfo, voters : Int32, force = false)
    return unless force || info.voters < voters
    info.voters = voters
  end

  def set_rating(info : BookInfo, rating : Int32, force = false)
    return unless force || info.rating < rating
    info.rating = rating
  end

  def fix_weight(info : BookInfo, weight = -1, force = true)
  end

  def fix_genre(genre : String)
    genre = genre.sub(/小说$/, "") unless genre == "轻小说"
    if genres = LabelMap.genre_zh.fetch(genre)
      return genres.split("¦")
    end

    ValueSet.skip_genres.upsert!(genre) if genre != "其他"
    [] of String
  end

  private def update_token(token_map : TokenMap, key : String, vals : String)
    token_map.upsert!(key, TextUtil.tokenize(vals))
  end

  private def update_order(order_map : TokenMap, key : String, value : Int64)
    order_map.upsert!(key, value)
  end
end
