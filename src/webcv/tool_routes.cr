require "./_route_utils"

module CV::Server
  post "/api/convert/:dname" do |env|
    dname = env.params.url["dname"]
    cvter = Cvmtl.generic(dname)

    input = env.params.json.fetch("input", "").as(String)
    lines = TextUtils.split_text(input)

    unless lines.empty?
      cvter.cv_title(lines[0]).to_str(env.response)

      1.upto(lines.size - 1) do |i|
        env.response << "\n"
        para = lines.unsafe_fetch(i)
        cvter.cv_plain(para).to_str(env.response)
      end
    end
  end
end
