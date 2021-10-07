require "./pos_tag/*"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  enum Tag
    None; Unkn

    {% for type in NOUNS + VERBS + ADJTS + NUMBERS + ADVERBS + MISCS + AFFIXES + AUXILS + PUNCTS %}
      {{ type[1].id }}
    {% end %}

    def to_str
      {% begin %}
      case self
      {% for type in NOUNS + VERBS + ADJTS + NUMBERS + ADVERBS + MISCS + AFFIXES + AUXILS + PUNCTS %}
        when {{ type[1].id }} then {{ type[0] }}
      {% end %}
      when None then "-"
      else           ""
      end
      {% end %}
    end
  end

  None = new(Tag::None, Pos::Puncts)
  Unkn = new(Tag::Unkn, Pos::Contws)

  {% for type in NOUNS + VERBS + ADJTS + NUMBERS + ADVERBS + MISCS + AFFIXES + AUXILS + PUNCTS %}
    {{ type[1].id }} = new(Tag::{{type[1].id}}, {{type[2]}})
  {% end %}

  getter pos : Pos
  getter tag : Tag
  forward_missing_to tag

  def initialize(@tag = Tag::Unkn, @pos = Pos::Contws)
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

  def to_str : ::String
    @tag.to_str
  end

  def self.from_str(tag : ::String) : self
    {% begin %}
    case tag
    {% for type in NOUNS + VERBS + ADJTS + NUMBERS + ADVERBS + MISCS + AFFIXES + AUXILS + PUNCTS %}
    when {{ type[0] }} then {{ type[1].id }}
    {% end %}
    when "l" then Idiom
    when "j" then Noun
    when "qv" then Verb # quanti verb is handled by
    # when "z" then Adesc
    when "-" then None
    else          Unkn
    end
    {% end %}
  end
end

# puts CV::PosTag.from_str("n").to_str
# puts CV::PosTag.from_str("v").to_str
# puts CV::PosTag.from_str("vn").to_str
