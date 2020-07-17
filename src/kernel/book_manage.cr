require "json"
require "colorize"

require "../engine"
require "../lookup/*"

require "../parser/ys_serial"
require "../parser/seed_info"

require "../common/text_util"
require "../bookdb/book_info"

module BookManage
  extend self

  delegate get, to: BookInfo
  delegate get!, to: BookInfo

  def find(slug : String)
    return unless ubid = LabelMap.map_slug.fetch(slug)
    BookInfo.get(ubid)
  end

  def upsert!(source : YsSerial, force = false, flush = true)
    info = find_or_create(source.title, source.author)

    rebuild_identity!(info, force: force)

    set_intro(info, source.intro, force: force)
    set_genre(info, "yousuu", source.genre, force: force)
    set_tags(info, "yousuu", source.fixed_tags, force: force)
    set_cover(info, "yousuu", source.fixed_cover, force: force)

    set_shield(info, 2, force: force) if source.shielded
    set_status(info, source.status, force: force)
    set_mftime(info, source.mftime, force: force)

    set_voters(info, source.voters, force: force)
    set_rating(info, source.rating, force: force)
    set_weight(info, source.weight, force: force)

    info.yousuu_bid = source.ysid
    info.origin_url = source.origin_url
    info.word_count = source.word_count
    info.crit_count = source.crit_count

    info.save! if info.changed? && flush
    info
  end

  def upsert!(source : SeedInfo, force = false, flush = true)
    info = find_or_create(source.title, source.author)
    rebuild_identity!(info, force)
    set_intro(info, source.intro, force: force)

    info.save! if info.changed? && flush
    info
  end

  # def ubid_for(title : String, author : String)

  # end

  def find_or_create(title : String, author : String)
    # title = fix_title(title)
    # author = fix_author(author, title)

    raise "book title on blacklist" if blacklist?(title)
    info = BookInfo.preload_or_create!(title, author)

    update_token(TokenMap.zh_title, info.ubid, title)
    update_token(TokenMap.zh_author, info.ubid, author)

    info
  end

  def fix_title(title : String)
    title = TextUtil.fix_spaces(title).sub(/\(.+\)\s*$/, "").strip
    LabelMap.zh_title.fetch(title) || title
  end

  def fix_author(author : String, title : String = "")
    author = TextUtil.fix_spaces(author).sub(/\(.+\)|\.QD\s*$/, "").strip
    return author unless matcher = LabelMap.zh_author.fetch(author)

    items = matcher.split("¦")
    match_author = items[0]

    return match_author unless match_title = items[1]?
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
      vi_title = LabelMap.vi_title.fetch(info.zh_title) || info.hv_title
      vi_title = to_hanviet(info.zh_title) if vi_title.empty?
      vi_title = TextUtil.titleize(vi_title)
    end

    update_token(TokenMap.vi_title, info.ubid, vi_title)
    info.vi_title = vi_title
  end

  def set_vi_author(info : BookInfo, vi_author = "", force = false)
    return unless force || info.vi_author.empty?

    if vi_author.empty?
      unless vi_author = LabelMap.vi_author.fetch(info.zh_author)
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
    return title_slug if set_slug(info, title_slug)

    author_slug = TextUtil.slugify(info.vi_author)
    full_slug = "#{title_slug}--#{author_slug}"
    return full_slug if set_slug(info, full_slug)

    raise "can not find an unique slug for this book"
  end

  def set_slug(info : BookInfo, slug : String) : String?
    unless old_ubid = LabelMap.map_slug.fetch(slug)
      LabelMap.map_slug.upsert!(slug, info.ubid)
      info.slug = slug
    else
      slug if old_ubid == info.ubid
    end
  end

  def set_intro(info : BookInfo, zh_intro : String, force = false)
    return unless force || info.zh_intro.empty?
    # assuming zh_intro is uncleaned
    lines = TextUtil.split_html(zh_intro)
    info.zh_intro = lines.join("\n")
    info.vi_intro = cv_intro(lines, info.ubid)
  end

  # currently unused
  def set_vi_intro(info : BookInfo, vi_intro = "", force = false)
    return unless force || info.vi_intro.empty?
    # assuming zh_intro is cleaned
    vi_intro = cv_intro(info.zh_intro.split("\n")) if vi_intro.empty?
    info.vi_intro = vi_intro
  end

  private def cv_intro(lines : Array(String), dname : String)
    Engine.cv_plain(lines, dname).map(&.vi_text).join("\n")
  end

  def set_genre(info : BookInfo, site : String, genre : String, force = false)
    return unless force || !info.zh_genres.includes?(site)
    info.add_zh_genre(site, genre)

    zh_genres = count_genres(info.zh_genres.values, min_count: 2)

    if zh_genres.empty?
      info.vi_genres = ["Loại khác"]
    else
      info.vi_genres = zh_genres.map do |(genre, _)|
        LabelMap.vi_genre.fetch(genre).not_nil!
      end
    end

    update_token(TokenMap.vi_genres, info.ubid, info.vi_genres)
  end

  def count_genres(zh_genres : Array(String), min_count = 1)
    counter = Hash(String, Int32).new { |h, k| h[k] = 0 }

    zh_genres.each do |genre|
      split_genres(genre).each { |x| counter[x] += 1 }
    end

    counted = counter.to_a

    if min_count > 1
      selects = counted.select { |_, c| c >= min_count }
      counted = selects unless selects.empty?
    end

    counted.sort_by { |(_, c)| -c }
  end

  def split_genres(genre : String)
    genre = genre.sub(/小说$/, "") unless genre == "轻小说"

    if genres = LabelMap.zh_genre.fetch(genre)
      genres.split("¦")
    else
      ValueSet.skip_genres.upsert!(genre) if genre != "其他"
      [] of String
    end
  end

  def set_tags(info : BookInfo, site : String, tags : Array(String), force = false)
    return unless force || !info.zh_tags.includes?(site)
    info.add_zh_tags(site, tags.join("¦"))
    tags.each { |tag_zh| info.add_vi_tag(to_hanviet(tag_zh)) }
    update_token(TokenMap.vi_tags, info.ubid, info.vi_tags)
  end

  def set_cover(info : BookInfo, site : String, cover : String, force = false)
    return unless force || !info.cover_urls.includes?(site)
    info.add_cover(site, cover)
    # TODO: Fetch covers?
  end

  def set_shield(info : BookInfo, shield = 0, force = false)
    return unless force || info.shield > shield
    info.shield = shield
    # TODO: remove info from order_map indexes if shield > 0 ?
  end

  def set_status(info : BookInfo, status = 0, force = false)
    return unless force || info.status > status
    info.status = status
  end

  def set_mftime(info : BookInfo, mftime = 0_i64, force = false)
    return unless force || info.mftime > mftime
    update_order(OrderMap.update, info.ubid, mftime)
    update_order(OrderMap.access, info.ubid, mftime)
    info.mftime = mftime
  end

  def set_voters(info : BookInfo, voters : Int32, force = false)
    return unless force || info.voters < voters
    info.voters = voters
  end

  def set_rating(info : BookInfo, rating : Float, force = false)
    return unless force || info.rating < rating
    update_order(OrderMap.rating, info.ubid, info.scored)
    info.rating = rating
  end

  def set_weight(info : BookInfo, weight : Int64, force = true)
    weight += info.view_count

    return unless force || info.weight < weight
    update_order(OrderMap.weight, info.ubid, weight)
    info.weight = weight
  end

  private def update_token(map : TokenMap, key : String, vals : String)
    map.upsert!(key, TextUtil.tokenize(vals))
  end

  private def update_token(map : TokenMap, key : String, vals : Array(String))
    map.upsert!(key, vals)
  end

  private def update_order(map : OrderMap, key : String, value : Int64)
    map.upsert!(key, value)
  end
end
