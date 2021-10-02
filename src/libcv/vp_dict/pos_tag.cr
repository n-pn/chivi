require "./pos_tag/*"

struct CV::PosTag
  # source: https://gist.github.com/luw2007/6016931
  # eng: https://www.lancaster.ac.uk/fass/projects/corpus/ZCTC/annotation.htm
  # extra: https://www.cnblogs.com/bushe/p/4635513.html

  enum Tag
    None; Unkn

    {% for noun in NOUNS %}
    {{ noun[1].id }}
    {% end %}

    {% for verb in VERBS %}
    {{ verb[1].id }}
    {% end %}

    {% for adjt in ADJTS %}
    {{ adjt[1].id }}
    {% end %}

    {% for misc in MISCS %}
    {{ misc[1].id }}
    {% end %}

    {% for auxil in AUXILS %}
    {{ auxil[1].id }}
    {% end %}

    {% for punct in PUNCTS %}
    {{ punct[1].id }}
    {% end %}

    def to_str
      {% begin %}
      case self
      {% for noun in NOUNS %}
      when {{ noun[1].id }} then {{ noun[0] }}
      {% end %}

      {% for verb in VERBS %}
      when {{ verb[1].id }} then {{ verb[0] }}
      {% end %}

      {% for adjt in ADJTS %}
      when {{ adjt[1].id }} then {{ adjt[0] }}
      {% end %}

      {% for misc in MISCS %}
      when {{ misc[1].id }} then {{ misc[0] }}
      {% end %}

      {% for auxil in AUXILS %}
      when {{ auxil[1].id }} then {{ auxil[0] }}
      {% end %}

      {% for puncts in PUNCTS %}
      when {{ puncts[1].id }} then {{ puncts[0] }}
      {% end %}

      when None then "-"
      else           ""
      end
      {% end %}
    end
  end

  None = new(Tag::None, Pos::Puncts)
  Unkn = new(Tag::Unkn, Pos::Contws)

  {% for noun in NOUNS %}
    {{ noun[1].id }} = new(Tag::{{noun[1].id}}, {{noun[2]}})
  {% end %}

  {% for verb in VERBS %}
    {{ verb[1].id }} = new(Tag::{{verb[1].id}}, {{verb[2]}})
  {% end %}

  {% for adjt in ADJTS %}
    {{ adjt[1].id }} = new(Tag::{{adjt[1].id}}, {{adjt[2]}})
  {% end %}

  {% for misc in MISCS %}
    {{ misc[1].id }} = new(Tag::{{misc[1].id}}, {{misc[2]}})
  {% end %}

  {% for auxil in AUXILS %}
    {{ auxil[1].id }} = new(Tag::{{auxil[1].id}}, {{auxil[2]}})
  {% end %}

  {% for puncts in PUNCTS %}
    {{ puncts[1].id }} = new(Tag::{{puncts[1].id}}, {{puncts[2]}})
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

  @[AlwaysInline]
  def pronouns?
    @pos.pronouns?
  end

  @[AlwaysInline]
  def preposes?
    @pos.preposes?
  end

  @[AlwaysInline]
  def strings?
    @pos.strings?
  end

  @[AlwaysInline]
  def numbers?
    @pos.numbers?
  end

  @[AlwaysInline]
  def quantis?
    @pos.quantis?
  end

  def nquants?
    Tag::Number <= @tag <= Tag::Qttime
  end

  def to_str : ::String
    @tag.to_str
  end

  def self.from_str(tag : ::String) : self
    {% begin %}
    case tag

    {% for noun in NOUNS %}
    when {{ noun[0] }} then {{ noun[1].id }}
    {% end %}

    {% for verb in VERBS %}
    when {{ verb[0] }} then {{ verb[1].id }}
    {% end %}

    {% for adjt in ADJTS %}
    when {{ adjt[0] }} then {{ adjt[1].id }}
    {% end %}

    {% for misc in MISCS %}
    when {{ misc[0] }} then {{ misc[1].id }}
    {% end %}

    {% for auxil in AUXILS %}
    when {{ auxil[0] }} then {{ auxil[1].id }}
    {% end %}

    {% for punct in PUNCTS %}
    when {{ punct[0] }} then {{ punct[1].id }}
    {% end %}

    when "z" then Adesc
    when "-" then None
    else          Unkn
    end
    {% end %}
  end
end

# puts CV::PosTag.from_str("n").to_str
# puts CV::PosTag.from_str("v").to_str
# puts CV::PosTag.from_str("vn").to_str
