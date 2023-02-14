require "json"

require "../data/v1_defn"
require "../core/m1_dict"
# require "../core/tl_name"
require "../core/vp_hint"

struct M1::M1TermView
  DIR = "var/vhint/detect"

  getter defns : Hash(String, Array(DbDefn))

  def initialize(@words : Array(String), @uname : String, @wn_id : Int32)
    @defns = DbDefn.repo.open_db do |db|
      sql = String.build do |str|
        str << "select * from defns where dic in (#{wn_id}, -1, -2, -3)"
        str << "and _flag >= 0 and key in ("
        words.join(str, ",") { |_, s| s << '?' }
        str << ")"
      end

      db.query_all(sql, args: words, as: DbDefn).group_by(&.key)
    end

    # @vdict = MtDict.load(@dname)
    # @word_mtl = MtCore.load(@dname, @user)
    # @name_mtl = TlName.new(@vdict)
  end

  def to_json(jb : JSON::Builder)
    jb.object do
      @words.each do |word|
        jb.field(word) {
          entries = @defns[word]? || [] of DbDefn
          entries.sort_by! { |e| {-e.dic, -e.tab, -e.mtime} }

          hanviet = MtCore.cv_hanviet(word, false)

          tag_hints = entries.map(&.ptag)
          tag_hints.concat(gen_tag_hints(word)).uniq!

          val_hints = entries.flat_map(&.val.split('ǀ'))
          val_hints.concat(gen_val_hints(word, tag_hints)).uniq!

          jb.object {
            jb.field "current", extract_current(entries)
            # jb.field "entries" { jb.array { entries.each(&.to_json(jb)) } }

            jb.field "hanviet", hanviet
            jb.field "pin_yin", MtCore.cv_pin_yin(word)

            jb.field "val_hints", val_hints
            jb.field "tag_hints", tag_hints
          }
        }
      end
    end
  end

  private def extract_current(entries : Array(DbDefn))
    return if entries.empty?

    groups = entries.group_by(&.dic)

    terms = groups[@wn_id]? || groups[-3]? || groups[-1]? || groups[-2]
    terms.find(&.uname.== @uname) || terms.first
  end

  private def gen_tag_hints(word : String)
    [] of String
  end

  private def gen_val_hints(word : String, tags : Array(String))
    [] of String
  end

  # private def add_hints(entry : TermView) : Nil
  #   # entry.add_hints_from_mtl(@word_mtl)
  #   entry.hints_tags_by_word
  #   # entry.hints_vals_by_tags(@name_mtl)
  #   entry.add_hint_from_regular_dict
  #   entry.add_preseed_hints
  # end

  # class TermView
  #   getter val_hints = Set(String).new
  #   getter tag_hints = Set(String).new

  #   @first_val : String? = nil
  #   @first_tag : String? = nil

  #   def initialize(@word : String, @vdict : MtDict, hanviet : String)
  #     @val_hints << hanviet
  #   end

  #   def get_active_term(with_user : String = "", with_temp : Bool = false) : VpTerm?
  #     return unless node = @vdict.trie.find(@word)

  #     if term = node.base
  #       add_hints_by_term(term)
  #     end

  #     if temp = node.temp
  #       add_hints_by_term(temp)
  #       term = temp if with_temp
  #     end

  #     node.privs.each_value do |user|
  #       add_hints_by_term(user)
  #       term = user if user.uname == with_user
  #     end

  #     term
  #   end

  #   def add_hints_by_term(term : VpTerm)
  #     @val_hints.concat(term.vals.reject(&.empty?))
  #     @tag_hints << term.ptag.to_str unless term.ptag.unkn?

  #     return unless prev = term._prev
  #     @val_hints.concat(prev.vals.reject(&.empty?))
  #     @tag_hints << term.ptag.to_str unless term.ptag.unkn?
  #   end

  #   def add_hints_from_mtl(word_mtl : MtCore) : Nil
  #     mt_data = word_mtl.cv_plain(@word, cap_first: false)
  #     mtl_val = mt_data.to_txt

  #     @val_hints << mtl_val

  #     head = mt_data.head.succ
  #     return if head.succ?

  #     mtl_tag = head.tag
  #     return if @vdict.kind.novel? && (mtl_tag.unkn? || mtl_tag.none?)

  #     @tag_hints << mtl_tag.to_str
  #     @first_val ||= mtl_val
  #   end

  #   def hints_tags_by_word
  #     if TlName.is_human?(@word)
  #       @tag_hints << "Nr"
  #       @first_tag = "Nr" if @vdict.kind.novel? || !@first_tag
  #     end

  #     if TlName.is_affil?(@word)
  #       @tag_hints << "Na"
  #       @first_tag ||= "Na" if @vdict.kind.novel? || !@first_tag
  #     end

  #     if TlName::ATTRIBUTE.includes?(@word[-1]?) || @word[0]? == '姓'
  #       @tag_hints << "na"
  #     end

  #     @tag_hints << "n" if @vdict.kind.basic?
  #   end

  #   def hints_vals_by_tags(name_mtl : TlName) : Nil
  #     if @tag_hints.includes?("Nr")
  #       list = name_mtl.tl_human(@word)
  #       @val_hints.concat list
  #       @first_val = list.first if @first_tag == "Nr"
  #     end

  #     if @tag_hints.includes?("Na")
  #       list = name_mtl.tl_affil(@word)
  #       @val_hints.concat list
  #       @first_val ||= list.first if @first_tag == "Na"
  #     end

  #     if @tag_hints.includes?("Nz")
  #       list = name_mtl.tl_other(@word)
  #       @val_hints.concat list
  #     end

  #     if @tag_hints.includes?("Nw")
  #       title_val = name_mtl.tl_name(@word)
  #       @val_hints << title_val
  #     end
  #   end

  #   def add_hint_from_regular_dict
  #     return if @first_val || !@vdict.kind.novel?

  #     if term = MtDict.regular.find(@word)
  #       @first_val = term.vals.first
  #       @first_tag = term.tags.first
  #     else
  #       @first_val = TextUtil.titleize(@val_hints.first)
  #       @first_tag = "Nr"
  #     end
  #   end

  #   def add_preseed_hints : Nil
  #     VpHint.seed_vals.find(@word).try { |x| @val_hints.concat(x) }
  #     VpHint.seed_tags.find(@word).try { |x| @tag_hints.concat(x) }

  #     VpHint.user_vals.find(@word).try { |x| @val_hints.concat(x) }
  #     VpHint.user_tags.find(@word).try { |x| @tag_hints.concat(x) }
  #   end

  #   def to_json(jb : JSON::Builder, term : VpTerm?)
  #     jb.object do
  #       if term
  #         jb.field "vals", term.vals
  #         jb.field "tags", term.tags
  #         jb.field "prio", term.prio_str

  #         jb.field "mtime", term.utime
  #         jb.field "uname", term.uname
  #         jb.field "state", term.state

  #         jb.field "_mode", term._mode
  #       end

  #       jb.field "h_vals", @val_hints
  #       jb.field "h_tags", @tag_hints

  #       h_vals = @val_hints.to_a
  #       jb.field "h_fval", @first_val || h_vals[1]? || h_vals[0]? || ""
  #       jb.field "h_ftag", @first_tag || @tag_hints.first? || ""
  #     end
  #   end
  # end
end
