require "./engine/*"

module Engine
  extend self

  def tradsim(input : String)
    dict = Library.tradsim
    Convert.tokenize(input.chars, dict)
  end

  def tradsim(lines : Array(String))
    dict = Library.tradsim
    lines.map { |line| Convert.tokenize(line.chars, dict) }
  end

  def binh_am(input : String, apply_cap = false)
    dict = Library.binh_am
    Convert.translit(input, dict, apply_cap)
  end

  def binh_am(lines : Array(String), apply_cap = false)
    dict = Library.binh_am
    lines.map { |line| Convert.translit(line, dict, apply_cap) }
  end

  def hanviet(input : String, apply_cap = true)
    dict = Library.hanviet.dict
    Convert.translit(input, dict, apply_cap)
  end

  def hanviet(lines : Array(String), apply_cap = true)
    dict = Library.hanviet.dict
    lines.map { |line| Convert.translit(line, dict, apply_cap) }
  end

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
