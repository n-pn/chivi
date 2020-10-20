require "../_utils/text_util"
require "./route_utils"

module Server
  post "/_tools/convert" do |env|
    input = env.params.json["input"]?.as(String?) || ""
    lines = TextUtil.split_text(input)
    dname = env.params.json.fetch("dname", "dich-nhanh").as(String)
    Engine.cv_mixed(lines, dname).map(&.to_s).to_json(env.response)
  end

  post "/_tools/hanviet" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Engine.hanviet(lines, apply_cap: true).map(&.to_s).to_json(env.response)
  end

  post "/_tools/binh_am" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Engine.binh_am(lines, apply_cap: true).map(&.to_s).to_json(env.response)
  end

  post "/_tools/tradsim" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Engine.tradsim(lines).map(&.to_s).to_json(env.response)
  end
end
