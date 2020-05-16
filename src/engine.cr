require "./engine/*"

module Engine
  extend self

  @@repo = CvRepo.new("data/cv_dicts")

  def hanviet(input : String, apply_cap = false)
    CvCore.cv_lit([@@repo.hanviet], input, apply_cap: apply_cap)
  end

  def pinyins(input : String, apply_cap = false)
    CvCore.cv_lit([@@repo.pinyins], input, apply_cap: apply_cap)
  end

  def tradsim(input : String)
    CvCore.cv_raw([@@repo.tradsim], input)
  end

  def translate(input : String, title : Bool, book : String? = nil, user = "guest")
    return input if input.empty?
    convert(input, title, book, user).vi_text
  end

  def translate(input : Array(String), mode : Symbol, book : String? = nil, user = "guest")
    return input if input.empty?
    convert(input, mode, book, user).map(&.vi_text)
  end

  def convert(input : String, title = false, book : String? = nil, user = "guest")
    dicts = @@repo.for_convert(book, user)
    title ? CvCore.cv_title(dicts, input) : CvCore.cv_plain(dicts, input)
  end

  def convert(lines : Array(String), mode : Symbol, book : String? = nil, user = "guest")
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

  def lookup(str : String, dic : String? = nil, user = "guest")
    chars = str.chars

    if dic
      special_base = @@repo.unique_base[dic]
      special_user = @@repo.unique_user[dic, user]
    else
      special_base = @@repo.shared_base["combine"]
      special_user = @@repo.shared_user["combine", user]
    end

    generic_user = @@repo.shared_user["generic", user]
    generic_base = @@repo.shared_base["generic"]

    dicts = {
      {special_user, "riêng (user)", "; "},
      {special_base, "riêng (base)", "; "},
      {generic_user, "chung (user)", "; "},
      {generic_base, "chung (base)", "; "},
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
      hanviet: hanviet(str, apply_cap: true),
      entries: entries,
    }
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

  def upsert(key : String, val : String, dic : String? = nil, user : String = "guest")
    upsert({key => val}, dic, user)
  end

  def upsert(entries : Hash(String, String), dic : String? = nil, user : String = "guest")
    case dic
    when "generic", nil
      dict = @@repo.shared_user["generic", user]
    when "combine"
      dict = @@repo.shared_user["combine", user]
    else
      dict = @@repo.unique_user[dic, user]
    end

    entries.each do |key, val|
      @@repo.shared_user["suggest", user].set(key, val)
      dict.set(key, val)
    end
  end
end
