require "./mt_attr"

class MT::MtPair
  struct Pair
    getter a_vstr : String
    getter a_attr : MtAttr?

    getter b_vstr : String?
    getter b_attr : MtAttr?

    def initialize(@a_vstr, @a_attr, @b_vstr, @b_attr)
    end

    def self.new(cols : Array(String))
      new(
        a_vstr: cols[0],
        a_attr: cols[1]?.try { |x| MtAttr.parse_list(x) },
        b_vstr: cols[2]?,
        b_attr: cols[3]?.try { |x| MtAttr.parse_list(x) },
      )
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

  def get?(a_zstr : String, b_zstr : String)
    @hash[a_zstr]?.try(&.[b_zstr]?)
  end

  def get?(a_zstr : String, *b_list : String)
    return unless entry = @hash[a_zstr]?
    b_list.each { |b_zstr| entry[b_zstr]?.try { |x| return x } }
  end

  def fix_if_match!(a_node : AiNode, b_node : AiNode, b_stem = b_node.zstr) : Nil
    return unless found = self.get?(a_node.zstr, b_stem, "X")

    a_node.set_vstr!(found.a_vstr)

    return unless a_attr = found.a_attr
    a_node.add_attr!(a_attr)

    return unless b_vstr = found.b_vstr
    a_node.set_vstr!(b_vstr)

    return unless b_attr = found.b_attr
    b_node.add_attr!(b_attr)
  end

  getter any_re : Regex {
    any_key = [] of String
    @hash.each { |k, v| any_key << k if v.has_key?("_") }
    Regex.new("^(.+)(#{any_key.join('|')})$")
  }

  def find_any(zstr : String)
    return unless match = any_re.match(zstr)
    _, a_zstr, b_zstr = match
    {a_zstr, @hash[b_zstr]["_"]}
  end

  ###

  class_getter m_n_pair : self { new("m_n_pair").load_tsv! }
  class_getter p_v_pair : self { new("p_v_pair").load_tsv! }
  class_getter v_n_pair : self { new("v_n_pair").load_tsv! }

  class_getter vcd_pair : self { new("vcd_pair").load_tsv! }
  class_getter vcp_pair : self { new("vcp_pair").load_tsv! }
  class_getter vrd_pair : self { new("vrd_pair").load_tsv! }

  # class_getter v_r_pair : self { new("v_d_pair") }

  def self.fix_m_n_pair!(q_node : AiNode, n_node : AiNode) : Void
    return unless m_node = q_node.find_by_epos(:M)
    n_stem = MtStem.noun_stem(n_node.last.zstr)
    self.m_n_pair.fix_if_match!(m_node, n_node, n_stem)
  end
end
