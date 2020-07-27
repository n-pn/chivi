require "./dictdb/user_dict"
require "./dictdb/base_dict"

require "./engine/convert"
require "./engine/analyze"

module Engine
  extend self

  def tradsim(input : String)
    dict = BaseDict.tradsim
    Convert.translit(input, dict, false, false)
  end

  def tradsim(lines : Array(String))
    dict = BaseDict.tradsim
    lines.map { |line| Convert.translit(line, dict, false, false) }
  end

  def hanviet(input : String, apply_cap = false)
    dict = BaseDict.hanviet
    Convert.translit(input, dict, apply_cap, true)
  end

  def hanviet(lines : Array(String), apply_cap = false)
    dict = BaseDict.hanviet
    lines.map { |line| Convert.translit(line, dict, apply_cap, false) }
  end

  def binh_am(input : String, apply_cap = false)
    dict = BaseDict.binh_am
    Convert.translit(input, dict, apply_cap, true)
  end

  def binh_am(lines : Array(String), apply_cap = false)
    dict = BaseDict.binh_am
    lines.map { |line| Convert.translit(line, dict, apply_cap, false) }
  end

  def cv_title(input : String, dname = "combine")
    dicts = BaseDict.for_convert(dname)
    Convert.cv_title(input, *dicts)
  end

  def cv_title(lines : Array(String), dname = "combine")
    dicts = BaseDict.for_convert(dname)
    lines.map { |line| Convert.cv_title(line, *dicts) }
  end

  def cv_plain(input : String, dname = "combine")
    dicts = BaseDict.for_convert(dname)
    Convert.cv_plain(input, *dicts)
  end

  def cv_plain(lines : Array(String), dname = "combine")
    dicts = BaseDict.for_convert(dname)
    lines.map { |line| Convert.cv_plain(line, *dicts) }
  end

  def cv_mixed(lines : Array(String), dname = "combine")
    dicts = BaseDict.for_convert(dname)
    output = [Convert.cv_title(lines.first, *dicts)]

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      output << Convert.cv_plain(line, *dicts)
    end

    output
  end
end
