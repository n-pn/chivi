require "./base_ctrl"

class CV::QtransCtrl < CV::BaseCtrl
  NOTE_DIR = "var/qttexts/notes"
  POST_DIR = "var/qttexts/posts"

  ::FileUtils.mkdir_p(NOTE_DIR)
  ::FileUtils.mkdir_p(POST_DIR)

  def show_note
    qname = params["name"]
    qfile = "#{NOTE_DIR}/#{qname}.txt"
    return halt! 404, "Not found!" unless File.exists?(qfile)

    lines = parse_lines(File.read(qfile))

    json_view do |jb|
      jb.object do
        jb.field "zhtext", lines
        jb.field "cvdata", String.build { |io| convert("combine", lines, io) }.to_s
      end
    end
  end

  def show_crit
  end

  def show_post
  end

  def qtran
    input = params.fetch_str("input").gsub("\t", "  ")
    lines = parse_lines(input)

    dname = params.fetch_str("dname", "combine")
    response.content_type = "text/plain; charset=utf-8"
    convert(dname, lines, response)
  end

  private def parse_lines(ztext : String) : Array(String)
    TextUtils.split_text(ztext, spaces_as_newline: false)
  end

  private def convert(dname, lines : Array(String), output : IO)
    cvmtl = MtCore.generic_mtl(dname, _cvuser.uname)

    lines.each_with_index do |line, idx|
      output << "\n" if idx > 0
      cvmtl.cv_plain(line, mode: 1).to_str(output)
    end
  end
end
