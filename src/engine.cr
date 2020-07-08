require "./engine/cv_dict"
require "./engine/cv_data"

require "./engine/convert"
require "./engine/analyze"

module Engine
  extend self

  def translit(input : String, type = "hanviet", apply_cap = false)
    dict = CvDict.load_shared(type)
    pad_space = type != "tradsim"
    Convert.translit(input, dict, apply_cap, pad_space)
  end

  def translit(lines : Array(String), type = "hanviet", apply_cap = false)
    dict = CvDict.load_shared(type)
    pad_space = type != "tradsim"
    lines.map { |line| Convert.translit(line, dict, apply_cap, pad_space) }
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

  def upsert(dname : String, uname : String, dlock : String, key : String, vals : String = "", extra = "")
    dlog = CvDlog.load_remote(dname)
    dict = CvDict.load_remote(dname)

    dlog.insert(key, dlock) do
      dict.upsert!(key, [vals], extra)
      CvDlog::Item.new(CvDlog::Item.mtime, uname, dlock, key, vals, extra)
    end
  end

  def search(input : String, dname = "generic")
    vals = [] of String
    extra = ""

    mtime = 0
    uname = ""
    dlock = 0

    if node = CvDict.load_remote(dname).find(input)
      vals = node.vals
      extra = node.extra
      dlock = 1
    end

    if dlog = CvDlog.load_remote(dname).find(input)
      vals = dlog.vals.split(CvDict::SEP_1) if vals.empty?
      extra = dlog.extra if extra.empty?

      mtime = dlog.mtime
      uname = dlog.uname
      dlock = dlog.dlock
    end

    {vals: vals, extra: extra, mtime: mtime, uname: uname, dlock: dlock}
  end
end
