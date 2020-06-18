require "./engine/*"

module Engine
  extend self

  def hanviet(line : String, user = "local", apply_cap = false)
    dicts = Lexicon.shared("hanviet", user)
    Convert.cvlit(line, dicts, apply_cap: apply_cap)
  end

  def hanviet(lines : Array(String), user = "local", apply_cap = false)
    dicts = Lexicon.shared("hanviet", user)
    lines.map { |line| Convert.cvlit(line, dicts, apply_cap: apply_cap) }
  end

  def pinyins(line : String, user = "local", apply_cap = false)
    dicts = Lexicon.shared("pinyins", user)
    Convert.cvlit(line, dicts, apply_cap: apply_cap)
  end

  def pinyins(lines : Array(String), user = "local", apply_cap = false)
    dicts = Lexicon.shared("pinyins", user)
    lines.map { |line| Convert.cvlit(line, dicts, apply_cap: apply_cap) }
  end

  def tradsim(line : String, user = "local")
    dicts = Lexicon.get_shared("tradsim", user)
    Convert.cvraw(line, dicts)
  end

  def tradsim(lines : Array(String), user = "local")
    dicts = Lexicon.shared("tradsim", user)
    lines.map { |line| Convert.cvraw(line, dicts) }
  end

  def cv_title(input : String, dict : String = "tonghop", user : String = "local")
    return input if input.empty?
    Convert.title(input, Lexicon.for_convert(dict, user))
  end

  def cv_title(lines : Array(String), dict : String = "tonghop", user : String = "local")
    return lines if lines.empty?
    dicts = Lexicon.for_convert(dict, user)
    lines.map { |line| Convert.title(line, dicts) }
  end

  def cv_plain(input : String, dict : String = "tonghop", user : String = "local")
    return input if input.empty?
    dicts = Lexicon.for_convert(dict, user)
    Convert.plain(input, dicts)
  end

  def cv_plain(lines : Array(String), dict : String = "tonghop", user : String = "local")
    return lines if lines.empty?
    dicts = Lexicon.for_convert(dict, user)
    lines.map { |line| Convert.plain(line, dicts) }
  end

  def cv_mixed(lines : Array(String), dict : String = "tonghop", user : String = "local")
    return lines if lines.empty?
    dicts = Lexicon.for_convert(dict, user)

    lines.map_with_index do |line, idx|
      idx == 0 ? Convert.title(line, dicts) : Convert.plain(line, dicts)
    end
  end

  def upsert(key : String, val : String = "", dict = "tonghop", user = "local")
    sync = user == "admin"

    case dict
    when "suggest", "combine", "pinyins", "tradsim", "hanviet"
      Lexicon.shared(dict, user).upsert(key, val, sync: sync)
    when "generic"
      # prevent missing translation
      if key.size == 1 && val.empty?
        if item = Lexicon.shared("hanviet", user).find(key)
          val = item.vals.first
        end
      end

      Lexicon.shared("generic", user).upsert(key, val, sync: sync)
    else
      dict = "tonghop" if dict.empty?
      Lexicon.unique(dict, user).upsert(key, val, sync: sync)

      unless val.empty?
        Lexicon.shared("suggest", user).upsert(key, val, sync: sync)
      end
    end
  end

  def lookup(line : String, dict : String = "tonghop", user : String = "local")
    trungviet = Lexicon.trungviet
    cc_cedict = Lexicon.cc_cedict

    special = Lexicon.unique(dict, user)
    generic = Lexicon.shared("generic", user)

    chars = line.chars
    upper = chars.size - 1

    (0..upper).map do |idx|
      entry = Hash(String, Hash(String, Array(String))).new do |hash, key|
        hash[key] = Hash(String, Array(String)).new do |h, k|
          h[k] = [] of String
        end
      end

      special.scan(chars, idx).each do |item|
        entry[item.key]["vietphrase"].concat(item.vals).uniq!
      end

      generic.scan(chars, idx).each do |item|
        entry[item.key]["vietphrase"].concat(item.vals).uniq!
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
    special = Lexicon.unique(dict, user).search(term)
    generic = Lexicon.shared("generic", user).search(term)
    suggest, _ = Lexicon.shared(dict, user).search(term)

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
