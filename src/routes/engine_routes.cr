require "./_route_utils"
require "../_oldcv/_utils/text_util"

module CV::Server
  post "/api/tools/convert" do |env|
    input = env.params.json["input"]?.as(String?) || ""
    lines = Oldcv::TextUtil.split_text(input)
    dname = env.params.json.fetch("dname", "combine").as(String)

    RouteUtils.json_res(env) do |res|
      Oldcv::Engine.cv_mixed(lines, dname).map(&.to_s).to_json(res)
    end
  end

  post "/api/tools/hanviet" do |env|
    input = env.params.json["input"].as(String)
    lines = Oldcv::TextUtil.split_text(input)

    RouteUtils.json_res(env) do |res|
      Oldcv::Engine.hanviet(lines, apply_cap: true).map(&.to_s).to_json(res)
    end
  end

  post "/api/tools/binh_am" do |env|
    input = env.params.json["input"].as(String)
    lines = Oldcv::TextUtil.split_text(input)

    RouteUtils.json_res(env) do |res|
      Oldcv::Engine.binh_am(lines, apply_cap: true).map(&.to_s).to_json(res)
    end
  end

  post "/api/tools/tradsim" do |env|
    input = env.params.json["input"].as(String)
    lines = Oldcv::TextUtil.split_text(input)

    RouteUtils.json_res(env) do |res|
      Oldcv::Engine.tradsim(lines).map(&.to_s).to_json(res)
    end
  end
end
