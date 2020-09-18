require "./route_utils"

module Server
  alias LookupEntry = Hash(String, Array(String))

  post "/_dicts/lookup" do |env|
    dname = env.params.query.fetch("dname", "dich-nhanh")
    dicts = Libcv::Library.for_convert(dname)

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

      Libcv::Library.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      Libcv::Library.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Libcv.hanviet(input, apply_cap: false).to_s
    {hanviet: hanviet, entries: entries}.to_json(env.response)
  end

  # # default upsert dicts
  DICTS = "dich-nhanh|generic|hanviet"

  get "/_dicts/search/:input" do |env|
    input = env.params.url["input"]
    dicts = env.params.query.fetch("dicts", DICTS).split("|")

    entries = dicts.map do |dname|
      Libcv::Library.load_dict(dname).find(input)
    end

    suggest = Libcv::Library.suggest.dict.find(input).try(&.vals)
    {
      entries: entries,
      hanviet: Libcv.hanviet(input, false).vi_text,
      binh_am: Libcv.binh_am(input, false).vi_text,
      suggest: suggest || [] of String,
    }.to_json(env.response)
  end

  put "/_dicts/upsert/:dic" do |env|
    dic = env.params.url["dic"]
    key = env.params.json["key"].as(String)
    val = env.params.json["val"].as(String?) || ""
    # power = env.params.json["power"].as(Int64).to_i

    if uslug = env.session.string?("uslug")
      user = UserInfo.get!(uslug)
      uname = user.uname
      power = user.power
    else
      uname = "Guest"
      power = 0
    end

    Libcv::Library.upsert(dic, uname, power, key, val)
    {_stt: "ok", _msg: "accepted"}.to_json(env.response)
  rescue err
    {_stt: "err", _msg: err.message}.to_json(env.response)
  end
end
