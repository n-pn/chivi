require "./_utils"
require "../engine"
require "../userdb"
require "../dictdb"

module Server
  alias LookupEntry = Hash(String, Array(String))

  get "/_lookup" do |env|
    dname = env.params.query.fetch("dname", "combine")
    dicts = TrieDict.for_convert(dname)

    input = env.params.query.fetch("input", "")
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

      TrieDict.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      TrieDict.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Engine.hanviet(input, apply_cap: true).to_s
    {hanviet: hanviet, entries: entries}.to_json(env.response)
  end

  get "/_search" do |env|
    # TODO: search for a list of dnames

    input = env.params.query.fetch("input", "")
    dname = env.params.query.fetch("dname", "combine")

    if item = TrieDict.suggest.find(input)
      suggest = {vals: item.vals, extra: item.extra}
    else
      suggest = {vals: [] of String, extra: ""}
    end

    {
      hanviet: Engine.hanviet(input, false).vi_text,
      binh_am: Engine.binh_am(input, false).vi_text,
      generic: DictDB.search(input, "generic"),
      special: DictDB.search(input, dname),
      suggest: suggest,
    }.to_json(env.response)
  end

  get "/_upsert" do |env|
    power = env.params.query.fetch("power", "0").to_i? || 0

    if uslug = env.session.string("uslug")
      user = UserInfo.get!(uslug)
      uname = user.uname
      power = user.power if power > user.power
    else
      uname = "guest"
      power = 0
    end

    dname = env.params.query.fetch("dname", "combine")

    key = env.params.query.fetch("key", "")
    vals = env.params.query.fetch("vals", "")
    extra = env.params.query.fetch("extra", "")

    if DictDB.upsert(dname, uname, power, key, vals, extra)
      {msg: "accepted"}.to_json(env.response)
    else
      {msg: "rejected"}.to_json(env.response)
    end
  end
end
