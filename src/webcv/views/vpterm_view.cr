require "json"

struct CV::VpTermView
  DIR = "var/vpterms"

  LASTNAMES = read_chars_to_set("#{DIR}/lastnames.txt")
  AFFILIATE = read_chars_to_set("#{DIR}/affiliate.txt")
  ATTRIBUTE = read_chars_to_set("#{DIR}/attribute.txt")

  def self.read_chars_to_set(file : String) : Set(Char)
    lines = File.read_lines(file)
    Set(Char).new(lines.map(&.[0]))
  end

  getter dname : String
  getter vdict : VpDict

  getter words : Array(String)
  getter uname : String

  getter hvmap : Hash(String, String)
  getter cvmtl : MtCore

  def initialize(@dname, @words, @hvmap, @uname = "~")
    @vdict = VpDict.load(@dname)
    @cvmtl = MtCore.load(@dname, @uname)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      @words.each do |word|
        jb.field(word) { to_json(jb, word) }
      end
    end
  end

  def to_json(jb : JSON::Builder, word : String)
    b_term, u_term, h_vals, h_tags = load_terms(word)

    jb.object do
      render_priv_term(jb, u_term) if u_term
      render_base_term(jb, b_term) if b_term

      fval = h_vals.first
      jb.field "h_vals", h_vals
      jb.field "h_fval", @vdict.dtype == 3 ? TextUtils.titleize(fval) : fval

      if @vdict.dtype > 0
        jb.field "h_tags", h_tags
        jb.field "h_ptag", h_tags.first
      end
    end
  end

  @[AlwaysInline]
  def render_priv_term(jb : JSON::Builder, u_term : VpTerm)
    jb.field "u_val", u_term.val.first
    jb.field "u_ptag", u_term.ptag.to_str
    jb.field "u_rank", u_term.rank

    jb.field "u_mtime", u_term.mtime
    # jb.field "u_uname", u_term.uname
    jb.field "u_state", u_term.state
  end

  @[AlwaysInline]
  def render_base_term(jb : JSON::Builder, b_term : VpTerm)
    jb.field "b_val", b_term.val.first
    jb.field "b_ptag", b_term.ptag.to_str
    jb.field "b_rank", b_term.rank

    jb.field "b_mtime", b_term.mtime
    jb.field "b_uname", b_term.uname
    jb.field "b_state", b_term.state
  end

  private def load_terms(word : String)
    vals = Set{@hvmap[word]}
    tags = Set(String).new

    if @vdict.dtype == 2 && (f_term = VpDict.fixture.find(word))
      b_term, u_term = f_term, nil
      add_hints(f_term, vals, tags)
    elsif node = @vdict.trie.find(word)
      b_term, u_term = node.base, node.privs[@uname]?
      add_hints(node, vals, tags)
    else
      b_term, u_term = nil, nil
    end

    tran = @cvmtl.cv_plain(word, cap_first: false)
    vals << tran.to_s

    if @vdict.dtype > 0
      fc, lc = word[0], word[-1]
      tags << "nr" if LASTNAMES.includes?(fc)
      tags << "nn" if AFFILIATE.includes?(lc)
      tags << "na" if ATTRIBUTE.includes?(lc) || fc == '姓'

      extract_tag(tran).try { |t| tags << t }
      tags << (@vdict.dtype == 3 ? "nr" : "n")
    end

    {b_term, u_term, vals, tags}
  end

  @[AlwaysInline]
  private def extract_tag(tran : MtList) : String?
    # exit if list is not singleton
    return unless (first = tran.first) && first.body?

    case tag = first.tag.to_str
    when "np" then "n"
    when "ap" then "a"
    when "vp" then "v"
    else           tag
    end
  end

  private def add_hints(node : VpTrie, vals : Set(String), tags : Set(String))
    node.base.try { |x| add_hints(x, vals, tags) }
    node.privs.each_value { |t| add_hints(t, vals, tags) }
  end

  private def add_hints(term : VpTerm, vals : Set(String), tags : Set(String))
    vals.concat(term.val)
    tags << term.ptag.to_str

    return unless prev = term._prev
    vals.concat(prev.val)
    tags << term.ptag.to_str
  end
end
