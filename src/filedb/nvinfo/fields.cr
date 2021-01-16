require "./shared"

module CV::NvFields
  extend self

  class_getter _index : TokenMap { NvShared.token_map("_index") }

  class_getter btitle : ValueMap { NvShared.value_map("btitle") }
  class_getter author : ValueMap { NvShared.value_map("author") }

  class_getter bgenre : ValueMap { NvShared.value_map("bgenre") }
  class_getter chseed : ValueMap { NvShared.value_map("chseed") }

  class_getter bcover : ValueMap { NvShared.value_map("bcover") }
  class_getter yousuu : ValueMap { NvShared.value_map("yousuu") }
  class_getter origin : ValueMap { NvShared.value_map("origin") }

  class_getter shield : ValueMap { NvShared.value_map("shield") }
  class_getter status : ValueMap { NvShared.value_map("status") }

  class_getter voters : OrderMap { NvShared.order_map("voters") }
  class_getter rating : OrderMap { NvShared.order_map("rating") }
  class_getter weight : OrderMap { NvShared.order_map("weight") }

  class_getter access_tz : OrderMap { NvShared.order_map("tz_access") }
  class_getter update_tz : OrderMap { NvShared.order_map("tz_update") }

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

  def set_bgenre(bhash : String, genres : Array(String), force : Bool = false) : Nil
    return unless force || !NvFields.bgenre.has_key?(bhash)
    if NvFields.bgenre.add(bhash, genres)
      NvTokens.set_bgenre(bhash, genres)
    end
  end

  def set_bintro(bhash : String, lines : Array(String), force : Bool = false) : Nil
    zh_file = NvShared.intro_file(bhash, "zh")
    return unless force || !File.exists?(zh_file)

    File.write(zh_file, lines.join("\n"))

    vi_file = NvShared.intro_file(bhash, "vi")
    cv_tool = Convert.content(bhash)

    vi_intro = lines.map { |line| cv_tool.tl_plain(line) }
    File.write(vi_file, vi_intro.join("\n"))
  end

  def get_bintro(bhash : String) : Array(String)
    vi_file = NvShared.intro_file(bhash, "vi")
    File.exists?(vi_file) ? File.read_lines(vi_file) : [] of String
  end

  def set_chseed(bhash : String, seed : String, sbid : String) : Nil
    chseed = NvFields.chseed.get(bhash) || [] of String
    chseed = chseed.each_with_object({} of String => String) do |x, h|
      a, b = x.split("/")
      h[a] = b
    end

    return if chseed[seed]? == sbid
    chseed[seed] = sbid

    NvFields.chseed.add(bhash, chseed.to_a.map { |a, b| "#{a}/#{b}" })
    NvTokens.set_chseed(bhash, chseed.keys)
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

  def set_score(bhash : String, z_voters : Int32, z_rating : Int32)
    voters.add(bhash, z_voters)
    rating.add(bhash, z_rating)

    score = Math.log(z_voters + 10).*(z_rating * 10).round.to_i
    weight.add(bhash, score)
  end

  {% for field in {:shield, :status} %}
    def set_{{field.id}}(bhash, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(bhash) < value)
      {{field.id}}.add(bhash, value)
    end
  {% end %}

  {% for field in {:access_tz, :update_tz} %}
    def set_{{field.id}}(bhash, value : Int64, force : Bool = false)
      return unless force || ({{field.id}}.ival_64(bhash) < value)
      {{field.id}}.add(bhash, value)
    end

    def set_{{field.id}}(bhash, value : Time, force : Bool = false)
      set_{{field.id}}(bhash, value.to_unix, force: force)
    end
  {% end %}
end
