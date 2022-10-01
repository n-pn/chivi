require "./mtl_pos"
require "./mtl_tag"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  None = new(:lit_blank, :none)
  Unkn = new(:lit_trans, :none)

  # ParenExpr = new(Tag::ParenExpr, :none)
  # Postpos   = new(Tag::Postpos, :none)

  # Quoteop = new(Tag::Quoteop, MtlPos.flags(Popens, Puncts))
  # Quotecl = new(Tag::Quotecl, MtlPos.flags(Pstops, Puncts))

  getter pos : MtlPos
  getter tag : MtlTag
  forward_missing_to tag

  def initialize(@tag : MtlTag = :lit_blank, @pos : MtlPos = :none)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def to_str
    case self
    when .puncts?    then "w"
    when .particles? then "u"
    when .vmodals?   then "vm"
    when .preposes?  then "p"
    when .pro_dems?  then "rz"
    when .pro_ints?  then "ry"
    when .specials?  then "!"
    when .numbers?   then "m"
    when .quantis?   then "q"
    when .nquants?   then "mq"
    when .adverbial?
      @pos.polysemy? ? @tag.to_str : "d"
    else
      @tag.to_str
    end
  end

  def self.parse_prepos(key : ::String)
    case key
    when "把"  then PreBa3
    when "被"  then PreBei
    when "对"  then PreDui
    when "在"  then PreZai
    when "比"  then PreBi3
    when "不比" then PreBi3
    else           Prepos
    end
  end

  def particles?
    tag >= Tag::Auxil && tag <= Tag::Ulian
  end

  # words that can act as noun
  @[AlwaysInline]
  def subject?
    @pos.nominal? || @pos.numeral? || @pos.pronouns? || @tag.verb_object?
  end

  @[AlwaysInline]
  def object?
    @pos.nominal? || @pos.pronouns? || @pos.nquants?
  end

  @[AlwaysInline]
  def property?
    @tag.nlabel? || @tag.nattr? || @tag.posit?
  end

  @[AlwaysInline]
  def ends?
    @pos.puncts? || @pos.none? || @tag.exclam? || @tag.mopart?
  end

  @[AlwaysInline]
  def junction?
    @tag.penum? || @tag.conjunct? || @tag.concoord?
  end

  @[AlwaysInline]
  def verb_no_obj?
    @tag.vintr? || @tag.verb_object?
  end

  @[AlwaysInline]
  def spaces?
    @tag.locat? || @tag.v_shang? || @tag.v_xia?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse(tag : String, key : String = "") : self
    case tag[0]?
    when nil then Unkn
    when '-' then None
    when 'N' then parse_name(tag)
    when 'n' then parse_noun(tag)
    when 'v' then parse_verb(tag, key)
    when 'a' then parse_adjt(tag, key)
    when 'w' then parse_punct(key)
    when 'u' then parse_auxil(key)
    when 'p' then parse_prepos(key)
    when 'd' then parse_adverb(key)
    when 'm' then parse_number(tag, key)
    when 'q' then parse_quanti(key)
    when 'k' then parse_suffix(tag)
    when 'r' then parse_pronoun(tag, key)
    when '!' then parse_special(key)
    when 'x' then parse_other(tag)
    when '~' then parse_extra(tag)
    else          parse_miscs(tag)
    end
  end

  def self.from_numlit(key : String)
    case key
    when /^[0-9０-９]+:[0-9０-９]+(:[0-9０-９]+)*$/,
         /^[0-9０-９]+\/[0-9０-９]+\/[0-9０-９]+$/
      Ntime
    when /^[0-9０-９]+[~\-.][0-9０-９]+$/
      Number
    else
      Litstr
    end
  end
end

# puts CV::PosTag.parse("n").tag
# puts CV::PosTag.parse("na").tag
# puts CV::PosTag.parse("vm", "").tag
# puts CV::PosTag.parse("vd").tag
# puts CV::PosTag.parse("w", "﹑").tag
# puts CV::PosTag.parse("w", ":").tag
# puts CV::PosTag.parse("w", "：").tag
# puts CV::PosTag.parse("vm", "会").tag
# puts CV::PosTag.parse("w", "《").tag
# puts CV::PosTag.parse("w", "“").tag
