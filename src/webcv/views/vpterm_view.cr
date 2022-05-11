require "json"
require "../../libcv/*"

struct CV::VpTermView
  DIR = "var/vphints/detect"

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

  def initialize(@dname, @words, @hvmap, @uname = "")
    @vdict = VpDict.load(@dname)
    @word_mtl = MtCore.load(@dname, @uname)
    @name_mtl = TlName.new(@dname)
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

  # def to_json(jb : JSON::Builder, word : String)
  #   b_term, u_term, h_vals, h_tags, h_fval, h_ptag = load_terms(word)

  #   jb.object do
  #     if u_term
  #       jb.field "u_val", u_term.val.first
  #       jb.field "u_ptag", u_term.ptag.to_str
  #       jb.field "u_rank", u_term.rank

  #       jb.field "u_mtime", u_term.mtime
  #       # jb.field "u_uname", u_term.uname
  #       jb.field "u_state", u_term.state
  #     end

  #     if b_term
  #       jb.field "b_val", b_term.val.first
  #       jb.field "b_ptag", b_term.ptag.to_str
  #       jb.field "b_rank", b_term.rank

  #       jb.field "b_mtime", b_term.mtime
  #       jb.field "b_uname", b_term.uname
  #       jb.field "b_state", b_term.state
  #     end

  #     jb.field "h_vals", h_vals
  #     jb.field "h_fval", h_fval
  #     jb.field "h_tags", h_tags
  #     jb.field "h_ptag", h_ptag
  #   end
  # end

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

    def initialize(@word : String, @uname : String,
                   @vdict : VpDict, hanviet : String,
                   @word_mtl : MtCore, @name_mtl : TlName)
      @val_hints << hanviet

      @df_val = ""
      @df_tag = ""
    end

    def to_json(jb : JSON::Builder)
      b_term, u_term = load_terms

      if @vdict.kind.cvmtl?
        dname = File.basename(@vdict.file, ".tsv")
        fill_tags_for_cvmtl_dicts(dname)
      elsif !@vdict.kind.other? # not hanviet/pin_yin
        add_preseed_hints
        fill_tags_by_word
        add_hints_by_tags
      end

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

        jb.field "h_fval", @val_hints.first
        jb.field "h_ptag", @tag_hints.first
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
      when "fix_nouns" then @tag_hints << "n" << "na" << "nr"
      when "fix_u_zhi" then @tag_hints << "nl" << "al" << "m"
      when "v_compl"   then @tag_hints << "v" << "vi"
      when "v_2_obj"   then @tag_hints << "v"
      when "v_group"   then @tag_hints << "vo"
      when "qt_nouns", "qt_verbs", "qt_times"
        @tag_hints << "q"
      end
    end

    def fill_tags_by_word
      return unless first_char = @word[0]?
      return unless last_char = @word[-1]?

      @tag_hints << "nr" if @vdict.kind.novel? || is_human_name?(first_char, @word[1]?)
      @tag_hints << "nn" if @vdict.kind.novel? || AFFILIATE.includes?(last_char)
      @tag_hints << "na" if ATTRIBUTE.includes?(last_char) || first_char == '姓'
      @tag_hints << "n" if @vdict.kind.basic?
    end

    @[AlwaysInline]
    private def is_human_name?(first_char : Char, last_char : Char?)
      return true if LASTNAMES.includes?(first_char)
      first_char.in?('小', '老') && LASTNAMES.includes?(last_char)
    end

    def add_hints_by_tags : String
      df_val = nil

      if @tag_hints.includes?("nr")
        list = @name_mtl.tl_human(@word)
        @val_hints.concat list
        df_val = list.first
      end

      if @tag_hints.includes?("nn")
        list = @name_mtl.tl_affil(@word)
        @val_hints.concat list
        df_val ||= list.first
      end

      if @tag_hints.includes?("nz")
        list = @name_mtl.tl_other(@word)
        @val_hints.concat list
        df_val ||= list.first
      end

      if @tag_hints.includes?("nx")
        title_val = @name_mtl.tl_name(@word)
        @val_hints << title_val
        df_val ||= title_val
      end

      mt_list = @word_mtl.cv_plain(@word, cap_first: false)
      mtl_val = mt_list.to_s

      @val_hints << mtl_val
      add_tag_hint_by_cvmtl(mt_list)

      df_val || mtl_val
    end

    private def add_tag_hint_by_cvmtl(mt_list : MtList) : Nil
      return if !(first = mt_list.first?) || first.succ?
      ptag = first.tag
      @tag_hints << ptag.to_str unless ptag.none?
    end
  end
end
