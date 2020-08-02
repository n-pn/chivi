require "./_utils"
require "../libcv"
require "../common/text_util"

module Server
  post "/_convert" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    dname = env.params.json.fetch("dname", "tonghop").as(String)
    Libcv.cv_mixed(lines, dname).map(&.to_s).to_json(env.response)
  end

  post "/_hanviet" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Libcv.hanviet(lines, apply_cap: true).map(&.to_s).to_json(env.response)
  end

  post "/_binh_am" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Libcv.binh_am(lines, apply_cap: true).map(&.to_s).to_json(env.response)
  end

  post "/_tradsim" do |env|
    input = env.params.json["input"].as(String)
    lines = TextUtil.split_text(input)
    Libcv.tradsim(lines).map(&.to_s).to_json(env.response)
  end
end
