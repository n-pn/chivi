require "./pos_tag/*"

# source: https://gist.github.com/luw2007/6016931
# eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
# extra: https://www.cnblogs.com/bushe/p/4635513.html

struct CV::MtlV2::PosTag
  {% begin %}
    TYPES = {{ NOUNS + NOUNS_2 + VERBS + ADJTS + SUFFIXES + MISCS }}
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

    Special; AdjHao

    VShang; VXia

    VShi; VYou

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
  getter sub : Sub
  getter tag : Tag
  forward_missing_to tag

  def initialize(@tag = Tag::Unkn, @pos = Pos::Contws, @sub = Sub::None)
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def to_str
    case @pos
    when .mixed?     then @tag.to_str
    when .puncts?    then "w"
    when .auxils?    then "u"
    when .vmodals?   then "vm"
    when .preposes?  then "p"
    when .pro_dems?  then "rz"
    when .pro_ints?  then "ry"
    when .numbers?   then "m"
    when .quantis?   then "q"
    when .nquants?   then "mq"
    when .adverbial? then "d"
    when .special?
      return "f" if @tag.locative?
      return "!" unless @pos.verbal?
      return "!vshi" if @tag.v_shi?
      return "!vyou" if @tag.v_you?

      case @sub
      when .v2_object? then "!v2"
      when .v_dircomp? then "!vf"
      when .v_combine? then "!vx"
      when .v_compare? then "!vp"
      else                  "!v"
      end
    else @tag.to_str
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
    @tag.naffil? || @tag.nattr? || @tag.position? || @tag.locative?
  end

  @[AlwaysInline]
  def ends?
    @pos.pstops? || @tag.none? || @tag.exclam? || @tag.mopart?
  end

  # ameba:disable Metrics/CyclomaticComplexity
  def self.parse(tag : String, key : String = "") : self
    case tag[0]?
    when nil then Unkn
    when '-' then None
    when 'n' then parse_noun(tag, key)
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
    when 'c' then parse_conjunct(tag, key)
    when '!' then parse_special(tag, key)
    when 'x' then parse_other(tag)
    when '~' then parse_extra(tag)
    when 'b' then Modi
    when 't' then Temporal
    when 's' then Position
    when 'f' then parse_locative(key)
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
