require "./_route_utils"

module CV::Server
  alias LookupEntry = Hash(String, Array(String))

  post "/api/dicts/lookup" do |env|
    dname = env.params.query.fetch("dname", "dich-nhanh")
    dicts = Oldcv::Engine::Library.for_convert(dname)

    input = env.params.json["input"].as(String)
    chars = input.chars
    upper = chars.size - 1

    entries = (0..upper).map do |idx|
      entry = Hash(Int32, LookupEntry).new do |hash, key|
        hash[key] = LookupEntry.new { |h, k| h[k] = [] of String }
      end

      dicts.reverse_each do |dict|
        dict.scan(chars, idx) do |item|
          entry[item.key.size]["vietphrase"].concat(item.vals).uniq!
        end
      end

      Oldcv::Engine::Library.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      Oldcv::Engine::Library.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Oldcv::Engine.hanviet(input, apply_cap: false).to_s

    RouteUtils.json_res(env) do |res|
      {hanviet: hanviet, entries: entries}.to_json(res)
    end
  end

  # # default upsert dicts
  DICTS = "dich-nhanh|generic|hanviet"

  get "/api/dicts/search/:input" do |env|
    input = env.params.url["input"]
    dicts = env.params.query.fetch("dicts", DICTS).split("|")

    entries = dicts.map do |dname|
      Oldcv::Engine::Library.load_dict(dname).find(input)
    end

    suggest = Oldcv::Engine::Library.suggest.dict.find(input).try(&.vals)

    RouteUtils.json_res(env) do |res|
      {
        entries: entries,
        hanviet: Oldcv::Engine.hanviet(input, false).vi_text,
        binh_am: Oldcv::Engine.binh_am(input, false).vi_text,
        suggest: suggest || [] of String,
      }.to_json(res)
    end
  end

  put "/api/dicts/upsert/:dic" do |env|
    dic = env.params.url["dic"]
    key = env.params.json["key"].as(String)
    val = env.params.json["val"].as(String?) || ""

    dname = env.session.string?("dname") || "Khách"
    power = env.session.int?("power") || -1

    # power = env.params.json["power"]?.as(Int32?) ||

    Oldcv::Engine::Library.upsert(dic, dname, power, key, val)
    RouteUtils.json_res(env) { |res| {_stt: "ok"}.to_json(res) }
  rescue err
    RouteUtils.json_res(env) { |res| {_stt: "err", _msg: err.message}.to_json(res) }
  end
end
