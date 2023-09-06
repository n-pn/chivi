require "./mt_prop"

class MT::MtDefn
  struct Defn
    getter a_vstr : String
    getter a_prop : MtProp?

    getter b_vstr : String?
    getter b_prop : MtProp?

    def initialize(@a_vstr, @a_prop, @b_vstr, @b_prop)
    end

    def self.new(cols : Array(String))
      new(
        a_vstr: cols[0],
        a_prop: cols[1]?.try { |x| MtProp.parse_list(x) },
        b_vstr: cols[2]?,
        b_prop: cols[3]?.try { |x| MtProp.parse_list(x) },
      )
    end
  end

  def initialize(@dname : String)
    @hash = {} of String => Hash(String, Defn)
  end

  DIR = "var/mtdic/mt_ai/core"

  def load_tsv!(dname : String = @dname)
    db_path = "#{DIR}/#{dname}.tsv"
    return self unless File.file?(db_path)

    File.each_line(db_path) do |line|
      cols = line.split('\t')
      next if cols.size < 3
      a_zstr, b_zstr, *cols = cols

      hash = @hash[a_zstr] ||= {} of String => Defn
      hash[b_zstr] = Defn.new(cols)
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
    return unless found = self.get?(a_node.zstr, b_stem, "_")

    a_node.set_vstr!(found.a_vstr)

    return unless a_prop = found.a_prop
    a_node.add_prop!(a_prop)

    return unless b_vstr = found.b_vstr
    a_node.set_vstr!(b_vstr)

    return unless b_prop = found.b_prop
    b_node.add_prop!(b_prop)
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
    return unless m_node = q_node.find_by_cpos("M")
    n_stem = MtStem.noun_stem(n_node.last.zstr)
    MtDefn.m_n_pair.fix_if_match!(m_node, n_node, n_stem)
  end
end
