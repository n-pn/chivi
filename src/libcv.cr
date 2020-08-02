require "./libcv/*"

module Libcv
  extend self

  def tradsim(input : String)
    dict = Libcv::Library.tradsim
    Convert.translit(input, dict, false, false)
  end

  def tradsim(lines : Array(String))
    dict = Libcv::Library.tradsim
    lines.map { |line| Convert.translit(line, dict, false, false) }
  end

  def hanviet(input : String, apply_cap = false)
    dict = Libcv::Library.hanviet
    Convert.translit(input, dict, apply_cap, true)
  end

  def hanviet(lines : Array(String), apply_cap = false)
    dict = Libcv::Library.hanviet
    lines.map { |line| Convert.translit(line, dict, apply_cap, false) }
  end

  def binh_am(input : String, apply_cap = false)
    dict = Libcv::Library.binh_am
    Convert.translit(input, dict, apply_cap, true)
  end

  def binh_am(lines : Array(String), apply_cap = false)
    dict = Libcv::Library.binh_am
    lines.map { |line| Convert.translit(line, dict, apply_cap, false) }
  end

  def cv_title(input : String, dname = "combine")
    dicts = Libcv::Library.for_convert(dname)
    Convert.cv_title(input, *dicts)
  end

  def cv_title(lines : Array(String), dname = "combine")
    dicts = Libcv::Library.for_convert(dname)
    lines.map { |line| Convert.cv_title(line, *dicts) }
  end

  def cv_plain(input : String, dname = "combine")
    dicts = Libcv::Library.for_convert(dname)
    Convert.cv_plain(input, *dicts)
  end

  def cv_plain(lines : Array(String), dname = "combine")
    dicts = Libcv::Library.for_convert(dname)
    lines.map { |line| Convert.cv_plain(line, *dicts) }
  end

  def cv_mixed(lines : Array(String), dname = "combine")
    dicts = Libcv::Library.for_convert(dname)
    res = [Convert.cv_title(lines.first, *dicts)]

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      res << Convert.cv_plain(line, *dicts)
    end

    res
  end
end
