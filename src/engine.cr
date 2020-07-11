require "./engine/cv_dict"
require "./engine/cv_data"

require "./engine/convert"
require "./engine/analyze"

module Engine
  extend self

  def tradsim(input : String)
    dict = CvDict.tradsim
    Convert.translit(input, dict, false, false)
  end

  def tradsim(lines : Array(String))
    dict = CvDict.tradsim
    lines.map { |line| Convert.translit(input, dict, false, false) }
  end

  def hanviet(input : String, apply_cap = false)
    dict = CvDict.hanviet
    Convert.translit(input, dict, apply_cap, true)
  end

  def hanviet(lines : Array(String), apply_cap = false)
    dict = CvDict.hanviet
    lines.map { |line| Convert.translit(input, dict, apply_cap, false) }
  end

  def binh_am(input : String, apply_cap = false)
    dict = CvDict.binh_am
    Convert.translit(input, dict, apply_cap, true)
  end

  def binh_am(lines : Array(String), apply_cap = false)
    dict = CvDict.binh_am
    lines.map { |line| Convert.translit(input, dict, apply_cap, false) }
  end

  def cv_title(input : String, dname = "combine")
    dicts = CvDict.for_convert(dname)
    Convert.cv_title(input, *dicts)
  end

  def cv_title(lines : Array(String), dname = "combine")
    dicts = CvDict.for_convert(dname)
    lines.map { |line| Convert.cv_title(line, *dicts) }
  end

  def cv_plain(input : String, dname = "combine")
    dicts = CvDict.for_convert(dname)
    Convert.cv_plain(input, *dicts)
  end

  def cv_plain(lines : Array(String), dname = "combine")
    dicts = CvDict.for_convert(dname)
    lines.map { |line| Convert.cv_plain(line, *dicts) }
  end

  def cv_mixed(lines : Array(String), dname = "combine")
    dicts = CvDict.for_convert(dname)
    output = [Convert.cv_title(lines.first, *dicts)]

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      output << Convert.cv_plain(line, *dicts)
    end

    output
  end

  def apply_logs!(dname : String, mode = :keep_new, save_dict = true)
    dlog = CvDlog.load_remote(dname)
    dict = CvDict.load_remote(dname)
    dlog.best.each_value do |log|
      dict.update(key) do |node|
        node.extra = log.extra

        vals = log.vals.split(CvDict::SEP_1)
        if node.vals.empty? || mode == :keep_new
          node.vals = vals
        elsif mode == :new_first
          node.vals = vals.concat(node.vals)
        else
          node.vals.concat(vals)
        end
      end
    end

    dict.save! if save_dict
  end

  def upsert(dname : String, uname : String, power : String, key : String, vals : String = "", extra = "")
    dlog = CvDlog.load_remote(dname)
    dict = CvDict.load_remote(dname)

    dlog.insert(key, power) do
      dict.upsert!(key, CvDict::Node.split(vals), extra)
      CvDlog::Item.new(CvDlog::Item.mtime, uname, power, key, vals, extra)
    end
  end

  def search(key : String, dname = "generic")
    mtime = 0
    uname = ""
    power = 0

    vals = [] of String
    extra = ""

    if node = CvDict.load_remote(dname).find(key)
      power = 1

      vals = node.vals
      extra = node.extra
    end

    if dlog = CvDlog.load_remote(dname).find(key)
      mtime = dlog.mtime
      uname = dlog.uname
      power = dlog.power

      vals = CvDict::Node.split(dlog.vals) if vals.empty?
      extra = dlog.extra if extra.empty?
    end

    {vals: vals, extra: extra, mtime: mtime, uname: uname, power: power}
  end
end
