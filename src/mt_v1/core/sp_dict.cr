require "sqlite3"

require "./mt_node/mt_term"
require "./pos_tag"

class M1::SpDict
  DB_PATH = "/srv/chivi/mt_db/v1_defns.db3"

  LOAD_SQL = <<-SQL
    select zstr, vstr, ptag from defns
    where d_id = $1 and vstr <> ''
  SQL

  @hash = Hash(String, {String, PosTag}).new

  def initialize(d_id : Int32, @df_ptag : PosTag, @fixed_tag = false)
    DB.open("sqlite3:#{DB_PATH}") do |db|
      db.query_each(LOAD_SQL, d_id) do |rs|
        zstr, vstr, ptag = rs.read(String, String, String)

        ptag = @fixed_tag || ptag.blank? ? @df_ptag : PosTag.parse(tag: ptag, key: zstr)
        @hash[zstr] = {vstr, ptag}
      end
    end
  end

  @[AlwaysInline]
  def has?(key : String)
    @hash.has_key?(key)
  end

  def fix!(node : MtDefn) : MtDefn
    if term = @hash[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(@df_ptag)
    end
  end

  def fix_uzhi(node : MtDefn) : PosTag?
    return unless term = @hash[node.key]?
    node.val = term[0]
    term[1]
  end

  def fix_vcompl(node : MtDefn)
    return unless term = @hash[node.key]?
    node.set!(term[0], term[1])
  end

  def fix_quanti(node : MtNode)
    return node unless term = @hash[node.key]?
    node.set!(term[0])
  end

  def self.fix_quanti!(node : MtDefn) : MtDefn
    dicts = {self.qt_nouns, self.qt_verbs, self.qt_times}
    dicts.reduce(node) { |memo, dict| dict.fix_quanti(memo) }
  end

  ##########

  class_getter fix_nouns : self { new(-20, PosTag::Noun) }
  class_getter fix_verbs : self { new(-21, PosTag::Verb) }
  class_getter fix_adjts : self { new(-22, PosTag::Adjt) }

  class_getter fix_advbs : self { new(-23, PosTag::Adverb) }
  class_getter fix_u_zhi : self { new(-24, PosTag::Nform) }

  class_getter qt_nouns : self { new(-25, PosTag::Qtnoun, fixed_tag: true) }
  class_getter qt_verbs : self { new(-26, PosTag::Qtverb, fixed_tag: true) }
  class_getter qt_times : self { new(-27, PosTag::Qttime, fixed_tag: true) }

  class_getter v_dircom : self { new(-28, PosTag::Verb, fixed_tag: true) }
  class_getter v_rescom : self { new(-29, PosTag::Verb, fixed_tag: true) }

  class_getter v_ditran : self { new(-30, PosTag::Verb, fixed_tag: true) }
  class_getter verb_obj : self { new(-31, PosTag::VerbObject, fixed_tag: true) }
end
