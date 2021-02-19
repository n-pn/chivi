require "./_route_utils"

module CV::Server
  alias Lookup = Hash(String, Array(String))

  get "/api/dictdb/lookup/:input" do |env|
    dname = env.params.query.fetch("dname", "various")
    dicts = {VpDict.load(dname), VpDict.regular}

    input = env.params.url["input"]
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

      VpDict.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      VpDict.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Convert.hanviet.translit(input).to_str

    RouteUtils.json_res(env) do |res|
      {hanviet: hanviet, entries: entries}.to_json(res)
    end
  end

  get "/api/dictdb/search/:input" do |env|
    input = env.params.url["input"]
    dname = env.params.query.fetch("dname", "various")

    hints = [] of String

    special_dict = VpDict.load(dname)
    regular_dict = VpDict.regular
    hanviet_dict = VpDict.hanviet

    if special_node = special_dict.trie.find(input)
      special_node.edits.each { |term| hints.concat(term.vals) }
    end

    if regular_node = regular_dict.trie.find(input)
      regular_node.edits.each { |term| hints.concat(term.vals) }
    end

    if hanviet_node = hanviet_dict.trie.find(input)
      hanviet_node.edits.each { |term| hints.concat(term.vals) }
    end

    if suggest_node = VpDict.suggest.trie.find(input)
      suggest_node.edits.each { |term| hints.concat(term.vals) }
    end

    binh_am = Convert.binh_am.translit(input).to_s
    hanviet = Convert.hanviet.translit(input).to_s

    # blank = {vals: [] of String, hints: [] of String, attrs: "", power: 0}

    unless special_term = special_node.try(&.term)
      if term = regular_node.try(&.term)
        prio = term.prio
        attr = term.attr
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

    RouteUtils.json_res(env) do |res|
      JSON.build(res) do |json|
        json.object do
          json.field "trans", {binh_am: binh_am, hanviet: hanviet}
          json.field "hints", hints.uniq.reject(&.== hanviet)

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

  put "/api/dictdb/upsert/:dname" do |env|
    u_dname = env.session.string?("u_dname") || "Khách"
    u_power = env.session.int?("u_power") || 0

    halt env, status_code: 500, response: "Access denied!" if u_power < 1
    dict = VpDict.load(env.params.url["dname"])

    key = env.params.json["key"].as(String).strip

    vals = env.params.json.fetch("vals", "").as(String)
    vals = [vals.strip]

    prio = env.params.json.fetch("prio", 1).as(Int64).to_i8
    attr = env.params.json.fetch("attr", 0).as(Int64).to_i8

    power = env.params.json.fetch("power", u_power).as(Int64).to_i8
    power = u_power.to_i8 if power > u_power

    new_term = VpTerm.new(key, vals, prio, attr, uname: u_dname, power: power, dtype: dict.dtype)

    # TODO: save context
    unless dict.add!(new_term)
      halt env, status_code: 501, response: "Unchanged!"
    end

    if dict.dtype == 3 # unique dict
      # add to quick translation dict if entry is a name
      unless key.size < 3 || vals.empty? || vals[0].downcase == vals[0]
        various_term = VpDict.various.gen_term(key, vals, 2_i8, 1_i8)
        VpDict.various.add!(various_term)
      end

      # add to suggestion
      suggest_term = VpDict.suggest.gen_term(key, vals)
      if old_term = VpDict.suggest.find(key)
        suggest_term.vals.concat(old_term.vals).uniq!
      end

      VpDict.suggest.add!(suggest_term)
    end

    RouteUtils.json_res(env, dict.find(key))
  end
end
