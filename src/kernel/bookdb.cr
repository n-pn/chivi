require "json"
require "colorize"

require "./parser/ys_serial"
require "./parser/seed_info"

require "./bookdb/*"
require "./chapdb/utils"

module BookDB
  extend self

  delegate get, to: BookInfo
  delegate get!, to: BookInfo

  def find(slug : String)
    return unless ubid = OldLabelMap.book_slug.fetch(slug)
    BookInfo.get(ubid)
  end

  def blacklist?(info : BookInfo)
    # TODO: check by both author and book title
    blacklist?(info.zh_title)
  end

  def blacklist?(title : String)
    OldValueSet.skip_titles.includes?(title)
  end

  def whitelist?(info : BookInfo)
    whitelist?(info.zh_author)
  end

  def whitelist?(author : String)
    return false unless weight = OldOrderMap.author_weight.value(author)
    weight >= 2000
  end

  def find_or_create(title : String, author : String, fixed = false)
    unless fixed
      title = Utils.fix_zh_title(title)
      author = Utils.fix_zh_author(author, title)
    end

    BookInfo.get_or_create(title, author)
  end

  def update_info(info : BookInfo, source : YsSerial, force = false)
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

  def update_info(info : BookInfo, source : SeedInfo, force = false)
    set_intro(info, source.intro, force: !info.zh_intro.includes?("\n"))
    set_cover(info, source.seed, source.cover, force: force)

    set_genre(info, source.seed, source.genre, force: force)
    set_tags(info, source.seed, source.tags, force: force)

    set_status(info, source.status, force: force)
    update_seed(info, source, force: force)

    # if info.weight == 0 && info.yousuu_bid.empty?
    #   puts "- FAKING RANDOM RATING -".colorize.yellow
    #   voters, rating, weight = Utils.fake_rating(info.zh_author)

    #   set_voters(info, voters, force: false)
    #   set_rating(info, rating, force: false)
    #   set_weight(info, weight, force: false)
    # end

    info
  end

  def update_seed(info : BookInfo, source : SeedInfo, force = false)
    if info.seed_sbids[source.seed]? != source.sbid
      return if info.seed_mftimes.fetch(source.seed, 0_i64) > source.mftime
      info.set_seed_sbid(source.seed, source.sbid)
    end

    info.add_seed(source.seed)
    # info.set_seed_type(source.seed, 0)
    update_seed(info, source.seed, source.latest, source.mftime)
  end

  def update_seed(info : BookInfo, seed_name : String, latest : ChapInfo, mftime : Int64)
    latest = ChapDB::Utils.convert(latest, info.ubid)
    info.set_seed_latest(seed_name, latest, mftime)
    mftime = info.seed_mftimes[seed_name]
    set_mftime(info, mftime)
  end

  def upsert_info(info : BookInfo, force = false)
    return unless force || info.slug.empty?

    Utils.update_token(OldTokenMap.zh_title, info.ubid, info.zh_title)
    Utils.update_token(OldTokenMap.zh_author, info.ubid, info.zh_author)

    set_hv_title(info, force: force)
    set_vi_title(info, force: force)
    set_vi_author(info, force: force)

    author_slug = TextUtil.slugify(info.vi_author)

    title1_slug = TextUtil.slugify(info.hv_title)
    full_slug_1 = "#{title1_slug}--#{author_slug}"

    book_slug = check_slug(info, title1_slug) || check_slug(info, full_slug_1)
    info.slug = book_slug || check_slug(info, "#{title1_slug}-#{info.ubid}").not_nil!

    title2_slug = TextUtil.slugify(info.vi_title)

    return if title2_slug == title1_slug
    full_slug_2 = "#{title2_slug}--#{author_slug}"
    check_slug(info, title2_slug) || check_slug(info, full_slug_2)
  end

  def set_hv_title(info : BookInfo, hv_title = "", force = false)
    return unless force || info.hv_title.empty?
    hv_title = Utils.hanviet(info.zh_title) if hv_title.empty?

    Utils.update_token(OldTokenMap.hv_title, info.ubid, hv_title)
    info.hv_title = hv_title
  end

  def set_vi_title(info : BookInfo, vi_title = "", force = false)
    return unless force || info.vi_title.empty?

    if vi_title.empty?
      if title = OldLabelMap.vi_title.fetch(info.zh_title)
        vi_title = TextUtil.titleize(title)
      elsif info.hv_title.empty?
        vi_title = Utils.hanviet(info.zh_title)
        set_hv_title(info, vi_title)
      else
        vi_title = info.hv_title
      end
    end

    Utils.update_token(OldTokenMap.vi_title, info.ubid, vi_title)
    info.vi_title = vi_title
  end

  def set_vi_author(info : BookInfo, vi_author = "", force = false)
    return unless force || info.vi_author.empty?

    if vi_author.empty?
      unless vi_author = OldLabelMap.vi_author.fetch(info.zh_author)
        vi_author = Utils.hanviet(info.zh_author)
      end
    end

    Utils.update_token(OldTokenMap.vi_author, info.ubid, vi_author)
    info.vi_author = vi_author
  end

  def check_slug(info : BookInfo, slug : String) : String?
    if ubid = OldLabelMap.book_slug.fetch(slug)
      return if ubid != info.ubid
    else
      OldLabelMap.book_slug.upsert!(slug, info.ubid)
      slug
    end
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

    zh_genres = Utils.fix_zh_genres(info.zh_genres)
    info.vi_genres = Utils.map_vi_genres(zh_genres.first(3))

    Utils.update_token(OldTokenMap.vi_genres, info.ubid, info.vi_genres)
  end

  def set_tags(info : BookInfo, site : String, tags : Array(String), force = false)
    return unless force || !info.zh_tags.includes?(site)
    info.add_zh_tags(site, tags.join("¦"))
    tags.each { |tag_zh| info.add_vi_tag(Utils.hanviet(tag_zh)) }

    Utils.update_token(OldTokenMap.vi_tags, info.ubid, info.vi_tags)
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
    Utils.update_order(OldOrderMap.book_update, info.ubid, mftime)
    Utils.update_order(OldOrderMap.book_access, info.ubid, mftime)
    info.mftime = mftime
  end

  def set_voters(info : BookInfo, voters : Int32, force = false)
    return unless force || info.voters < voters
    info.voters = voters
  end

  def set_rating(info : BookInfo, rating : Float, force = false)
    return unless force || info.rating < rating
    Utils.update_order(OldOrderMap.book_rating, info.ubid, (rating * 10).to_i64)
    info.rating = rating
  end

  def set_weight(info : BookInfo, weight : Int64, force = true)
    return unless force || info.weight < weight
    Utils.update_order(OldOrderMap.book_weight, info.ubid, weight)
    info.weight = weight
  end

  # def inc_counter(info : BookInfo, read = false)
  #   info.view_count += 1
  #   info.read_count += 1 if read

  #   info.save!
  # end

  def bump_access(info : BookInfo, value : Int64 = Time.utc.to_unix_ms)
    Utils.update_order(OldOrderMap.book_access, info.ubid, value)
  end
end
