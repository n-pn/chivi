require "json"
require "../../mtlv1/*"

struct CV::VpTermView
  DIR = "var/dicts/vx/detect"

  getter dname : String
  getter vdict : VpDict

  getter words : Array(String)
  getter uname : String

  getter hvmap : Hash(String, String)

  def initialize(@dname, @words, @hvmap, @uname = "")
    @vdict = VpDict.load(@dname)
    @word_mtl = MtCore.load(@dname, @uname)
    @name_mtl = TlName.new(@vdict)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      @words.each do |word|
        jb.field(word) {
          TermView.new(word, @uname, @vdict, @hvmap[word], @word_mtl, @name_mtl).to_json(jb)
        }
      end
    end
  end

  alias Hints = Set(String)

  private def load_terms(word : String)
    vals = Hints.new
    tags = Hints.new
    vals << @hvmap[word]

    if @vdict.type == 2 && (f_term = VpDict.fixture.find(word))
      b_term, u_term = f_term, nil
      add_hints(f_term, vals, tags)
    elsif node = @vdict.trie.find(word)
      b_term, u_term = node.base, node.privs["!" + @uname]?
      add_hints(node, vals, tags)
    else
      b_term, u_term = nil, nil
    end

    if @dname[0] == '~'
      fval = @core_mtl.cv_plain(word, cap_first: false).to_s
      ptag = ""
    elsif @vdict.type > 0
      fval, ptag = add_hints_by_ctx(word, vals, tags)
    else
      fval, ptag = vals.first?, ""
    end

    {b_term, u_term, vals, tags, fval, ptag}
  end

  private def add_hints(node : VpTrie, vals : Hints, tags : Hints)
    node.base.try { |x| add_hints(x, vals, tags) }
    node.privs.each_value { |t| add_hints(t, vals, tags) }
  end

  class TermView
    getter val_hints = Set(String).new
    getter tag_hints = Set(String).new

    @first_val : String? = nil
    @first_tag : String? = nil

    def initialize(@word : String, @uname : String,
                   @vdict : VpDict, hanviet : String,
                   @word_mtl : MtCore, @name_mtl : TlName)
      @val_hints << hanviet
    end

    def to_json(jb : JSON::Builder)
      b_term, u_term = load_terms
      fill_hints(u_term || b_term) unless @vdict.kind.other?

      jb.object do
        if u_term
          jb.field "u_val", u_term.val.first
          jb.field "u_ptag", u_term.ptag.to_str
          jb.field "u_rank", u_term.rank

          jb.field "u_mtime", u_term.mtime
          # jb.field "u_uname", u_term.uname
          jb.field "u_state", u_term.state
        end

        if b_term
          jb.field "b_val", b_term.val.first
          jb.field "b_ptag", b_term.ptag.to_str
          jb.field "b_rank", b_term.rank

          jb.field "b_mtime", b_term.mtime
          jb.field "b_uname", b_term.uname
          jb.field "b_state", b_term.state
        end

        jb.field "h_vals", @val_hints
        jb.field "h_tags", @tag_hints

        h_vals = @val_hints.to_a
        jb.field "h_fval", @first_val || h_vals[1]? || h_vals[0]?
        jb.field "h_ptag", @first_tag || @tag_hints.first?
      end
    end

    private def load_terms
      if @vdict.kind.basic? && (f_term = VpDict.fixture.find(@word))
        add_hints_by_term(f_term)
        return f_term, nil
      elsif node = @vdict.trie.find(@word)
        node.base.try { |term| add_hints_by_term(term) }
        node.privs.each_value { |term| add_hints_by_term(term) }
        return node.base, node.privs["!" + @uname]?
      else
        return nil, nil
      end
    end

    private def fill_hints(term : VpTerm?)
      if @vdict.kind.cvmtl?
        dname = File.basename(@vdict.file, ".tsv")
        fill_tags_for_cvmtl_dicts(dname)
        VpDict.regular.find(@word).try { |x| add_hints_by_term(x) }
        return
      end

      add_hint_from_mtl
      hint_tags_by_word
      add_hints_by_tags
      add_preseed_hints

      return if @first_val || !@vdict.kind.novel?

      if term = VpDict.regular.find(@word)
        @first_val = term.val.first
        @first_tag = term.attr
      else
        @first_val = TextUtil.titleize(@val_hints.first)
        @first_tag = "Nr"
      end
    end

    def add_preseed_hints : Nil
      VpHint.seed_vals.find(@word).try { |x| @val_hints.concat(x) }
      VpHint.seed_tags.find(@word).try { |x| @tag_hints.concat(x) }

      VpHint.user_vals.find(@word).try { |x| @val_hints.concat(x) }
      VpHint.user_tags.find(@word).try { |x| @tag_hints.concat(x) }
    end

    private def add_hints_by_term(term : VpTerm)
      @val_hints.concat(term.val.reject(&.empty?))
      @tag_hints << term.ptag.to_str unless term.attr.empty?

      return unless prev = term._prev
      @val_hints.concat(prev.val.reject(&.empty?))
      @tag_hints << term.ptag.to_str unless term.attr.empty?
    end

    def fill_tags_for_cvmtl_dicts(dname : String)
      case dname
      when "fix_adjts" then @tag_hints << "a" << "b"
      when "fix_verbs" then @tag_hints << "v" << "vi" << "vo"
      when "fix_nouns" then @tag_hints << "n" << "na" << "Nr"
      when "fix_u_zhi" then @tag_hints << "nl" << "al" << "m"
      when "v_compl"   then @tag_hints << "v" << "vi"
      when "v2_objs"   then @tag_hints << "v"
      when "v_group"   then @tag_hints << "vo"
      when "qt_nouns", "qt_verbs", "qt_times"
        @tag_hints << "mq"
      end
    end

    def hint_tags_by_word
      if TlName.is_human?(@word)
        @tag_hints << "Nr"
        @first_tag = "Nr" if @vdict.kind.novel? || !@first_tag
      end

      if TlName.is_affil?(@word)
        @tag_hints << "Na"
        @first_tag ||= "Na" if @vdict.kind.novel? || !@first_tag
      end

      if TlName::ATTRIBUTE.includes?(@word[-1]?) || @word[0]? == '姓'
        @tag_hints << "na"
      end

      @tag_hints << "n" if @vdict.kind.basic?
    end

    def add_hint_from_mtl : Nil
      mt_data = @word_mtl.cv_plain(@word, cap_first: false)
      mtl_val = mt_data.to_s

      @val_hints << mtl_val
      return if mt_data.head.succ?

      mtl_tag = mt_data.head.tag
      return if @vdict.kind.novel? && (mtl_tag.unkn? || mtl_tag.none?)

      @tag_hints << mtl_tag.to_str
      @first_val ||= mtl_val
    end

    def add_hints_by_tags : Nil
      if @tag_hints.includes?("Nr")
        list = @name_mtl.tl_human(@word)
        @val_hints.concat list
        @first_val = list.first if @first_tag == "Nr"
      end

      if @tag_hints.includes?("Na")
        list = @name_mtl.tl_affil(@word)
        @val_hints.concat list
        @first_val ||= list.first if @first_tag == "Na"
      end

      if @tag_hints.includes?("Nz")
        list = @name_mtl.tl_other(@word)
        @val_hints.concat list
      end

      if @tag_hints.includes?("Nw")
        title_val = @name_mtl.tl_name(@word)
        @val_hints << title_val
      end
    end
  end
end
