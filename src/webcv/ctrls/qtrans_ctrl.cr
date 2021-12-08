require "./base_ctrl"

class CV::QtransCtrl < CV::BaseCtrl
  NOTE_DIR = "var/qttexts/notes"
  POST_DIR = "var/qttexts/posts"

  ::FileUtils.mkdir_p(NOTE_DIR)
  ::FileUtils.mkdir_p(POST_DIR)

  alias RawQt = Tuple(String, String, Array(String))

  CACHE = RamCache(String, RawQt).new(512, 6.hours)

  def show
    type = params["type"]
    name = params["name"]

    dname, d_dub, lines = CACHE.get("#{type}-#{name}") do
      case type
      when "notes" then load_note(name)
      when "crits" then load_crit(name)
      else              raise "Unknown qtran type!"
      end
    end

    return halt! 404, "Not found!" if lines.empty?

    if params["mode"]? == "text"
      response.content_type = "text/plain; charset=utf-8"
      convert(dname, lines, response)
    else
      json_view do |jb|
        jb.object do
          jb.field "dname", dname
          jb.field "d_dub", d_dub
          jb.field "zhtext", lines
          jb.field "cvdata", String.build { |io| convert(dname, lines, io) }.to_s
        end
      end
    end
  end

  private def load_note(name : String) : RawQt
    file = "#{NOTE_DIR}/#{name}.txt"
    return {"", "", [] of String} unless File.exists?(file)

    dname = params.fetch_str("dname", "combine")
    d_dub = CtrlUtil.d_dub(dname)
    {dname, d_dub, parse_lines(File.read(file))}
  end

  private def load_crit(name : String) : RawQt
    crit_id = UkeyUtil.decode32(name)
    return {"", "", [] of String} unless yscrit = Yscrit.find({id: crit_id})

    dname = yscrit.cvbook.bhash
    d_dub = yscrit.cvbook.vtitle
    {dname, d_dub, parse_lines(yscrit.ztext)}
  end

  def create_post
    # TODO: save posts
    lines = parse_lines(params.fetch_str("input"))
    dname = params.fetch_str("dname", "combine")

    response.content_type = "text/plain; charset=utf-8"
    convert(dname, lines, response)
  end

  def qtran
    input = params.fetch_str("input")
    dname = params.fetch_str("dname", "combine")

    response.content_type = "text/plain; charset=utf-8"

    if params["mode"]? == "tlspec"
      cvmtl = MtCore.generic_mtl(dname, _cvuser.uname)
      cvmtl.cv_plain(input, cap_first: false).to_s(response)

      response << "\n"
      MtCore.hanviet_mtl.translit(input, apply_cap: false).to_s(response)
    else
      convert(dname, parse_lines(input), response)
    end
  end

  private def parse_lines(ztext : String) : Array(String)
    ztext = ztext.gsub("\t", "  ")
    TextUtils.split_text(ztext, spaces_as_newline: false)
  end

  private def convert(dname, lines : Array(String), output : IO)
    cvmtl = MtCore.generic_mtl(dname, _cvuser.uname)

    lines.each_with_index do |line, idx|
      output << "\n" if idx > 0
      cvmtl.cv_plain(line, cap_first: true).to_str(output)
    end
  end
end
