require "./_route_utils"

module Server
  get "/_/lookup" do |env|
    user = env.get("user").as(String)

    line = env.params.query.fetch("line", "")
    dict = env.params.query.fetch("dict", "tonghop")

    Engine.lookup(line, dict, user).to_json(env.response)
  end

  get "/_/inquire" do |env|
    user = env.get("user").as(String)

    word = env.params.query["word"]? || ""
    dict = env.params.query["dict"]? || "tonghop"

    res = Engine.inquire(word, dict, user)
    res.to_json(env.response)
  end

  get "/_/upsert" do |env|
    key = env.params.query["key"]? || ""
    val = env.params.query["val"]? || ""

    dict = env.params.query["dict"]? || "tonghop"
    user = env.get("user").as(String)

    res = Engine.upsert(key, val, dict, user)
    res.to_json(env.response)
  end
end
