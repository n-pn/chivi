require "./nv_helper"

module CV::NvValues
  extend self

  class_getter _index : TokenMap { NvHelper.token_map("_index") }

  class_getter btitle : ValueMap { NvHelper.value_map("btitle") }
  class_getter author : ValueMap { NvHelper.value_map("author") }

  class_getter bgenre : ValueMap { NvHelper.value_map("bgenre") }
  class_getter chseed : ValueMap { NvHelper.value_map("chseed") }

  class_getter bcover : ValueMap { NvHelper.value_map("bcover") }
  class_getter yousuu : ValueMap { NvHelper.value_map("yousuu") }
  class_getter origin : ValueMap { NvHelper.value_map("origin") }

  class_getter shield : ValueMap { NvHelper.value_map("shield") }
  class_getter status : ValueMap { NvHelper.value_map("status") }

  class_getter voters : OrderMap { NvHelper.order_map("voters") }
  class_getter rating : OrderMap { NvHelper.order_map("rating") }
  class_getter weight : OrderMap { NvHelper.order_map("weight") }

  class_getter access_tz : OrderMap { NvHelper.order_map("tz_access") }
  class_getter update_tz : OrderMap { NvHelper.order_map("tz_update") }

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
  end

  def set_bgenre(b_hash : String, genres : Array(String), force : Bool = false) : Nil
    return unless force || !NvValues.bgenre.has_key?(b_hash)
    if NvValues.bgenre.add(b_hash, genres)
      NvTokens.set_bgenre(b_hash, genres)
    end
  end

  def set_bintro(b_hash : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = NvHelper.intro_file(b_hash, "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    vi_file = NvHelper.intro_file(b_hash, "vi")
    cv_tool = Convert.generic(b_hash)

    vi_intro = lines.map { |line| cv_tool.tl_plain(line) }
    File.write(vi_file, vi_intro.join("\n"))
  end

  def get_bintro(b_hash : String) : Array(String)
    vi_file = NvHelper.intro_file(b_hash, "vi")
    File.exists?(vi_file) ? File.read_lines(vi_file) : [] of String
  end

  def set_chseed(b_hash : String, seed : String, sbid : String) : Nil
    chseed = NvValues.chseed.get(b_hash) || [] of String
    chseed = chseed.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if chseed[seed]? == sbid
    chseed[seed] = sbid

    NvValues.chseed.add(b_hash, chseed.to_a.map { |a, b| "#{a}/#{b}" })
    NvTokens.set_chseed(b_hash, chseed.keys)
  end

  def get_chseed(b_hash : String) : Hash(String, String)
    output = {} of String => String

    return output unless seeds = chseed.get(b_hash)

    seeds.each do |entry|
      seed, sbid = entry.split("/")
      output[seed] = sbid
    end

    output
  end

  def set_score(b_hash : String, z_voters : Int32, z_rating : Int32)
    voters.add(b_hash, z_voters)
    rating.add(b_hash, z_rating)

    score = Math.log(z_voters + 10).*(z_rating * 10).round.to_i
    weight.add(b_hash, score)
  end

  {% for field in {:shield, :status} %}
    def set_{{field.id}}(b_hash, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(b_hash) < value)
      {{field.id}}.add(b_hash, value)
    end
  {% end %}

  {% for field in {:access_tz, :update_tz} %}
    def set_{{field.id}}(b_hash, value : Int64, force : Bool = false)
      return unless force || ({{field.id}}.ival_64(b_hash) < value)
      {{field.id}}.add(b_hash, value)
    end

    def set_{{field.id}}(b_hash, value : Time, force : Bool = false)
      set_{{field.id}}(b_hash, value.to_unix, force: force)
    end
  {% end %}
end
