require "./_route_utils"

module CV::Server
  alias LookupEntry = Hash(String, Array(String))

  put "/api/dicts/lookup/:dname" do |env|
    dname = env.params.url["dname"]
    dicts = {VpDict.load(dname), VpDict.regular}

    input = env.params.json["input"].as(String)
    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, LookupEntry).new do |hash, key|
        hash[key] = LookupEntry.new { |h, k| h[k] = [] of String }
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

    RouteUtils.json_res(env) do |res|
      {
        entries: {
          VpDict.load(dname).info(input),
          VpDict.regular.info(input),
          VpDict.hanviet.info(input),
        },
        hanviet: Convert.hanviet.translit(input).to_s,
        binh_am: Convert.binh_am.translit(input).to_s,
        suggest: VpDict.suggest.find(input).try(&.vals),
      }.to_json(res)
    end
  end

  put "/api/dicts/upsert/:dname" do |env|
    uname = env.session.string?("u_dname") || "Khách"
    p_max = env.session.int?("u_power") || 0

    power = env.params.json["power"]?.as(Int32?) || p_max
    power = p_max if power > p_max

    halt env, status_code: 500, response: "Access denied!" if power < 1

    key = env.params.json["key"].as(String)
    vals = env.params.json["vals"]?.as(String?) || ""
    attrs = env.params.json["attrs"]?.as(String?) || ""

    dict = VpDict.load(env.params.url["dname"])
    entry = VpEntry.new(key, vals.split(/[\/|]/), attrs)
    emend = VpEmend.new(uname: uname, power: power)

    # TODO: save context

    if dict.upsert!(entry, emend)
      RouteUtils.json_res(env, [1])
    else
      halt env, status_code: 501, response: "Unchanged!"
    end
  end
end
