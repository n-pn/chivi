require "./mt_attr"

class MT::MtPair
  struct Pair
    getter a_vstr : String
    getter a_attr : MtAttr?

    getter b_vstr : String?
    getter b_attr : MtAttr

    def initialize(@a_vstr, @a_attr, @b_vstr, @b_attr = MtAttr::None)
    end

    def initialize(cols : Array(String))
      @a_vstr = cols[0]
      @a_attr = cols[1]?.try { |x| MtAttr.parse_list(x) }
      @b_vstr = cols[2]?.try { |x| x.empty? ? nil : x }
      @b_attr = cols[3]?.try { |x| MtAttr.parse_list(x) } || MtAttr::None
    end
  end

  def initialize(@dname : String)
    @hash = {} of String => Hash(String, Pair)
  end

  DIR = "var/mtdic/mt_ai"

  def load_tsv!(dname : String = @dname)
    db_path = "#{DIR}/#{dname}.tsv"
    return self unless File.file?(db_path)

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      next if cols.size < 3
      a_zstr, b_zstr, *cols = cols

      hash = @hash[a_zstr] ||= {} of String => Pair
      hash[b_zstr] = Pair.new(cols)
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

      break unless a_attr = found.a_attr
      a_node.set_attr!(a_attr)

      break unless b_vstr = found.b_vstr
      a_node.set_vstr!(b_vstr) if b_zstr == b_node.zstr

      break unless b_attr = found.b_attr
      b_node.add_attr!(b_attr)

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

  def add_more(pair : Pair)
  end

  ###

  class_getter m_n_pair : self { new("m_n_pair").load_tsv! }
  class_getter m_v_pair : self { new("m_v_pair").load_tsv! }

  class_getter p_v_pair : self { new("p_v_pair").load_tsv! }
  class_getter d_v_pair : self { new("d_v_pair").load_tsv! }

  class_getter v_v_pair : self { new("v_v_pair").load_tsv! }
  class_getter v_n_pair : self { new("v_n_pair").load_tsv! }
  class_getter v_c_pair : self { new("v_c_pair").load_tsv! }
end
