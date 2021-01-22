require "./_route_utils"

module CV::Server
  alias Lookup = Hash(String, Array(String))

  put "/api/dicts/lookup/:dname" do |env|
    dname = env.params.url["dname"]
    dicts = {VpDict.load(dname), VpDict.regular}

    input = env.params.json["input"].as(String)
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

  get "/api/dicts/search/:input" do |env|
    input = env.params.url["input"]
    dname = env.params.query.fetch("dname", "various")

    hints = [] of String

    if special_info = VpDict.load(dname).info(input)
      hints.concat(special_info[:vals])
      hints.concat(special_info[:hints])
    end

    if regular_info = VpDict.regular.info(input)
      hints.concat(regular_info[:vals])
      hints.concat(regular_info[:hints])
    end

    if hanviet_info = VpDict.hanviet.info(input)
      hints.concat(hanviet_info[:vals])
      hints.concat(hanviet_info[:hints])
    end

    if suggest_info = VpDict.suggest._root.find(input)
      suggest_info.entry.try { |x| hints.concat(x.vals) }
      hints.concat(suggest_info._hint)
    end

    binh_am = Convert.binh_am.translit(input).to_s
    hanviet = Convert.hanviet.translit(input).to_s

    blank = {vals: [] of String, hints: [] of String}

    RouteUtils.json_res(env) do |res|
      {
        trans: {binh_am: binh_am, hanviet: hanviet},
        infos: {special_info || blank, regular_info || blank, hanviet_info || blank},
        hints: hints.uniq.reject(&.== hanviet),
      }.to_json(res)
    end
  end

  put "/api/dicts/upsert/:dname" do |env|
    u_dname = env.session.string?("u_dname") || "Khách"
    u_power = env.session.int?("u_power") || 0

    halt env, status_code: 500, response: "Access denied!" if u_power < 1

    key = env.params.json["key"].as(String)
    value = env.params.json.fetch("value", "").as(String).split(/[\/|]/).reject(&.empty?)
    attrs = env.params.json.fetch("attrs", "").as(String)

    power = env.params.json.fetch("power", u_power).as(Int64).to_i
    power = u_power if power > u_power

    dict = VpDict.load(env.params.url["dname"])
    entry = VpEntry.new(key, value, attrs, dtype: dict.dtype)
    emend = VpEmend.new(uname: u_dname, power: power)

    # TODO: save context
    unless dict.set(entry, emend)
      halt env, status_code: 501, response: "Unchanged!"
    end

    if dict.dtype == 3 # unique dict
      # add to suggestion
      CV::VpDict.suggest.set(entry, emend)

      # add to quick translation dict if entry is a name
      unless value.empty? || value[0].downcase == value[0]
        CV::VpDict.various.set(entry, emend) unless CV::VpDict.regular.find(key)
      end
    end

    RouteUtils.json_res(env, dict.info(key))
  end
end
