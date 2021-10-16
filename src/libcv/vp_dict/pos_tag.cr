require "./pos_tag/*"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  {% begin %}
    TYPES = {{ NOUNS + PRONOUNS + NUMBERS + VERBS + ADJTS + AFFIXES + MISCS + UNIQS }}
  {% end %}

  enum Tag
    None; Unkn

    {% for type in TYPES %}
      {{ type[1].id }}
    {% end %}

    Punct
    Auxil

    {% for group in {ADVERBS, PUNCTS, AUXILS, PREPOSES} %}
      {% for type in group %}
      {{ type[0].id }}
      {% end %}
    {% end %}

    def to_str
      {% begin %}
      case self
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
    when .puncts?   then return "w"
    when .auxils?   then return "u"
    when .adverbs?  then return "d"
    when .preposes? then return "p"
    end

    case self
    when .noun? then "-"
    when .unkn? then ""
    else             @tag.to_str
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
    {% for type in TYPES %}
    when {{ type[0] }} then {{ type[1].id }}
    {% end %}
    when "l" then Idiom
    when "j" then Noun
    when "-" then None
    when "z" then Adesc
    else          Unkn
    end
    {% end %}
  end
end

# puts CV::PosTag.from_str("n").to_str
# puts CV::PosTag.from_str("v").to_str
# puts CV::PosTag.from_str("vn").to_str
