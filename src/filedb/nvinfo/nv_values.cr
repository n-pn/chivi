require "./nv_helper"

module CV::NvValues
  extend self

  class_getter _index : TokenMap { NvHelper.token_map("_index") }

  class_getter btitle : ValueMap { NvHelper.value_map("btitle") }
  class_getter author : ValueMap { NvHelper.value_map("author") }

  class_getter genres : ValueMap { NvHelper.value_map("genres") }

  class_getter bcover : ValueMap { NvHelper.value_map("bcover") }
  class_getter yousuu : ValueMap { NvHelper.value_map("yousuu") }
  class_getter origin : ValueMap { NvHelper.value_map("origin") }

  class_getter voters : OrderMap { NvHelper.order_map("voters") }
  class_getter rating : OrderMap { NvHelper.order_map("rating") }
  class_getter weight : OrderMap { NvHelper.order_map("weight") }

  class_getter source : ValueMap { NvHelper.value_map("source") }

  class_getter hidden : ValueMap { NvHelper.value_map("hidden") }
  class_getter status : ValueMap { NvHelper.value_map("status") }

  class_getter _atime : OrderMap { NvHelper.order_map("_atime") }
  class_getter _utime : OrderMap { NvHelper.order_map("_utime") }

  def save!(mode : Symbol = :full)
    @@_index.try(&.save!(mode: mode))

    @@btitle.try(&.save!(mode: mode))
    @@author.try(&.save!(mode: mode))

    @@genres.try(&.save!(mode: mode))
    @@bcover.try(&.save!(mode: mode))
    @@source.try(&.save!(mode: mode))

    @@yousuu.try(&.save!(mode: mode))
    @@origin.try(&.save!(mode: mode))

    @@hidden.try(&.save!(mode: mode))
    @@status.try(&.save!(mode: mode))

    @@voters.try(&.save!(mode: mode))
    @@rating.try(&.save!(mode: mode))
    @@weight.try(&.save!(mode: mode))

    @@_atime.try(&.save!(mode: mode))
    @@_utime.try(&.save!(mode: mode))
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

  def get_source(b_hash : String) : Hash(String, String)
    source = NvValues.source.get(b_hash) || [] of String
    source.each_with_object({} of String => String) do |entry, output|
      s_name, s_nvid = entry.split("/")
      output[s_name] = s_nvid
    end
  end

  def set_score(b_hash : String, z_voters : Int32, z_rating : Int32)
    voters.add(b_hash, z_voters)

    if z_voters == 0
      z_rating = Random.rand(30..50)
    elsif z_voters < 10
      sum = Random.rand(30..50) * (10 - z_voters) + z_voters * z_rating
      z_rating = sum // 10
    end

    score = Math.log(z_voters + 10).*(z_rating * 10).round.to_i
    weight.add(b_hash, score)
  end

  {% for field in {:hidden, :status} %}
    def set_{{field.id}}(b_hash, value : Int32, force : Bool = false)
      return unless force || ({{field.id}}.ival(b_hash) < value)
      {{field.id}}.add(b_hash, value)
    end
  {% end %}

  {% for field in {:_atime, :_utime} %}
    def set{{field.id}}(b_hash, value : Int64, force : Bool = false)
      return unless force || ({{field.id}}.ival_64(b_hash) < value)
      {{field.id}}.add(b_hash, value)
    end

    def set{{field.id}}(b_hash, value : Time, force : Bool = false)
      set{{field.id}}(b_hash, value.to_unix, force: force)
    end
  {% end %}
end
