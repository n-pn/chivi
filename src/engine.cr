require "./engine/convert/*"

module Engine
  extend self

  @@repo = CvRepo.new("data/cv_dicts")

  def hanviet(input : String, apply_cap = false)
    CvCore.cv_lit(input, @@repo.hanviet, apply_cap: apply_cap)
  end

  def pinyins(input : String, apply_cap = false)
    CvCore.cv_lit(input, @@repo.pinyins, apply_cap: apply_cap)
  end

  def tradsim(input : String)
    CvCore.cv_raw(input, @@repo.tradsim)
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

  alias LookupItem = Tuple(String, String)

  def lookup(line : String, book : String = "tong-hop", user : String = "local")
    chars = line.chars

    if book == "combine" || book.empty?
      special_root, special_user = @@repo.combine(user)
    else
      special_root, special_user = @@repo.book(book, user)
    end

    generic_root, generic_user = @@repo.generic(user)

    dicts = {
      {special_user, "riêng (user)", "; "},
      {special_root, "riêng (base)", "; "},
      {generic_user, "chung (user)", "; "},
      {generic_root, "chung (base)", "; "},
      {@@repo.trungviet, "trungviet", "\n"},
      {@@repo.cc_cedict, "cc_cedict", "\n"},
    }

    entries = (0..chars.size).map do |idx|
      res = Hash(Int32, Array(LookupItem)).new do |h, k|
        h[k] = Array(LookupItem).new
      end

      dicts.each do |dict, name, join|
        dict.scan(chars, idx).each do |item|
          res[item.key.size] << {name, item.vals.join(join)} unless item.vals.empty?
        end
      end

      res.to_a.sort_by(&.[0].-)
    end

    {
      hanviet: hanviet(line, apply_cap: true),
      entries: entries,
    }
  end

  def inquire(key : String, book : String = "tong-hop", user = "local")
    if book.empty?
      special_1, special_2 = @@repo.combine(user)
    else
      special_1, special_2 = @@repo.book(book, user)
    end

    generic_1, generic_2 = @@repo.generic(user)
    suggest_1, suggest_2 = @@repo.suggest(user)

    generic = generic_2.find(key) || generic_1.find(key)
    special = special_2.find(key) || special_1.find(key)
    suggest = suggest_2.find(key) || suggest_1.find(key)

    {
      hanviet: hanviet(key).vi_text,
      pinyins: pinyins(key).vi_text,
      generic: dict_item(generic),
      special: dict_item(special),
      suggest: suggest ? suggest.vals : [] of String,
    }
  end

  private def dict_item(item : CvDict::Item?)
    return {vals: [] of String, time: nil} if item.nil?

    {
      vals: item.vals,
      time: item.time,
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
    when "suggest", "generic", "combine"
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
