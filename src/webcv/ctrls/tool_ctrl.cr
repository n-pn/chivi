require "./base_ctrl"

class CV::ToolCtrl < CV::BaseCtrl
  def convert
    input = params.fetch_str("input").gsub("\t", "  ")
    lines = TextUtils.split_text(input, spaces_as_newline: false)

    response.content_type = "text/plain; charset=utf-8"
    convert(lines, response)
  end

  DIR = "db/qtnotes"
  ::FileUtils.mkdir_p(DIR)

  def show
    qfile = "#{DIR}/#{params["name"]}.txt"
    return halt! 404, "Not found!" unless File.exists?(qfile)

    lines = File.read_lines(qfile).map(&.strip).reject(&.empty?)

    json_view do |jb|
      jb.object do
        jb.field "zhtext", lines
        jb.field "cvdata", String.build { |io| convert(lines, io) }.to_s
      end
    end
  end

  private def convert(lines : Array(String), output : IO)
    dname = params.fetch_str("dname", "combine")
    cvmtl = MtCore.generic_mtl(dname, _cv_user.uname)

    lines.each_with_index do |line, idx|
      output << "\n" if idx > 0
      cvmtl.cv_plain(line, mode: 1).to_str(output)
    end
  end
end
