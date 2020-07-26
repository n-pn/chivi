require "./dictdb/*"

module DictDB
  extend self

  def apply_logs!(dname : String, mode = :keep_new, save_dict = true)
    edit = DictEdit.load_unsure(dname)
    dict = TrieDict.load_unsure(dname)

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

  def upsert(dname : String, uname : String, power : Int32, key : String, vals : String = "", extra = "")
    edit = DictEdit.load_unsure(dname)
    dict = TrieDict.load_unsure(dname)

    entry = EditData.new(EditData.mtime, uname, power, key, vals, extra)
    raise "power too low" unless edit.insert!(entry)
    raise "power too low" unless power > 0
    dict.upsert!(key, TrieNode.split(vals), extra)
  end

  def search(key : String, dname = "generic")
    mtime = 0
    uname = ""
    power = 0

    vals = [] of String
    extra = ""

    if node = TrieDict.load_unsure(dname).find(key)
      power = 1

      vals = node.vals
      extra = node.extra
    end

    if edit = DictEdit.load_unsure(dname).find(key)
      mtime = edit.mtime
      uname = edit.uname
      power = edit.power

      vals = TrieNode.split(edit.vals) if vals.empty?
      extra = edit.extra if extra.empty?
    end

    mtime = (EditData::EPOCH + mtime.minutes).to_unix_ms
    {vals: vals, extra: extra, mtime: mtime, uname: uname, power: power}
  end
end
