require "./engine/*"

module Engine
  extend self

  @@repo = CvRepo.new("data/dic-out")

  def hanviet(input : String, apply_cap = false)
    CvCore.cv_lit(@@repo.hanviet, input, apply_cap: apply_cap)
  end

  def pinyin(input : String, apply_cap = false)
    CvCore.cv_lit(@@repo.pinyin, input, apply_cap: apply_cap)
  end

  def tradsim(input : String)
    CvCore.cv_raw(@@repo.tradsim, input)
  end

  def translate(input : String, title : Bool, book : String? = nil, user = "local")
    convert(input, title, book, user).vi_text
  end

  def translate(input : Array(String), mode : Symbol, book : String? = nil, user = "local")
    convert(input, mode, book, user).map(&.vi_text)
  end

  def convert(input : String, title = false, book : String? = nil, user = "local")
    dicts = @@repo.for_convert(book, user)
    title ? CvCore.cv_title(dicts, input) : CvCore.cv_plain(dicts, input)
  end

  def convert(lines : Array(String), mode : Symbol, book : String? = nil, user = "local")
    dicts = @@repo.for_convert(book, user)

    case mode
    when :title
      lines.map { |line| CvCore.cv_title(dicts, line) }
    when :plain
      lines.map { |line| CvCore.cv_plain(dicts, line) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? CvCore.cv_title(dicts, line) : CvCore.cv_plain(dicts, line)
      end
    end
  end

  alias LookupItem = Tuple(String, String)

  def lookup(str : String, idx = 0, book : String? = nil, user = "local")
    chars = str.chars

    trungviet = @@repo.trungviet
    cc_cedict = @@repo.cc_cedict

    if book
      special_1, special_2 = @@repo.unique(book, user)
    else
      special_1, special_2 = @@repo.combine(user)
    end

    generic_1, generic_2 = @@repo.generic(user)

    dicts = {
      {special_2, "riêng (#{user})", "; "},
      {special_1, "riêng (hệ thống)", "; "},
      {generic_2, "chung (#{user})", "; "},
      {generic_1, "chung (hệ thống)", "; "},
      {trungviet, "trungviet", "\n"},
      {cc_cedict, "cc_cedict", "\n"},
    }

    # (0..chars.size).map do |idx|
    res = Hash(Int32, Array(LookupItem)).new do |h, k|
      h[k] = Array(LookupItem).new
    end

    dicts.each do |dict, name, join|
      dict.scan(chars, idx).each do |item|
        res[item.key.size] << {name, item.vals.join(join)}
      end
    end

    res.to_a.sort_by(&.[0].-)
    # end
  end

  def inquire(key, book : String? = nil, user = "guest")
    if book
      special_1, special_2 = @@repo.unique(book, user)
    else
      special_1, special_2 = @@repo.combine(user)
    end

    generic_1, generic_2 = @@repo.generic(user)
    suggest_1, suggest_2 = @@repo.suggest(user)

    generic = generic_2.find(key) || generic_1.find(key)
    special = special_2.find(key) || special_1.find(key)
    suggest = suggest_2.find(key) || suggest_1.find(key)

    {
      hanviet: hanviet(key).vi_text,
      pinyins: pinyin(key).vi_text,
      generic: dict_item(generic),
      special: dict_item(special),
      suggest: suggest ? suggest.vals : [] of String,
    }
  end

  private def dict_item(item : CDict::Item?)
    return {value: "", mtime: nil} if item.nil?

    {
      value: item.vals.join(CDict::Item::SEP_1),
      mtime: item.mtime.try(&.to_unix_ms),
    }
  end

  def upsert(key : String, val : String, dic : String? = nil, user : String = "local")
    case dic
    when "generic", nil
      dict = @@repo.common.get_fix("generic", user)
    when "combine"
      dict = @@repo.common.get_fix("generic", user)
    else
      dict = @@repo.unique.get_fix(dic, user)
    end

    # TODO: smart tranfering items
    dict.set(key, val)
  end
end
