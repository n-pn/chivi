require "log"
require "./mt_node"
require "../vp_dict"

module CV::MtDict
  extend self

  alias MtTerm = Tuple(String, PosTag)

  class MtHash < Hash(String, MtTerm)
    getter df_ptag : PosTag

    def initialize(@df_ptag, initial_capacity = 0)
      super(initial_capacity: initial_capacity)
    end

    def upsert(term : VpTerm)
      fval = term.val.first
      return delete(term.key) if fval.empty?
      term.ptag = @df_ptag if term.ptag.unkn?
      upsert(term.key, {fval, term.ptag})
    end
  end

  enum Dnames
    REFINE_NOUNS
    REFINE_VERBS
    REFINE_ADJTS
    QUANTI_NOUNS
    QUANTI_TIMES
    QUANTI_VERBS
    U_ZHI_RIGHTS
    VERBS_2_OBJECTS
    VERBS_SEPERATED
    VERB_COMPLEMENT
  end

  DICTS = {
    load("~refine-nouns", PosTag::Noun),
    load("~refine-verbs", PosTag::Verb),
    load("~refine-adjts", PosTag::Adjt),
    load("~quanti-nouns", PosTag::Qtnoun),
    load("~quanti-times", PosTag::Qttime),
    load("~quanti-verbs", PosTag::Qtverb),
    load("~u_zhi-rights", PosTag::Nform),
    load("~verbs-2-objects", PosTag::Verb),
    load("~verbs-seperated", PosTag::VerbObject),
    load("~verb-complement", PosTag::Verb),
  }

  def load(dname : String, df_ptag = PosTag::Unkn)
    vpdict = VpDict.load(dname)
    output = MtHash.new(df_ptag, initial_capacity: vpdict.size)

    vpdict.data.each do |vpterm|
      output.upsert(vpterm) if vpterm._flag == 0
    end

    output
  end

  def get(dict : String) : MtHash
    DICTS[Dicts.new(dict).to_i]
  end

  def get(dict : Dnames) : MtHash
    DICTS[dict.to_i]
  end

  def has_key?(dict : Dnames, key : String) : Bool
    get(dict).has_key?(key)
  end

  def upsert(hash : MtHash, term : VpTerm) : Nil
    hash.upsert(term)
  end

  def upsert(dict : String, term : VpTerm) : Nil
    get(dict).upsert(term)
  end

  def fix_noun!(node : MtNode) : MtNode
    if term = get(:refine_nouns)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Noun)
    end
  end

  def fix_verb!(node : MtNode) : MtNode
    if term = get(:refine_verbs)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Verb)
    end
  end

  def fix_adjt!(node : MtNode) : MtNode
    if term = get(:refine_adjts)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Adjt)
    end
  end

  def fix_uzhi(node : MtNode)
    return unless term = get(:u_zhi_rights)[node.key]?
    node.val = term[0]
    term[1]
  end

  def fix_vcompl(node : MtNode)
    return unless term = get(:verb_complement)[node.key]?
    node.set!(term[0], term[1])
  end

  def fix_quanti(node : MtNode)
    key = node.key

    {get(:quanti_times), get(:quanti_verbs), get(:quanti_nouns)}.each do |hash|
      next unless term = hash[key]?
      return node.set!(term[0], term[1])
    end

    node
  end
end
