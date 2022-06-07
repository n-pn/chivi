require "log"
require "./mt_node"
require "../vp_dict"

module CV::MtDict
  extend self

  alias MtTerm = Tuple(String, PosTag)

  class MtHash < Hash(String, MtTerm)
    getter df_ptag : PosTag

    def initialize(@df_ptag, @fixed_tag = false, initial_capacity = 0)
      super(initial_capacity: initial_capacity)
    end

    def upsert_term(term : VpTerm)
      return unless fval = term.val.first?
      return delete(term.key) if fval.empty?
      ptag = @fixed_tag || term.attr.empty? ? @df_ptag : term.ptag
      upsert(term.key, {fval, ptag})
    end

    def get_val(key : String)
      self[key]?.try(&.first)
    end
  end

  class_getter fix_u_zhi : MtHash { load("fix_u_zhi", PosTag::NounPhrase, false) }
  class_getter fix_nouns : MtHash { load("fix_nouns", PosTag::Noun, false) }
  class_getter fix_verbs : MtHash { load("fix_verbs", PosTag::Verb, false) }
  class_getter fix_adjts : MtHash { load("fix_adjts", PosTag::Adjt, false) }
  class_getter fix_adverbs : MtHash { load("fix_adverbs", PosTag::Adverb) }

  class_getter qt_times : MtHash { load("qt_times", PosTag::Nqtime) }
  class_getter qt_verbs : MtHash { load("qt_verbs", PosTag::Nqverb) }
  class_getter qt_nouns : MtHash { load("qt_nouns", PosTag::Nqnoun) }

  class_getter verb_com : MtHash { load("verb_com", PosTag::Verb) }
  class_getter verb_dir : MtHash { load("verb_dir", PosTag::VDircomp) }

  class_getter v2_objs : MtHash { load("v2_objs", PosTag::V2Object) }
  class_getter v_group : MtHash { load("v_group", PosTag::VerbObject) }
  class_getter v_combine : MtHash { load("v_combine", PosTag::VCombine) }
  class_getter v_compare : MtHash { load("v_compare", PosTag::VCompare) }

  DICTS = {} of String => MtHash

  def load(dname : String, df_ptag = PosTag::Unkn, fixed_tag = true)
    DICTS[dname] ||= begin
      vpdict = VpDict.load_cvmtl(dname)
      output = MtHash.new(df_ptag, fixed_tag, initial_capacity: vpdict.size)

      vpdict.list.each do |vpterm|
        output.upsert_term(vpterm) unless vpterm.deleted?
      rescue err
        puts err, vpterm
      end

      output
    end
  end

  def upsert(dict : String, term : VpTerm) : Nil
    load(dict).upsert_term(term)
  end

  def fix_noun!(node : MtNode) : MtNode
    if term = self.fix_nouns[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Noun)
    end
  end

  def fix_verb!(node : MtNode) : MtNode
    if term = self.fix_verbs[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Verb)
    end
  end

  def fix_adjt!(node : MtNode) : MtNode
    if term = self.fix_adjts[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Adjt)
    end
  end

  def fix_adverb!(node : MtNode) : MtNode
    if term = self.fix_adverbs[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Adverb)
    end
  end

  def fix_uzhi(node : MtNode)
    return unless term = self.fix_u_zhi[node.key]?
    node.val = term[0]
    term[1]
  end

  def fix_quanti(node : MtNode)
    key = node.key

    {self.qt_times, self.qt_verbs, self.qt_nouns}.each do |hash|
      next unless term = hash[key]?
      return node.set!(term[0], term[1])
    end

    node
  end
end
