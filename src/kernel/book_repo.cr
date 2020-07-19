require "json"
require "colorize"

require "../parser/ys_serial"
require "../parser/seed_info"

require "./book_repo/*"

module BookRepo
  extend self

  delegate get, to: BookInfo
  delegate get!, to: BookInfo

  def find(slug : String)
    return unless ubid = LabelMap.map_slug.fetch(slug)
    BookInfo.get(ubid)
  end

  def blacklist?(info : BookInfo)
    # TODO: check by both author and book title
    ValueSet.skip_titles.includes?(info.zh_title)
  end

  def whitelist?(info : BookInfo)
    OrderMap.top_authors.has_key?(info.zh_author)
  end

  def find_or_create(title : String, author : String, fixed = false)
    unless fixed
      title = Utils.fix_zh_title(title)
      author = Utils.fix_zh_author(author, title)
    end

    BookInfo.get_or_create(title, author)
  end

  def update(info : BookInfo, source : YsSerial, force = false)
    set_intro(info, source.intro, force: force)
    set_cover(info, "yousuu", source.fixed_cover, force: force)

    set_genre(info, "yousuu", source.genre, force: force)
    set_tags(info, "yousuu", source.fixed_tags, force: force)

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

    info
  end

  def update(info : BookInfo, source : SeedInfo, force = false)
    set_intro(info, source.intro, force: force)
    set_cover(info, source.seed, source.cover, force: force)

    set_genre(info, source.seed, source.genre, force: force)
    set_tags(info, source.seed, source.tags, force: force)

    set_status(info, source.status, force: force)
    set_mftime(info, source.mftime, force: force)

    info
  end

  def reset_info(info : BookInfo, force = false)
    Utils.update_token(TokenMap.zh_title, info.ubid, info.zh_title)
    Utils.update_token(TokenMap.zh_author, info.ubid, info.zh_author)

    set_hv_title(info, force: force)
    set_vi_title(info, force: force)
    set_vi_author(info, force: force)

    return unless force || info.slug.empty?

    title1_slug = TextUtil.slugify(info.hv_title)
    title2_slug = TextUtil.slugify(info.vi_title)

    author_slug = TextUtil.slugify(info.vi_author)
    full_slug_1 = "#{title1_slug}--#{author_slug}"
    full_slug_2 = "#{title2_slug}--#{author_slug}"

    # the shortest slug will remain
    set_slug(info, full_slug_1)
    set_slug(info, full_slug_2)
    set_slug(info, title1_slug)
    set_slug(info, title2_slug)
  end

  def set_hv_title(info : BookInfo, hv_title = "", force = false)
    return unless force || info.hv_title.empty?
    hv_title = Utils.hanviet(info.zh_title) if hv_title.empty?

    Utils.update_token(TokenMap.hv_title, info.ubid, hv_title)
    info.hv_title = hv_title
  end

  def set_vi_title(info : BookInfo, vi_title = "", force = false)
    return unless force || info.vi_title.empty?

    if vi_title.empty?
      if title = LabelMap.vi_title.fetch(info.zh_title)
        vi_title = TextUtil.titleize(title)
      elsif info.hv_title.empty?
        vi_title = Utils.hanviet(info.zh_title)
        set_hv_title(info, vi_title)
      else
        vi_title = info.hv_title
      end
    end

    Utils.update_token(TokenMap.vi_title, info.ubid, vi_title)
    info.vi_title = vi_title
  end

  def set_vi_author(info : BookInfo, vi_author = "", force = false)
    return unless force || info.vi_author.empty?

    if vi_author.empty?
      unless vi_author = LabelMap.vi_author.fetch(info.zh_author)
        vi_author = Utils.hanviet(info.zh_author)
      end
    end

    Utils.update_token(TokenMap.vi_author, info.ubid, vi_author)
    info.vi_author = vi_author
  end

  def set_slug(info : BookInfo, slug : String) : String?
    if ubid = LabelMap.map_slug.fetch(slug)
      return if ubid != info.ubid
    else
      LabelMap.map_slug.upsert!(slug, info.ubid)
    end

    info.slug = slug
  end

  def set_intro(info : BookInfo, zh_intro : String, force = false)
    return unless force || info.zh_intro.empty?

    # assuming zh_intro is unclean
    lines = TextUtil.split_html(zh_intro)

    info.zh_intro = lines.join("\n")
    info.vi_intro = Utils.cv_intro(lines, info.ubid)
  end

  # currently unused
  def set_vi_intro(info : BookInfo, vi_intro = "", force = false)
    return unless force || info.vi_intro.empty?

    # assuming zh_intro is cleaned
    lines = info.zh_intro.split("\n")

    info.vi_intro = Utils.cv_intro(lines, info.ubid)
  end

  def set_genre(info : BookInfo, site : String, genre : String, force = false)
    return unless force || !info.zh_genres.includes?(site)
    info.add_zh_genre(site, genre)

    zh_genres = Utils.fix_zh_genres(info.zh_genres.values, min_count: 2)
    info.vi_genres = Utils.map_vi_genres(zh_genres)

    Utils.update_token(TokenMap.vi_genres, info.ubid, info.vi_genres)
  end

  def set_tags(info : BookInfo, site : String, tags : Array(String), force = false)
    return unless force || !info.zh_tags.includes?(site)
    info.add_zh_tags(site, tags.join("¦"))
    tags.each { |tag_zh| info.add_vi_tag(Utils.hanviet(tag_zh)) }

    Utils.update_token(TokenMap.vi_tags, info.ubid, info.vi_tags)
  end

  def set_cover(info : BookInfo, site : String, cover : String, force = false)
    return unless force || !info.cover_urls.includes?(site)
    info.add_cover(site, cover)
    # TODO: Fetch covers?
  end

  def set_shield(info : BookInfo, shield = 0, force = false)
    return unless force || info.shield < shield
    info.shield = shield
    # TODO: remove info from order_map indexes if shield > 0 ?
  end

  def set_status(info : BookInfo, status = 0, force = false)
    return unless force || info.status < status
    info.status = status
  end

  def set_mftime(info : BookInfo, mftime = 0_i64, force = false)
    return unless force || info.mftime < mftime
    Utils.update_order(OrderMap.book_update, info.ubid, mftime)
    Utils.update_order(OrderMap.book_access, info.ubid, mftime)
    info.mftime = mftime
  end

  def set_voters(info : BookInfo, voters : Int32, force = false)
    return unless force || info.voters < voters
    info.voters = voters
  end

  def set_rating(info : BookInfo, rating : Float, force = false)
    return unless force || info.rating < rating
    Utils.update_order(OrderMap.book_rating, info.ubid, info.scored)
    info.rating = rating
  end

  def set_weight(info : BookInfo, weight : Int64, force = true)
    return unless force || info.weight < weight
    Utils.update_order(OrderMap.book_weight, info.ubid, weight)
    info.weight = weight
  end

  def add_seed(info : BookInfo, seed : String, type : String, latest : ChapInfo, mftime : Int64)
    3
  end
end
