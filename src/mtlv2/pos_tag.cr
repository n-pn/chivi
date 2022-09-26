enum MTL::PosTag
  {% for file in ["special", "polysemy"] %}
    {% lines = read_file("#{__DIR__}/pos_tag/#{file.id}.cr").split("\n") %}
    {% for line in lines %}
      {{ line.id }}
    {% end %}
  {% end %}

  def special?
    value < 100
  end

  def polysemy?
    value < 200 && vlue >= 100
  end

  def ambiguous?
    value < 200
  end
end
