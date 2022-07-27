require "log"
require "../mt_node/*"
require "../vp_dict"

module CV::MtDict
  extend self

  alias VxTerm = Tuple(String, PosTag)

  class MtHash < Hash(String, VxTerm)
    getter df_ptag : PosTag

    def initialize(@df_ptag, @fixed_tag = false, initial_capacity = 0)
      super(initial_capacity: initial_capacity)
    end

    def upsert(term : VpTerm)
      return unless fval = term.vals.first?
      return delete(term.key) if fval.empty?
      ptag = @fixed_tag || term.tags[0].empty? ? @df_ptag : term.ptag
      upsert(term.key, {fval, ptag})
    end
  end

  enum Dnames
    FixUZhi; FixAdverbs

    FixNouns; FixVerbs; FixAdjts

    QtTimes; QtVerbs; QtNouns

    VCompl; VGroup; V2Objs
  end

  DICTS = {
    load("fix_u_zhi", PosTag::Nform),
    load("fix_adverbs", PosTag::Adverb),
    load("fix_nouns", PosTag::Noun),
    load("fix_verbs", PosTag::Verb),
    load("fix_adjts", PosTag::Adjt),
    load("qt_times", PosTag::Qttime, true),
    load("qt_verbs", PosTag::Qtverb, true),
    load("qt_nouns", PosTag::Qtnoun, true),
    load("v_compl", PosTag::Verb),
    load("v_group", PosTag::VerbObject),
    load("v2_objs", PosTag::Verb, true),
  }

  def load(dname : String, df_ptag = PosTag::Unkn, fixed_tag = false)
    vpdict = VpDict.load_cvmtl(dname)
    output = MtHash.new(df_ptag, fixed_tag, initial_capacity: vpdict.size)

    vpdict.list.each do |vpterm|
      output.upsert(vpterm) unless vpterm.deleted?
    rescue err
      puts err, vpterm
    end

    output
  end

  def get(dict : String) : MtHash
    DICTS[Dnames.parse(dict).to_i]
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

  def fix_noun!(node : MtTerm) : MtTerm
    if term = get(:fix_nouns)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Noun)
    end
  end

  def fix_verb!(node : MtTerm) : MtTerm
    if term = get(:fix_verbs)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Verb)
    end
  end

  def fix_adjt!(node : MtTerm) : MtTerm
    if term = get(:fix_adjts)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Adjt)
    end
  end

  def fix_adverb!(node : MtTerm) : MtTerm
    if term = get(:fix_adverbs)[node.key]?
      node.set!(term[0], term[1])
    else
      node.set!(PosTag::Adverb)
    end
  end

  def fix_uzhi(node : MtTerm)
    return unless term = get(:fix_u_zhi)[node.key]?
    node.val = term[0]
    term[1]
  end

  def fix_vcompl(node : MtTerm)
    return unless term = get(:v_compl)[node.key]?
    node.set!(term[0], term[1])
  end

  def fix_quanti(node : MtTerm)
    key = node.key

    {get(:qt_times), get(:qt_verbs), get(:qt_nouns)}.each do |hash|
      next unless term = hash[key]?
      return node.set!(term[0], term[1])
    end

    node
  end
end
