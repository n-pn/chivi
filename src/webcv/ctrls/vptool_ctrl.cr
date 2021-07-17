require "./base_ctrl"

class CV::VpToolCtrl < CV::BaseCtrl
  def convert
    dname = params["dname"]
    cvter = MtCore.generic_mtl(dname)

    input = params.fetch_str("input").gsub("\t", "  ")
    lines = TextUtils.split_text(input, spaces_as_newline: false)

    response.content_type = "text/plain; charset=utf-8"

    lines.each do |line|
      response << "\n"
      cvter.cv_plain(line).to_str(response)
    end
  end

  DIR = "_db/qtrans"
  ::FileUtils.mkdir_p(DIR)

  def show
    dname = params.fetch_str("dname", "combine")
    cvter = MtCore.generic_mtl(dname)

    name = params["name"]
    file = "#{DIR}/#{name}.txt"
    return halt! 404, "Not found!" unless File.exists?(file)

    lines = File.read_lines(file)
    response.content_type = "text/plain; charset=utf-8"

    lines.each do |line|
      response << "\n"
      cvter.cv_plain(line).to_str(response)
    end
  end
end
