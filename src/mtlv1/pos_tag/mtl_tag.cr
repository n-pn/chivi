enum CV::MtlTag
  {% for file in {"0-lit+str+punct", "1-name+noun", "2-pron+numb"} %}
    {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.cr").split("\n") %}
    {% for line in lines %}
    {{ line.id }}
    {% end %}
  {% end %}

  def human_name?
    @tag >= Human0 && @tag <= Human6
  end

  def affil_name?
    @tag >= Affil0 && @tag <= Affil5
  end

  def other_name?
    @tag >= Xother && @tag <= XSkill
  end
end
