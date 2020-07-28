require "./_utils"
require "../engine"
require "../userdb"
require "../dictdb"

module Server
  alias LookupEntry = Hash(String, Array(String))

  get "/_lookup" do |env|
    dname = env.params.query.fetch("dname", "combine")
    dicts = DictDB.for_convert(dname)

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

      DictDB.trungviet.scan(chars, idx) do |item|
        entry[item.key.size]["trungviet"] = item.vals
      end

      DictDB.cc_cedict.scan(chars, idx) do |item|
        entry[item.key.size]["cc_cedict"] = item.vals
      end

      entry.to_a.sort_by(&.[0].-)
    end

    hanviet = Engine.hanviet(input, apply_cap: true).to_s
    {hanviet: hanviet, entries: entries}.to_json(env.response)
  end

  get "/_search" do |env|
    # TODO: search for a list of dnames

    bdic = env.params.query.fetch("bdic", "_tonghop")
    term = env.params.query.fetch("term", "")

    generic = DictDB.search(term, "generic")
    special = DictDB.search(term, bdic)
    suggest = DictDB.suggest.dict.find(term).try(&.vals) || [] of String

    {
      hanviet: Engine.hanviet(term, false).vi_text,
      binh_am: Engine.binh_am(term, false).vi_text,
      generic: generic,
      special: special,
      suggest: suggest,
    }.to_json(env.response)
  end

  put "/_upsert" do |env|
    power = env.params.json["power"]?.as?(Int32) || 0

    if uslug = env.session.string?("uslug")
      user = UserInfo.get!(uslug)
      uname = user.uname
      power = user.power if power > user.power
      power = 0 if power < 0
    else
      uname = "guest"
      power = 0
    end

    dname = env.params.query.fetch("dname", "_tonghop")

    key = env.params.json.fetch("key", "").as(String)
    vals = env.params.json.fetch("vals", "").as(String)

    DictDB.upsert(dname, uname, power, key, vals)
    {status: "ok", msg: "accepted"}.to_json(env.response)
  rescue err
    {status: "err", msg: err.message}.to_json(env.response)
  end
end
