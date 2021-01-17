require "./_route_utils"

module CV::Server
  alias LookupEntry = Hash(String, Array(String))

  put "/api/dicts/lookup/:dname" do |env|
    dname = env.params.url["dname"]
    dicts = {Library.find_dict(dname), Library.regular}

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

      Library.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      Library.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = String.build do |io|
      Convert.hanviet.translit(input, apply_cap: false).to_json(io)
    end

    RouteUtils.json_res(env) do |res|
      {hanviet: hanviet, entries: entries}.to_json(res)
    end
  end

  get "/api/dicts/search/:input" do |env|
    input = env.params.url["input"]
    dname = env.params.query.fetch("dname", "various")

    RouteUtils.json_res(env) do |res|
      {
        entries: [
          Library.find_dict(dname).find(input).try(&.to_tuple),
          Library.regular.find(input).try(&.to_tuple),
          Library.hanviet.find(input).try(&.to_tuple),
        ],

        hanviet: Oldcv::Engine.hanviet(input, false).vi_text,
        binh_am: Oldcv::Engine.binh_am(input, false).vi_text,
        suggest: Library.suggest.find(input).try(&.vals),
      }.to_json(res)
    end
  end

  put "/api/dicts/upsert/:dic" do |env|
    dic = env.params.url["dic"]
    key = env.params.json["key"].as(String)
    val = env.params.json["val"].as(String?) || ""

    uname = env.session.string?("dname") || "Khách"
    power = env.session.int?("power") || -1

    # power = env.params.json["power"]?.as(Int32?) ||

    if Library.upsert(dic, key, val.split("/"), uname: uname, plock: power)
      RouteUtils.json_res(env) { |res| {_stt: "ok"}.to_json(res) }
    else
      RouteUtils.json_res(env) { |res| {_stt: "err", _msg: "Không đủ quyền hạn!"}.to_json(res) }
    end
  end
end
