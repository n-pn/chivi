enum CV::MtlTag
  {% for file in {"0-lit+str+punct", "1-name+noun"} %}
    {% lines = read_file("#{__DIR__}/mtl_tag/#{file.id}.cr").split("\n") %}
    {% for line in lines %}
    {{ line.id }}
    {% end %}
  {% end %}
end
