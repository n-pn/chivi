require "./engine/convert/*"

module Engine
  extend self

  @@repo = CvRepo.new("data/cv_dicts")

  def hanviet(line : String, user = "local", apply_cap = false)
    CvCore.cv_lit(line, @@repo.hanviet(user), apply_cap: apply_cap)
  end

  def pinyins(line : String, user = "local", apply_cap = false)
    CvCore.cv_lit(line, @@repo.pinyins(user), apply_cap: apply_cap)
  end

  def tradsim(line : String, user = "local")
    CvCore.cv_raw(line, @@repo.tradsim(user))
  end

  def translate(input : String, book : String = "tong-hop", user : String = "local", title : Bool = false)
    return input if input.empty?
    convert(input, book, user, title: title).vi_text
  end

  def translate(input : Array(String), book : String = "tong-hop", user : String = "local", mode : Symbol = :mixed)
    return input if input.empty?
    convert(input, book, user, mode: mode).map(&.vi_text)
  end

  def convert(input : String, book : String = "", user : String = "local", title : Bool = false)
    dicts = @@repo.for_convert(book, user)
    title ? CvCore.cv_title(input, dicts) : CvCore.cv_plain(input, dicts)
  end

  def convert(lines : Array(String), book : String = "tong-hop", user : String = "local", mode : Symbol = :mixed)
    dicts = @@repo.for_convert(book, user)

    case mode
    when :title
      lines.map { |line| CvCore.cv_title(line, dicts) }
    when :plain
      lines.map { |line| CvCore.cv_plain(line, dicts) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? CvCore.cv_title(line, dicts) : CvCore.cv_plain(line, dicts)
      end
    end
  end

  def lookup(line : String, dict : String = "tong-hop", user : String = "local")
    chars = line.chars

    special_root, special_user = @@repo.book(dict, user)
    combine_root, combine_user = @@repo.combine(user)
    generic_root, generic_user = @@repo.generic(user)

    trungviet = @@repo.trungviet
    cc_cedict = @@repo.cc_cedict

    upto = chars.size - 1
    (0..upto).map do |idx|
      entry = Hash(String, Hash(String, Array(String))).new do |hash, key|
        hash[key] = Hash(String, Array(String)).new do |h, k|
          h[k] = [] of String
        end
      end

      {special_user, special_root, combine_user, combine_root, generic_user, generic_root}.each do |dict|
        dict.scan(chars, idx).each do |item|
          words = entry[item.key]["vietphrase"]
          words.concat(item.vals).uniq!
        end
      end

      trungviet.scan(chars, idx).each do |item|
        entry[item.key]["trungviet"] = item.vals
      end

      cc_cedict.scan(chars, idx).each do |item|
        entry[item.key]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].size.-)
    end
  end

  def inquire(word : String, dict : String = "tong-hop", user = "local")
    generic_vals = [] of String
    generic_time = 0_i64

    @@repo.generic(user).each do |dict|
      if item = dict.find(word)
        generic_vals.concat(item.vals)
        if mtime = item.mtime
          generic_time = mtime if generic_time == 0
        end
      end
    end

    special_vals = [] of String
    special_time = 0_i64

    @@repo.book(dict, user).each do |dict|
      if item = dict.find(word)
        special_vals.concat(item.vals)
        if mtime = item.mtime
          special_time = mtime if special_time == 0_i64
        end
      end
    end

    @@repo.combine(user).each do |dict|
      if item = dict.find(word)
        special_vals.concat(item.vals)
        if mtime = item.mtime
          special_time = mtime if special_time == 0_i64
        end
      end
    end

    suggest_vals = [] of String

    @@repo.suggest(user).each do |dict|
      if item = dict.find(word)
        suggest_vals.concat(item.vals)
      end
    end

    if generic_time > 0
      generic_time = CvDict::Item.real_time(generic_time).to_unix_ms
    end

    if special_time > 0
      special_time = CvDict::Item.real_time(special_time).to_unix_ms
    end

    generic_vals.uniq!
    special_vals.uniq!

    suggest_vals.reject! { |x| generic_vals.includes?(x) || special_vals.includes?(x) }

    {
      hanviet: hanviet(word).vi_text,
      pinyins: pinyins(word).vi_text,
      generic: {vals: generic_vals, time: generic_time},
      special: {vals: special_vals, time: special_time},
      suggest: suggest_vals,
    }
  end

  def upsert(key : String, val = "", dict = "tong-hop", user = "local")
    do_upsert(key, val, dict, user, mode: :new_first)

    if val.empty?
      do_upsert(key, val, "combine", user, mode: :keep_new)
    else
      do_upsert(key, val, "suggest", user, mode: :new_first)
    end
  end

  def do_upsert(key : String, val = "", dict = "tong-hop", user = "local", mode = :new_first)
    dict = "generic" if dict.empty?

    case dict
    when "generic", "combine", "suggest"
      # prevent missing translation
      if dict == "generic" && key.size == 1 && val.empty?
        hanviet_root, hanviet_user = @@repo.hanviet
        if hanviet = hanviet_user.find(key) || hanviet_root.find(key)
          val = hanviet.vals.first
        end
      end

      @@repo.core_user[dict, user].set(key, val, mode: mode)
      if user == "local" || user == "admin"
        @@repo.core_root[dict].set(key, val, mode: mode)
      end
    else
      @@repo.book_user[dict, user].set(key, val, mode: mode)
      if user == "local" || user == "admin"
        @@repo.book_root[dict].set(key, val, mode: mode)
      end
    end
  end
end
