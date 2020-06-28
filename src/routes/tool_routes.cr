require "./_route_utils"

module Server
  post "/_/convert" do |env|
    udic = env.get("udic").as(String)
    bdic = env.params.json.fetch("bdic", "tonghop").as(String)

    text = env.params.json["text"].as(String)
    lines = Utils.split_lines(text)

    data = Engine.cv_mixed(lines, bdic, udic)
    data.to_json(env.response)
  end

  get "/_/hanviet" do |env|
    udic = env.get("udic").as(String)
    text = env.params.query.fetch("text", "")

    data = Engine.hanviet(text, udic, apply_cap: true)
    data.to_json env.response
  end

  get "/_/pinyins" do |env|
    udic = env.get("udic").as(String)
    text = env.params.query.fetch("text", "")

    data = Engine.pinyins(text, udic, apply_cap: true)
    data.to_json env.response
  end

  get "/_/tradsim" do |env|
    udic = env.get("udic").as(String)
    text = env.params.query.fetch("text", "")

    data = Engine.tradsim(txt, udic, apply_cap: true)
    data.to_json env.response
  end
end
