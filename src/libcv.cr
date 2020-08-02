require "./libcv/*"

module Libcv
  extend self

  def tradsim(input : String)
    dict = Library.tradsim
    Convert.translit(input, dict, false, false)
  end

  def tradsim(lines : Array(String))
    dict = Library.tradsim
    lines.map { |line| Convert.translit(line, dict, false, false) }
  end

  {% for type in {:hanviet, :binh_am} %}
  def {{type.id}}(input : String, apply_cap = false)
    dict = Library.{{type.id}}
    Convert.translit(input, dict, apply_cap, true)
  end

  def {{type.id}}(lines : Array(String), apply_cap = false)
    dict = Library.{{type.id}}
    lines.map { |line| Convert.translit(line, dict, apply_cap, false) }
  end
  {% end %}

  {% for type in {:title, :plain} %}
  def cv_{{type.id}}(input : String, dname = "_tonghop")
    dicts = Library.for_convert(dname)
    Convert.cv_{{type.id}}(input, *dicts)
  end

  def cv_{{type.id}}(lines : Array(String), dname = "_tonghop")
    dicts = Library.for_convert(dname)
    lines.map { |line| Convert.cv_{{type.id}}(line, *dicts) }
  end
  {% end %}

  def cv_mixed(lines : Array(String), dname = "_tonghop")
    dicts = Library.for_convert(dname)
    res = [Convert.cv_title(lines.first, *dicts)]

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      res << Convert.cv_plain(line, *dicts)
    end

    res
  end
end
