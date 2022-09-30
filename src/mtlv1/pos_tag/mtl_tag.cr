enum CV::MtlTag
  {% for file in {"0-lit+str+punct", "1-name+noun", "2-pron+numb", "3-verb+adjt", "4-prep+ptcl"} %}
    {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.cr").split("\n") %}
    {% for line in lines %}
    {{ line.id }}
    {% end %}
  {% end %}

  def puncts?
    value < 50
  end

  def pfinal?
    value >= 4 && value <= 6
  end

  def popens?
    value >= 8 && value < 20
  end

  def pstops?
    value >= 20 && value < 30
  end

  def phrases?
    value >= 60 && value < 100
  end

  def strings?
    value >= 80 && value < 90
  end

  def proper_noun?
    value >= 100 && value < 120
  end

  def common_noun?
    value >= 120 && value < 155
  end

  def honorific?
    value >= 120 && value < 125
  end

  def locative?
    value >= 160 && value < 180
  end

  def timeword?
    value >= 180 && value < 200
  end
end
