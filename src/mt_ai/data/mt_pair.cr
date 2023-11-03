require "./mt_attr"
require "./zv_pair"

class MT::MtPair
  struct Pair
    getter a_vstr : String
    getter a_attr : MtAttr?

    getter b_vstr : String?
    getter b_attr : MtAttr = MtAttr::None

    def initialize(@a_vstr, a_attr : String?, @b_vstr = nil, b_attr : String? = nil)
      @a_attr = MtAttr.parse_list(a_attr) if a_attr
      @b_attr = MtAttr.parse_list(b_attr) if b_attr
    end
  end

  getter hash = {} of String => Hash(String, Pair)

  def initialize(@dname : String)
  end

  def add!(data : ZvPair)
    hash = @hash[data.a_key] ||= {} of String => Pair
    hash[data.b_key] = Pair.new(data.a_vstr, data.a_attr, data.b_vstr, data.b_attr)
  end

  def load_db3!(dname = @dname)
    ZvPair.fetch_all(dname).each { |zv_pair| add!(zv_pair) }
    self
  end

  def load_tsv!(dname : String = @dname)
    db_path = "var/mtdic/mt_ai/#{dname}.tsv"
    return self unless File.file?(db_path)

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      add!(ZvPair.new(cols)) if cols.size > 2
    end

    self
  end

  @[AlwaysInline]
  def get?(a_zstr : String, b_zstr : String)
    @hash[a_zstr]?.try(&.[b_zstr]?)
  end

  def get?(a_zstr : String, *b_list : String)
    return unless entry = @hash[a_zstr]?
    b_list.each { |b_zstr| entry[b_zstr]?.try { |x| return x } }
  end

  def fix_if_match!(a_node : AiNode, b_node : AiNode, b_stem = b_node.zstr) : Nil
    return unless entry = @hash[a_node.zstr]?

    if b_stem.size > 1
      b_list = {b_stem, "*#{b_stem[-1]}", "#{b_stem[0]}*", "*"}
    else
      b_list = {b_stem, "*"}
    end

    b_list.each do |b_zstr|
      next unless found = entry[b_zstr]?

      a_node.set_vstr!(found.a_vstr)

      if a_attr = found.a_attr
        a_node.set_attr!(a_attr)
      end

      if b_vstr = found.b_vstr
        b_node.set_vstr!(b_vstr) if b_zstr == b_node.zstr
      end

      if b_attr = found.b_attr
        b_node.add_attr!(b_attr)
      end

      break
    end
  end

  getter match_sufx : Regex {
    any_key = [] of String
    @hash.each { |k, v| any_key << k if v.has_key?("*") }
    Regex.new("^(.+)(#{any_key.join('|')})$")
  }

  def split_sufx(zstr : String)
    return unless match = match_sufx.match(zstr)
    _, b_zstr, a_zstr = match
    {b_zstr, a_zstr, @hash[a_zstr]["*"]}
  end

  ###

  CACHE = {} of String => self

  def self.load!(dname : String)
    CACHE[dname] ||= new(dname).load_db3!
  end

  class_getter m_n_pair : self { load!("m_n") }
  class_getter m_v_pair : self { load!("m_v") }

  class_getter p_v_pair : self { load!("p_v") }
  class_getter d_v_pair : self { load!("d_v") }

  class_getter v_v_pair : self { load!("v_v") }
  class_getter v_n_pair : self { load!("v_n") }
  class_getter v_c_pair : self { load!("v_c") }
end
