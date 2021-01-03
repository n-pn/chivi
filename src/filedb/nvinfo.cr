require "./nvinfo/*"

module CV::Nvinfo
  extend self

  class_getter _index : TokenMap { Utils.token_map("_index") }

  class_getter btitle : ValueMap { Utils.value_map("btitle") }
  class_getter author : ValueMap { Utils.value_map("author") }

  class_getter bgenre : ValueMap { Utils.value_map("bgenre") }
  class_getter chseed : ValueMap { Utils.value_map("chseed") }

  class_getter bcover : ValueMap { Utils.value_map("bcover") }
  class_getter yousuu : ValueMap { Utils.value_map("yousuu") }
  class_getter origin : ValueMap { Utils.value_map("origin") }

  class_getter shield : ValueMap { Utils.value_map("shield") }
  class_getter status : ValueMap { Utils.value_map("status") }

  class_getter voters : OrderMap { Utils.order_map("voters") }
  class_getter rating : OrderMap { Utils.order_map("rating") }
  class_getter weight : OrderMap { Utils.order_map("weight") }

  class_getter access_tz : OrderMap { Utils.order_map("tz_access") }
  class_getter update_tz : OrderMap { Utils.order_map("tz_update") }

  class_getter bintro = {} of String => String

  def upsert!(zh_btitle : String, zh_author : String, fixed : Bool = false)
    unless fixed
      zh_btitle = Utils.fix_zh_btitle(zh_btitle)
      zh_author = Utils.fix_zh_author(zh_author)
    end

    zh_slug = CoreUtils.digest32("#{zh_btitle}--#{zh_author}")
    existed = _index.has_key?(zh_slug)

    unless existed
      set_author(zh_slug, zh_author)
      set_btitle(zh_slug, zh_btitle)

      hv_slug = Tokens.btitle_hv.get(zh_slug).not_nil!.join("-")
      hv_slug += "-#{zh_slug}" if _index.has_val?(hv_slug)

      slugs = [hv_slug]
      if vi_tokens = Tokens.btitle_vi.get(zh_slug)
        vi_slug = vi_tokens.join("-")
        slugs << vi_slug unless _index.has_val?(vi_slug)
      end

      _index.add(zh_slug, slugs)
    end

    {zh_slug, existed}
  end

  def set_btitle(zh_slug : String,
                 zh_btitle : String,
                 hv_btitle : String? = nil,
                 vi_btitle : String? = nil) : Nil
    hv_btitle ||= Utils.to_hanviet(zh_btitle)
    vi_btitle ||= Utils.fix_vi_btitle(zh_btitle)
    vi_btitle = nil if vi_btitle == hv_btitle

    vals = [zh_btitle, hv_btitle]
    vals << vi_btitle if vi_btitle

    if btitle.add(zh_slug, vals)
      Tokens.set_btitle_zh(zh_slug, zh_btitle)
      Tokens.set_btitle_hv(zh_slug, hv_btitle)
      Tokens.set_btitle_vi(zh_slug, vi_btitle) if vi_btitle
    end
  end

  def set_author(zh_slug : String,
                 zh_author : String,
                 vi_author : String? = nil) : Nil
    vi_author ||= Utils.fix_vi_author(zh_author)

    if author.add(zh_slug, [zh_author, vi_author])
      Tokens.set_author_zh(zh_slug, zh_author)
      Tokens.set_author_vi(zh_slug, vi_author)
    end
  end

  def set_bgenre(zh_slug : String, genres : Array(String), force : Bool = false) : Nil
    return unless force || !bgenre.has_key?(zh_slug)
    if bgenre.add(zh_slug, genres)
      Tokens.set_bgenre(zh_slug, genres)
    end
  end

  def set_chseed(zh_slug : String, seed : String, sbid : String) : Nil
    seeds = chseed.get(zh_slug) || [] of String
    seeds = seeds.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if seeds[seed]? == sbid
    seeds[seed] = sbid

    chseed.add(zh_slug, seeds.to_a.map { |a, b| "#{a}/#{b}" })
    Tokens.set_chseed(zh_slug, seeds.keys)
  end

  def set_bintro(zh_slug : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = Utils.intro_file(zh_slug, "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    vi_file = Utils.intro_file(zh_slug, "vi")
    cv_tool = Convert.content(zh_slug)

    vi_intro = lines.map { |line| cv_tool.tl_plain(line) }
    File.write(vi_file, vi_intro.join("\n"))
  end

  def get_bintro(zh_slug : String) : Array(String)
    bintro[zh_slug] ||= begin
      vi_file = Utils.intro_file(zh_slug, "vi")
      File.read_lines(vi_file) || [] of String
    end
  end

  {% for field in {:shield, :status} %}
    def set_{{field.id}}(zh_slug, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(zh_slug) < value)
      {{field.id}}.add(zh_slug, value)
    end
  {% end %}

  def set_score(zh_slug : String, z_voters : Int32, z_rating : Int32)
    return unless voters.add(zh_slug, z_voters) || rating.add(zh_slug, z_rating)
    score = Math.log(z_voters + 10).*(z_rating).round.to_i
    weight.add(zh_slug, score)
  end

  {% for field in {:access_tz, :update_tz} %}
    def set_{{field.id}}(zh_slug, value : Int64, force : Bool = false)
      return unless force || ({{field.id}}.ival_64(zh_slug) < value)
      {{field.id}}.add(zh_slug, value)
    end

    def set_{{field.id}}(zh_slug, value : Time, force : Bool = false)
      set_{{field.id}}(zh_slug, value.to_unix, force: force)
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
end
