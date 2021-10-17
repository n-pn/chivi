require "./pos_tag/*"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  {% begin %}
    TYPES = {{ NOUNS + NUMBERS + VERBS + ADJTS + AFFIXES + MISCS }}
  {% end %}

  enum Tag
    None; Unkn

    {% for type in TYPES %}
      {{ type[1].id }}
    {% end %}

    Pronoun; ProPer
    ProDem; ProZhe; ProNa1
    ProInt; ProNa2; ProJi

    Vmodal; VmHui; VmNeng; VmXiang

    Adverb; AdvBu; AdvMei; AdvFei
    Prepos; PreBei; PreDui; PreBa

    Auxil; Punct

    Unique; AdjHao; VShang; VXia; VShi; VYou

    {% for group in {PUNCTS, AUXILS} %}
      {% for type in group %}
      {{ type[0].id }}
      {% end %}
    {% end %}

    def to_str
      {% begin %}
      case self
      when None then "-"
      when Pronoun then "r"
      when ProPer then "rr"
      when Unique then "!"
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

  {% for type in TYPES %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  getter pos : Pos
  getter tag : Tag
  forward_missing_to tag

  def initialize(@tag = Tag::Unkn, @pos = Pos::Contws)
  end

  def to_str
    case @pos
    when .puncts?   then "w"
    when .auxils?   then "u"
    when .adverbs?  then "d"
    when .vmodals?  then "vm"
    when .preposes? then "p"
    when .pro_dems? then "rz"
    when .pro_ints? then "ry"
    when .uniques?  then "!"
    else                 @tag.to_str
    end
  end

  @[AlwaysInline]
  def contws?
    @pos.contws?
  end

  @[AlwaysInline]
  def funcws?
    @pos.funcws?
  end

  def ends?
    none? || puncts? || interjection?
  end

  def self.from_str(tag : ::String, key : ::String = "") : self
    {% begin %}
    case tag
    when "qv" then Verb # quanti verb is handled by code
    when "w" then map_puncts(key)
    when "u" then map_auxils(key)
    when "d" then map_adverbs(key)
    when "p" then map_preposes(key)
    when "vm" then map_vmodals(key)
    when "rz" then map_pro_dems(key)
    when "ry" then map_pro_ints(key)
    when "!" then map_uniques(key)
    when "r" then Pronoun
    when "rr" then ProPer
    when "l" then Idiom
    when "j" then Noun
    when "-" then None
    when "z" then Adesc
    {% for type in TYPES %}
    when {{ type[0] }} then {{ type[1].id }}
    {% end %}
    else          Unkn
    end
    {% end %}
  end
end

# puts CV::PosTag.from_str("n").to_str
# puts CV::PosTag.from_str("v").to_str
# puts CV::PosTag.from_str("vn").to_str
# puts CV::PosTag.from_str("w", "﹑").tag
# puts CV::PosTag.from_str("w", ":").tag
# puts CV::PosTag.from_str("w", "：").tag
# puts CV::PosTag.from_str("vm", "会").tag
# puts CV::PosTag.from_str("u", "着").tag
