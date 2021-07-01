require "./base_ctrl"

class CV::VpToolCtrl < CV::BaseCtrl
  def convert
    dname = params["dname"]
    cvter = Cvmtl.generic(dname)

    input = params.fetch_str("input").gsub("\t", "    ")
    lines = TextUtils.split_text(input, spaces_is_new_line: false)

    response.content_type = "text/plain; charset=utf-8"

    lines.each do |line|
      response << "\n"
      cvter.cv_plain(line).to_str(response)
    end
  end
end
