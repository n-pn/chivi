require "sqlite3"

require "./mt_node/mt_term"
require "./pos_tag"

class M1::SpDict
  DB_PATH = "var/mtapp/v1dic/v1_defns.dic"

  def initialize(@df_ptag : PosTag, @fixed_tag = false)
    @hash = Hash(String, {String, PosTag}).new
  end

  def upsert(key : String, val : String, tag : String)
    vals = val.split(/[ǀ|\t]/).map!(&.strip).reject!(&.empty?)

    if val = vals.first?
      tag = @fixed_tag || tag.blank? ? @df_ptag : PosTag.parse(tag: tag, key: key)
      @hash[key] = {val, tag}
    else
      @hash.delete(key)
    end
  end

  def has?(key : String)
    @hash.has_key?(key)
  end

  private def open_db(&)
    DB.open("sqlite3:#{DB_PATH}") { |db| yield db }
  end

  def load!(dict_id : Int32) : self
    sql = <<-SQL
      select key, val, ptag from defns
      where dic = ?
      order by id asc
    SQL

    open_db do |db|
      db.query_each(sql, dict_id) do |rs|
        key, val, tag = rs.read(String, String, String)
        upsert(key, val, tag)
      end
    end

    self
  end

  def fix!(node : MtTerm) : MtTerm
    if term = @hash[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(@df_ptag)
    end
  end

  def fix_uzhi(node : MtTerm) : PosTag?
    return unless term = @hash[node.key]?
    node.val = term[0]
    term[1]
  end

  def fix_vcompl(node : MtTerm)
    return unless term = @hash[node.key]?
    node.set!(term[0], term[1])
  end

  def fix_quanti(node : MtNode)
    return node unless term = @hash[node.key]?
    node.set!(term[0])
  end

  def self.fix_quanti!(node : MtTerm) : MtTerm
    dicts = {self.qt_nouns, self.qt_verbs, self.qt_times}
    dicts.reduce(node) { |memo, dict| dict.fix_quanti(memo) }
  end

  ##########

  class_getter fix_nouns : self { new(PosTag::Noun).load!(-20) }
  class_getter fix_verbs : self { new(PosTag::Verb).load!(-21) }
  class_getter fix_adjts : self { new(PosTag::Adjt).load!(-22) }

  class_getter fix_advbs : self { new(PosTag::Adverb).load!(-23) }
  class_getter fix_u_zhi : self { new(PosTag::Nform).load!(-24) }

  class_getter qt_nouns : self { new(PosTag::Qtnoun, true).load!(-25) }
  class_getter qt_verbs : self { new(PosTag::Qtverb, true).load!(-26) }
  class_getter qt_times : self { new(PosTag::Qttime, true).load!(-27) }

  class_getter v_dircom : self { new(PosTag::Verb, true).load!(-28) }
  class_getter v_rescom : self { new(PosTag::Verb, true).load!(-29) }

  class_getter v_ditran : self { new(PosTag::Verb, true).load!(-30) }
  class_getter verb_obj : self { new(PosTag::VerbObject, true).load!(-31) }
end
