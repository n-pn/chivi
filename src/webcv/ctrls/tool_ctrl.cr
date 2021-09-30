require "./base_ctrl"

class CV::ToolCtrl < CV::BaseCtrl
  def convert
    dname = params.fetch_str("dname", "combine")

    input = params.fetch_str("input").gsub("\t", "  ")
    lines = TextUtils.split_text(input, spaces_as_newline: false)

    convert(lines, dname)
  end

  DIR = "_db/qtrans"
  ::FileUtils.mkdir_p(DIR)

  def show
    dname = params.fetch_str("dname", "combine")

    qfile = "#{DIR}/#{params["name"]}.txt"
    return halt! 404, "Not found!" unless File.exists?(qfile)

    lines = File.read_lines(qfile)
    convert(lines, dname)
  end

  private def convert(lines : Array(String), dname : String)
    cvmtl = MtCore.generic_mtl(dname)

    response.content_type = "text/plain; charset=utf-8"

    lines.each_with_index do |line, idx|
      response << "\n" if idx > 0
      cvmtl.cv_plain(line).to_str(response)
    end
  end
end
