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
    bintro[bhash] ||= begin
      vi_file = Utils.intro_file(bhash, "vi")
      File.read_lines(vi_file) || [] of String
    end
  end

  {% for field in {:shield, :status} %}
    def set_{{field.id}}(bhash, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(bhash) < value)
      {{field.id}}.add(bhash, value)
    end
  {% end %}

  def set_score(bhash : String, z_voters : Int32, z_rating : Int32)
    return unless voters.add(bhash, z_voters) || rating.add(bhash, z_rating)
    score = Math.log(z_voters + 10).*(z_rating).round.to_i
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
end
