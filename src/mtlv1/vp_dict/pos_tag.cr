require "./pos_tag/*"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  {% begin %}
    TYPES = {{ NOUNS + NAMES + VERBS + ADJTS + SUFFIXES + MISCS }}
  {% end %}

  enum Tag
    None; Unkn

    {% for type in TYPES %}
      {{ type[1].id }}
    {% end %}

    ProUkn; ProPer
    ProDem; ProZhe; ProNa1
    ProInt; ProNa2; ProJi

    Vmodal; VmHui; VmNeng; VmXiang

    Adverb; AdvBu4; AdvMei; AdvFei
    AdvNoun; AdvUniq

    Prepos; PreBei; PreDui; PreZai; PreBa3; PreBi3

    Number; Ndigit; Nhanzi
    Qtnoun; Qttime; Qtverb
    Nqnoun; Nqtime; Nqverb; Nqiffy

    Auxil; Punct

    Special; AdjHao; VShang; VXia; VShi; VYou

    {% for type in PUNCTS %}
      {{ type[0].id }}
    {% end %}

    {% for type in AUXILS %}
      {{ type[0].id }}
    {% end %}

    def to_str
      {% begin %}
      case self
      when None then "-"
      when ProPer then "rr"
      when ProUkn then "r"
      when Special then "!"
      {% for type in TYPES %}
        when {{ type[1].id }} then {{ type[0] }}
      {% end %}
      else ""
      end
      {% end %}
    end
  end

  None = new(Tag::None, Pos::Puncts)
  Unkn = new(Tag::Unkn, Pos::Contws)

  getter pos : Pos
  getter tag : Tag
  forward_missing_to tag

  def initialize(@tag = Tag::Unkn, @pos = Pos::Contws)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def to_str
    case @pos
    when .puncts?   then "w"
    when .auxils?   then "u"
    when .vmodals?  then "vm"
    when .preposes? then "p"
    when .pro_dems? then "rz"
    when .pro_ints? then "ry"
    when .specials? then "!"
    when .numbers?  then "m"
    when .quantis?  then "q"
    when .nquants?  then "mq"
    when .adverbial?
      @pos.mixed? ? @tag.to_str : "d"
    else
      @tag.to_str
    end
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
    @tag.naffil? || @tag.nattr? || @tag.posit?
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
