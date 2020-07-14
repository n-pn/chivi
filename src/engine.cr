require "./dictdb/dict_edit"
require "./dictdb/trie_dict"

require "./engine/convert"
require "./engine/analyze"

module Engine
  extend self

  def tradsim(input : String)
    dict = TrieDict.tradsim
    Convert.translit(input, dict, false, false)
  end

  def tradsim(lines : Array(String))
    dict = TrieDict.tradsim
    lines.map { |line| Convert.translit(input, dict, false, false) }
  end

  def hanviet(input : String, apply_cap = false)
    dict = TrieDict.hanviet
    Convert.translit(input, dict, apply_cap, true)
  end

  def hanviet(lines : Array(String), apply_cap = false)
    dict = TrieDict.hanviet
    lines.map { |line| Convert.translit(input, dict, apply_cap, false) }
  end

  def binh_am(input : String, apply_cap = false)
    dict = TrieDict.binh_am
    Convert.translit(input, dict, apply_cap, true)
  end

  def binh_am(lines : Array(String), apply_cap = false)
    dict = TrieDict.binh_am
    lines.map { |line| Convert.translit(input, dict, apply_cap, false) }
  end

  def cv_title(input : String, dname = "combine")
    dicts = TrieDict.for_convert(dname)
    Convert.cv_title(input, *dicts)
  end

  def cv_title(lines : Array(String), dname = "combine")
    dicts = TrieDict.for_convert(dname)
    lines.map { |line| Convert.cv_title(line, *dicts) }
  end

  def cv_plain(input : String, dname = "combine")
    dicts = TrieDict.for_convert(dname)
    Convert.cv_plain(input, *dicts)
  end

  def cv_plain(lines : Array(String), dname = "combine")
    dicts = TrieDict.for_convert(dname)
    lines.map { |line| Convert.cv_plain(line, *dicts) }
  end

  def cv_mixed(lines : Array(String), dname = "combine")
    dicts = TrieDict.for_convert(dname)
    output = [Convert.cv_title(lines.first, *dicts)]

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      output << Convert.cv_plain(line, *dicts)
    end

    output
  end

  def apply_logs!(dname : String, mode = :keep_new, save_dict = true)
    edit = DictEdit.load_remote(dname)
    dict = TrieDict.load_remote(dname)

    edit.best.each_value do |log|
      dict.update(key) do |node|
        node.extra = log.extra

        vals = log.vals.split(TrieDict::SEP_1)
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
    edit = DictEdit.load_remote(dname)
    dict = TrieDict.load_remote(dname)

    edit.insert(key, power) do
      dict.upsert!(key, TrieDict::Node.split(vals), extra)
      DictEdit::Edit.new(DictEdit::Edit.mtime, uname, power, key, vals, extra)
    end
  end

  def search(key : String, dname = "generic")
    mtime = 0
    uname = ""
    power = 0

    vals = [] of String
    extra = ""

    if node = TrieDict.load_remote(dname).find(key)
      power = 1

      vals = node.vals
      extra = node.extra
    end

    if edit = DictEdit.load_remote(dname).find(key)
      mtime = edit.mtime
      uname = edit.uname
      power = edit.power

      vals = TrieDict::Node.split(edit.vals) if vals.empty?
      extra = edit.extra if extra.empty?
    end

    {vals: vals, extra: extra, mtime: mtime, uname: uname, power: power}
  end
end
