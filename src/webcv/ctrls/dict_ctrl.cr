require "./base_ctrl"

class CV::DictCtrl < CV::BaseCtrl
  def index
    res = [] of Tuple(String, String, Int32) # dict name, dict type, entries count

    res << {"regular", "system", Vdict.regular.size}
    res << {"hanviet", "system", Vdict.hanviet.size}

    limit = params.fetch_int("limit", min: 50, max: 100)
    offset = params.fetch_int("offset")

    # TODO: display book names
    Vdict.udicts[offset, limit].each do |dname|
      res << {dname, "unique", Vdict.load(dname).size}
    end

    render_json(res)
  end

  def show
    dname = params["dname"]
    vdict = Vdict.load(dname)

    limit = params.fetch_int("limit", min: 50, max: 100)
    offset = params.fetch_int("offset")

    res = [] of VpTerm

    filter = VpTrie::Filter.init(params.to_unsafe_h)

    vdict.each do |node|
      next unless filter.match?(node)

      if offset > 0
        offset -= 1
      else
        res << node
        break if res.size >= limit
      end
    end

    render_json(res)
  end

  alias Lookup = Hash(String, Array(String))

  def lookup
    dname = params["dname"]
    input = params["input"].strip

    dicts = {Vdict.load(dname), Vdict.regular}
    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, Lookup).new do |hash, key|
        hash[key] = Lookup.new { |h, k| h[k] = [] of String }
      end

      dicts.each do |dict|
        dict.scan(chars, idx) do |item|
          entry[item.key.size]["vietphrase"].concat(item.vals).uniq!
        end
      end

      Vdict.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      Vdict.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Cvmtl.hanviet.translit(input).to_str
    render_json({hanviet: hanviet, entries: entries})
  end

  def search
    dname = params["dname"]
    input = params["input"]
    hints = [] of String

    special_dict = Vdict.load(dname)
    regular_dict = Vdict.regular
    hanviet_dict = Vdict.hanviet

    if special_node = special_dict.trie.find(input)
      special_node.edits.each { |term| hints.concat(term.vals) }
    end

    if regular_node = regular_dict.trie.find(input)
      regular_node.edits.each { |term| hints.concat(term.vals) }
    end

    if hanviet_node = hanviet_dict.trie.find(input)
      hanviet_node.edits.each { |term| hints.concat(term.vals) }
    end

    if suggest_node = Vdict.suggest.trie.find(input)
      suggest_node.edits.each { |term| hints.concat(term.vals) }
    end

    unless special_term = special_node.try(&.term)
      if term = regular_node.try(&.term)
        prio, attr = term.prio, term.attr
      else
        prio = attr = 1
      end

      special_term = special_dict.gen_term(input, prio: prio, attr: attr)
    end

    unless regular_term = regular_node.try(&.term)
      regular_term = regular_dict.gen_term(input)
    end

    unless hanviet_term = hanviet_node.try(&.term)
      hanviet_term = hanviet_dict.gen_term(input)
    end

    binh_am = Cvmtl.binh_am.translit(input).to_s
    hanviet = Cvmtl.hanviet.translit(input).to_s

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object {
          jb.field "trans", {binh_am: binh_am, hanviet: hanviet}
          jb.field "hints", hints.uniq.reject { |x| x.empty? || x == hanviet }

          jb.field "infos" {
            jb.array {
              special_term.to_json(jb)
              regular_term.to_json(jb)
              hanviet_term.to_json(jb)
            }
          }
        }
      end
    end
  end

  def upsert
    return halt!(500, "Không đủ quyền hạn!") if cu_privi < 1

    power = params.fetch_int("power")
    power = cu_privi if power > cu_privi

    dname = params["dname"]
    dict = Vdict.load(dname)

    key = params.fetch_str("key").strip
    vals = [params.fetch_str("vals").strip]

    prio = params.fetch_int("prio")
    attr = params.fetch_int("attr")

    new_term = VpTerm.new(key, vals, prio, attr, uname: cu_uname, power: power, dtype: dict.dtype)
    return halt!(501, "Không thay đổi!") unless dict.set!(new_term)

    # TODO: save context

    if dict.dtype == 3 # unique dict
      # add to quick translation dict if entry is a name
      unless key.size < 3 || vals.empty? || vals[0].downcase == vals[0]
        various_term = Vdict.various.gen_term(key, vals, 2, 1)
        Vdict.various.set!(various_term)
      end

      # add to suggestion
      suggest_term = Vdict.suggest.gen_term(key, vals)
      if old_term = Vdict.suggest.find(key)
        suggest_term.vals.concat(old_term.vals).uniq!
      end

      Vdict.suggest.set!(suggest_term)
    end

    render_json(dict.find(key))
  end
end
