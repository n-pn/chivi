require "../../mapper/*"
require "../../_utils/text_utils"

module CV::NvIndex
  extend self

  DIR = "_db/nvdata/indexes"
  ::FileUtils.mkdir_p(DIR)

  class_getter _index : TokenMap { TokenMap.new("#{DIR}/_index.tsv") }

  TOKENS = {
    :author_zh, :author_vi,
    :btitle_zh, :btitle_hv, :btitle_vi,
    :genres, :chseed,
  }

  {% for label in TOKENS %}
    class_getter {{label.id}} : TokenMap do
      TokenMap.new("#{DIR}/tokens.#{{{ label }}}.tsv", mode: 1)
    end

    def set_{{label.id}}(key : String, value : Array(String))
      value.map {|v| TextUtils.slugify(v)}.tap do |arr|
        {{label.id}}.set(key, arr)
      end
    end

    def set_{{label.id}}(key : String, value : String)
      TextUtils.tokenize(value).tap do |arr|
        {{label.id}}.set(key, arr)
      end
    end
  {% end %}

  ORDERS = {"access", "update", "voters", "rating", "weight"}

  {% for label in ORDERS %}
    class_getter {{label.id}} : OrderMap do
      OrderMap.new("#{DIR}/orders.#{{{ label }}}.tsv", mode: 1)
    end
  {% end %}

  {% for field in {"access", "update"} %}
    def set_{{field.id}}(bhash, value : Int64, force : Bool = false)
      return false unless force || value > {{field.id}}.ival_64(bhash)
      {{field.id}}.set!(bhash, value)
    end

    def set_{{field.id}}(bhash, value : Time, force : Bool = false)
      set_{{field.id}}(bhash, value.to_unix, force: force)
    end
  {% end %}

  def order_map(order : String? = nil)
    case order
    when "access" then NvIndex.access
    when "update" then NvIndex.update
    when "rating" then NvIndex.rating
    when "voters" then NvIndex.voters
    else               NvIndex.weight
    end
  end

  def set_scores(bhash : String, voters_val : Int32, rating_val : Int32)
    weight_val = voters_val * rating_val

    if voters_val < 30
      weight_val += (30 - voters_val) + Random.rand(40..60)
      rating_val = weight_val // 30
    end

    voters.set!(bhash, voters_val)
    rating.set!(bhash, rating_val)
    weight.set!(bhash, weight_val)
  end

  def save!(clean : Bool = false)
    _index.try(&.save!(clean: clean))

    {% for type in TOKENS %}
      @@{{ type.id }}.try(&.save!(clean: clean))
    {% end %}

    {% for type in ORDERS %}
      @@{{ type.id }}.try(&.save!(clean: clean))
    {% end %}
  end

  def filter(opts, matched : Set(String)? = nil)
    {"btitle", "author", "genre", "sname"}.each do |type|
      next unless inp = opts[type]?

      matched =
        case type
        when "btitle" then filter_btitle(inp, matched)
        when "author" then filter_author(inp, matched)
        when "genre"  then filter_bgenre(inp, matched)
        when "sname"  then filter_chseed(inp, matched)
        else               Set(String).new
        end

      return matched if matched.empty?
    end

    matched
  end

  def filter_btitle(inp : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(inp)
    res = inp =~ /\p{Han}/ ? btitle_zh.keys(tsv) : btitle_hv.keys(tsv) + btitle_vi.keys(tsv)
    prevs ? prevs & res : res
  end

  def filter_author(inp : String, prevs : Set(String)? = nil)
    tsv = TextUtils.tokenize(inp)
    res = inp =~ /\p{Han}/ ? author_zh.keys(tsv) : author_vi.keys(tsv)
    prevs ? prevs & res : res
  end

  def filter_bgenre(inp : String, prevs : Set(String)? = nil)
    res = genres.keys(TextUtils.slugify(inp))
    prevs ? prevs & res : res
  end

  def filter_chseed(inp : String, prevs : Set(String)? = nil)
    res = chseed.keys(inp.downcase)
    prevs ? prevs & res : res
  end
end
