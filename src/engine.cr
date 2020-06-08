require "./engine/*"

module Engine
  extend self

  def hanviet(line : String, user = "local", apply_cap = false)
    Convert.cvlit(line, Lexicon.hanviet(user), apply_cap: apply_cap)
  end

  def pinyins(line : String, user = "local", apply_cap = false)
    Convert.cvlit(line, Lexicon.pinyins(user), apply_cap: apply_cap)
  end

  def tradsim(line : String, user = "local")
    Convert.cvraw(line, Lexicon.tradsim(user))
  end

  def cv_title(input : String, dict : String = "tonghop", user : String = "local")
    return input if input.empty?
    Convert.title(input, Lexicon.for_convert(dict, user))
  end

  def cv_plain(input : String, dict : String = "tonghop", user : String = "local")
    return input if input.empty?
    Convert.plain(input, Lexicon.for_convert(dict, user))
  end

  def cv_mixed(lines : Array(String), book : String = "tonghop", user : String = "local", mode : Symbol = :mixed)
    dicts = Lexicon.for_convert(book, user)

    case mode
    when :title
      lines.map { |line| Convert.title(line, dicts) }
    when :plain
      lines.map { |line| Convert.plain(line, dicts) }
    else # :mixed
      lines.map_with_index do |line, idx|
        idx == 0 ? Convert.title(line, dicts) : Convert.plain(line, dicts)
      end
    end
  end

  def upsert(key : String, val : String = "", dict = "tonghop", user = "local")
    case dict
    when "generic"
      # prevent missing translation
      if key.size == 1 && val.empty?
        if item = Lexicon.search_shared(key, "hanviet", user)
          val = item.vals.first
        end
      end

      Lexicon.upsert_shared(key, val, "generic", user, mode: :new_first)
    when "hanviet"
      return if key.size == 1 && val.empty?
      Lexicon.upsert_shared(key, val, "hanviet", user, mode: :new_first)
    when "suggest", "combine", "pinyins", "tradsim"
      Lexicon.upsert_shared(key, val, dict, user, mode: :new_first)
    else
      dict = "tonghop" if dict.empty?
      Lexicon.upsert_unique(key, val, dict, user, mode: :new_first)

      if val.empty?
        Lexicon.upsert_shared(key, val, "combine", user, mode: :keep_new)
      else
        Lexicon.upsert_shared(key, val, "suggest", user, mode: :new_first)
      end
    end
  end

  def lookup(line : String, dict : String = "tonghop", user : String = "local")
    trungviet = Lexicon.trungviet
    cc_cedict = Lexicon.cc_cedict

    special_user, special_root = Lexicon.unique(dict, user)
    generic_user, generic_root = Lexicon.generic(user)

    chars = line.chars
    upto = chars.size - 1
    (0..upto).map do |idx|
      entry = Hash(String, Hash(String, Array(String))).new do |hash, key|
        hash[key] = Hash(String, Array(String)).new do |h, k|
          h[k] = [] of String
        end
      end

      {special_user, special_root, generic_user, generic_root}.each do |dict|
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

  def inquire(term : String, dict : String = "tonghop", user = "local")
    special = Lexicon.search_unique(term, dict, user)
    generic = Lexicon.search_shared(term, "generic", user)
    suggest, _ = Lexicon.search_shared(term, dict, user)

    suggest.reject! do |x|
      special[0].includes?(x) || generic[0].includes?(x)
    end

    {
      hanviet: hanviet(term).vi_text,
      pinyins: pinyins(term).vi_text,
      special: special,
      generic: generic,
      suggest: suggest,
    }
  end
end
