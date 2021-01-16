require "./nvinfo/*"

module CV::Nvinfo
  extend self

  class_getter _index : TokenMap { Butils.token_map("_index") }

  class_getter btitle : ValueMap { Butils.value_map("btitle") }
  class_getter author : ValueMap { Butils.value_map("author") }

  class_getter bgenre : ValueMap { Butils.value_map("bgenre") }
  class_getter chseed : ValueMap { Butils.value_map("chseed") }

  class_getter bcover : ValueMap { Butils.value_map("bcover") }
  class_getter yousuu : ValueMap { Butils.value_map("yousuu") }
  class_getter origin : ValueMap { Butils.value_map("origin") }

  class_getter shield : ValueMap { Butils.value_map("shield") }
  class_getter status : ValueMap { Butils.value_map("status") }

  class_getter voters : OrderMap { Butils.order_map("voters") }
  class_getter rating : OrderMap { Butils.order_map("rating") }
  class_getter weight : OrderMap { Butils.order_map("weight") }

  class_getter access_tz : OrderMap { Butils.order_map("tz_access") }
  class_getter update_tz : OrderMap { Butils.order_map("tz_update") }

  def upsert!(zh_btitle : String, zh_author : String, fixed : Bool = false)
    unless fixed
      zh_btitle = Butils.fix_zh_btitle(zh_btitle)
      zh_author = Butils.fix_zh_author(zh_author)
    end

    bhash = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")
    existed = _index.has_key?(bhash)

    unless existed
      set_author(bhash, zh_author)
      set_btitle(bhash, zh_btitle)

      bslug = Tokens.btitle_hv.get(bhash).not_nil!.join("-")
      bslug += "-#{bhash}" if _index.has_val?(bslug)

      slugs = [bslug]
      if vi_tokens = Tokens.btitle_vi.get(bhash)
        vslug = vi_tokens.join("-")
        slugs << vslug unless _index.has_val?(vslug)
      end

      _index.add(bhash, slugs)
    end

    {bhash, existed}
  end

  def set_btitle(bhash : String,
                 zh_btitle : String,
                 hv_btitle : String? = nil,
                 vi_btitle : String? = nil) : Nil
    hv_btitle ||= Utils.to_hanviet(zh_btitle)
    vi_btitle ||= Utils.fix_vi_btitle(zh_btitle)
    vi_btitle = nil if vi_btitle == hv_btitle

    vals = [zh_btitle, hv_btitle]
    vals << vi_btitle if vi_btitle

    if btitle.add(bhash, vals)
      Tokens.set_btitle_zh(bhash, zh_btitle)
      Tokens.set_btitle_hv(bhash, hv_btitle)
      Tokens.set_btitle_vi(bhash, vi_btitle) if vi_btitle
    end
  end

  def set_author(bhash : String,
                 zh_author : String,
                 vi_author : String? = nil) : Nil
    vi_author ||= Utils.fix_vi_author(zh_author)

    if author.add(bhash, [zh_author, vi_author])
      Tokens.set_author_zh(bhash, zh_author)
      Tokens.set_author_vi(bhash, vi_author)
    end
  end

  def set_bgenre(bhash : String, genres : Array(String), force : Bool = false) : Nil
    return unless force || !bgenre.has_key?(bhash)
    if bgenre.add(bhash, genres)
      Tokens.set_bgenre(bhash, genres)
    end
  end

  def set_bintro(bhash : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = Utils.intro_file(bhash, "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    vi_file = Utils.intro_file(bhash, "vi")
    cv_tool = Convert.content(bhash)

    vi_intro = lines.map { |line| cv_tool.tl_plain(line) }
    File.write(vi_file, vi_intro.join("\n"))
  end

  def get_bintro(bhash : String) : Array(String)
    vi_file = Utils.intro_file(bhash, "vi")
    File.read_lines(vi_file) || [] of String
  end

  BINTROS = {} of String => Array(String)

  def get_cached_bintro(bhash : String)
    BINTROS[bhash] ||= get_bintro(bhash)
  end

  def set_chseed(bhash : String, seed : String, sbid : String) : Nil
    seeds = chseed.get(bhash) || [] of String
    seeds = seeds.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if seeds[seed]? == sbid
    seeds[seed] = sbid

    chseed.add(bhash, seeds.to_a.map { |a, b| "#{a}/#{b}" })
    Tokens.set_chseed(bhash, seeds.keys)
  end

  def get_chseed(bhash : String) : Hash(String, String)
    output = {} of String => String

    return output unless seeds = chseed.get(bhash)

    seeds.each do |entry|
      seed, sbid = entry.split("/")
      output[seed] = sbid
    end

    output
  end

  CHSEED = {} of String => Hash(String, String)

  def get_cached_chseed(bhash : String)
    CHSEED[bhash] ||= get_chseed(bhash)
  end

  {% for field in {:shield, :status} %}
    def set_{{field.id}}(bhash, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(bhash) < value)
      {{field.id}}.add(bhash, value)
    end
  {% end %}

  def set_score(bhash : String, z_voters : Int32, z_rating : Int32)
    return unless voters.add(bhash, z_voters) || rating.add(bhash, z_rating)
    score = Math.log(z_voters + 10).*(z_rating * 10).round.to_i
    weight.add(bhash, score)
  end

  {% for field in {:access_tz, :update_tz} %}
    def set_{{field.id}}(bhash, value : Int64, force : Bool = false)
      return unless force || ({{field.id}}.ival_64(bhash) < value)
      {{field.id}}.add(bhash, value)
    end

    def set_{{field.id}}(bhash, value : Time, force : Bool = false)
      set_{{field.id}}(bhash, value.to_unix, force: force)
    end
  {% end %}

  def save!(mode : Symbol = :full)
    @@_index.try(&.save!(mode: mode))

    @@btitle.try(&.save!(mode: mode))
    @@author.try(&.save!(mode: mode))

    @@bgenre.try(&.save!(mode: mode))
    @@chseed.try(&.save!(mode: mode))

    @@bcover.try(&.save!(mode: mode))
    @@yousuu.try(&.save!(mode: mode))
    @@origin.try(&.save!(mode: mode))

    @@shield.try(&.save!(mode: mode))
    @@status.try(&.save!(mode: mode))

    @@voters.try(&.save!(mode: mode))
    @@rating.try(&.save!(mode: mode))
    @@weight.try(&.save!(mode: mode))

    @@access_tz.try(&.save!(mode: mode))
    @@update_tz.try(&.save!(mode: mode))

    Tokens.save!(mode: mode)
  end

  def bump_access!(bhash : String, atime : Time = Time.utc) : Nil
    return unless access_tz.add(atime.to_unix // 60)
    access_tz.save!(mode: :upds) if access_tz.unsaved > 20
  end

  def get_basic_info(bhash : String)
    BasicInfo.new(
      bhash: bhash,
      bslug: _index.fval(bhash) || bhash,

      btitle: btitle.get(bhash).not_nil!,
      author: author.get(bhash).not_nil!,

      genres: bgenre.get(bhash) || [] of String,
      bcover: bcover.fval(bhash),

      voters: voters.ival(bhash),
      rating: rating.ival(bhash),
    )
  end

  def get_extra_info(bhash : String)
    ExtraInfo.new(
      chseed: get_cached_chseed(bhash),
      bintro: get_cached_bintro(bhash),

      status: status.ival(bhash),

      yousuu: yousuu.fval(bhash),
      origin: origin.fval(bhash),

      update_tz: update_tz.ival_64(bhash),
    )
  end

  def find_by_slug(slug : String)
    _index.keys(slug).first
  end

  def each(order = "weight", skip = 0, take = 24, matched : Set(String)? = nil)
    order_map = get_order_map(order)

    if !matched
      iter = order_map._idx.reverse_each
      skip.times { return unless iter.next }

      take.times do
        return unless node = iter.next
        yield node.key
      end
    elsif matched.size > 512
      iter = order_map._idx.reverse_each

      while skip > 0
        return unless node = iter.next
        skip -= 1 if matched.includes?(node.key)
      end

      while take > 0
        return unless node = iter.next

        if matched.includes?(node.key)
          yield node.key
          take -= 1
        end
      end
    else
      list = matched.to_a.sort_by { |bhash| order_map.get_val(bhash).- }
      upto = skip + take
      upto = list.size if upto > list.size
      skip.upto(upto) { |i| yield list.unsafe_fetch(i) }
    end
  end

  def get_order_map(order : String)
    case order
    when "access" then access_tz
    when "update" then update_tz
    when "rating" then rating
    when "voters" then voters
    else               weight
    end
  end
end

# puts CV::Nvinfo.find_by_slug("quy-bi-chi-chu")
# puts CV::Nvinfo.get_basic_info("h6cxpsr4")
# puts CV::Nvinfo.get_extra_info("h6cxpsr4")

# CV::Nvinfo.each("voters", take: 10) do |bhash|
#   puts CV::Nvinfo.get_basic_info(bhash)
# end

# CV::Nvinfo.each("voters", skip: 5, take: 5) do |bhash|
#   puts CV::Nvinfo.get_basic_info(bhash).btitle
# end

# matched = CV::Nvinfo::Tokens.glob(genre: "kinh di")
# CV::Nvinfo.each("weight", take: 10, matched: matched) do |bhash|
#   puts CV::Nvinfo.get_basic_info(bhash)
# end
