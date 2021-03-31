require "./_route_utils"

module CV::Server
  alias Lookup = Hash(String, Array(String))

  put "/api/dicts/:dname/lookup" do |env|
    dname = env.params.url["dname"]
    input = env.params.json["input"].as(String).strip

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
    RouteUtils.json_res(env, {hanviet: hanviet, entries: entries})
  end

  put "/api/dicts/:dname/search" do |env|
    dname = env.params.url["dname"]
    input = env.params.json["input"].as(String).strip

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
        prio = attr = 1_i8
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

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "trans", {binh_am: binh_am, hanviet: hanviet}
          json.field "hints", hints.uniq.reject { |x| x.empty? || x == hanviet }

          json.field "infos" do
            json.array do
              special_term.to_json(json)
              regular_term.to_json(json)
              hanviet_term.to_json(json)
            end
          end
        end
      end
    end
  end

  put "/api/dicts/:dname/upsert" do |env|
    u_power = env.session.int?("u_power") || 0
    halt env, status_code: 500, response: "Access denied!" if u_power < 1

    power = env.params.json.fetch("power", u_power).as(Int64).to_i8
    power = u_power.to_i8 if power > u_power

    uname = env.session.string?("u_dname") || "Khách"
    dname = env.params.url["dname"]

    dict = Vdict.load(dname)

    key = env.params.json["key"].as(String).strip
    vals = env.params.json.fetch("vals", "").as(String)
    vals = [vals.strip]
    prio = env.params.json.fetch("prio", 1).as(Int64).to_i8
    attr = env.params.json.fetch("attr", 0).as(Int64).to_i8

    new_term = Vterm.new(key, vals, prio, attr, uname: uname, power: power, dtype: dict.dtype)

    # TODO: save context
    unless dict.set!(new_term)
      halt env, status_code: 501, response: "Unchanged!"
    end

    if dict.dtype == 3 # unique dict
      # add to quick translation dict if entry is a name
      unless key.size < 3 || vals.empty? || vals[0].downcase == vals[0]
        various_term = Vdict.various.gen_term(key, vals, 2_i8, 1_i8)
        Vdict.various.set!(various_term)
      end

      # add to suggestion
      suggest_term = Vdict.suggest.gen_term(key, vals)
      if old_term = Vdict.suggest.find(key)
        suggest_term.vals.concat(old_term.vals).uniq!
      end

      Vdict.suggest.set!(suggest_term)
    end

    RouteUtils.json_res(env, dict.find(key))
  end
end
