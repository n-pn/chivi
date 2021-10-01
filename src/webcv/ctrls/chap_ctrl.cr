require "./base_ctrl"

class CV::ChapCtrl < CV::BaseCtrl
  private def load_zhbook
    cvbook_id = params["book"].to_i64
    zname = Zhseed.index(params["sname"])
    Zhbook.load!(cvbook_id, zname)
  end

  def index
    pgidx = params.fetch_int("page", min: 1)
    imode = params.fetch_int("mode", min: 0, max: cu_privi)

    zhbook = load_zhbook
    utime, total = zhbook.refresh!(cu_privi, imode)

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "sname", zhbook.sname
          jb.field "utime", utime

          jb.field "wlink", zhbook.wlink
          jb.field "crawl", zhbook.remote?(cu_privi)

          jb.field "total", total

          jb.field "pgidx", pgidx
          jb.field "pgmax", (total - 1) // 32 + 1

          jb.field "lasts" do
            jb.array do
              zhbook.lastpg.each(&.to_json(jb))
            end
          end

          jb.field "chaps" do
            jb.array do
              zhbook.chpage(pgidx - 1).each(&.to_json(jb))
            end
          end
        end
      end
    end
  end

  def show
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart") { 0 }

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    privi = _cv_user.privi
    imode = params.fetch_int("mode", min: 0, max: privi)
    lines = zhbook.chtext(chidx - 1, cpart, privi: privi, reset: imode > 1)

    json_view do |jb|
      jb.object {
        jb.field "sname", zhbook.sname
        jb.field "total", zhbook.chap_count

        jb.field "_prev", cpart == 0 ? zhbook.chap_url(chidx - 1, -1) : zhbook.chap_url(chidx, cpart - 1)
        jb.field "_next", cpart + 1 < chinfo.parts ? zhbook.chap_url(chidx, cpart + 1) : zhbook.chap_url(chidx + 1)

        jb.field "chidx", chidx
        jb.field "cpart", cpart
        jb.field "clink", zhbook.clink(chinfo.schid)

        jb.field "utime", chinfo.utime
        jb.field "parts", chinfo.parts

        jb.field "title", chinfo.title
        jb.field "chvol", chinfo.chvol
        jb.field "uslug", chinfo.uslug

        jb.field "zhtext", lines
        jb.field "cvdata" {
          cvdata = String.build { |io| convert(zhbook, chinfo, lines, cpart, io) }
          jb.string(cvdata)
        }
      }
    end
  end

  def text : Nil
    chidx = params.fetch_int("chidx") { 1 }
    cpart = params.fetch_int("cpart") { 0 }

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    min_fresh = _cv_user.privi < 2 ? 60 : 20
    response.headers.add("Cache-Control", "private, min-fresh=#{min_fresh}")
    response.content_type = "text/plain; charset=utf-8"

    lines = zhbook.chtext(chidx - 1, cpart, privi: 0)
    convert(zhbook, chinfo, lines, cpart, response)
  end

  private def text_not_found!(status = 404)
    halt! 404, "Chương tiết không tồn tại!"
  end

  private def convert(zhbook, chinfo, lines, cpart, output : IO)
    return if lines.empty?

    cvmtl = MtCore.generic_mtl(zhbook.cvbook.bhash, _cv_user.uname)
    mode = _cv_user.tlmode

    cvmtl.cv_title_full(lines[0], mode: mode).to_str(output)
    output << "\t" << "  (#{cpart + 1}/#{chinfo.parts})" if chinfo.parts > 1

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      output << "\n"
      cvmtl.cv_plain(line, mode: mode).to_str(output)
    end
  end

  def upsert
    return 403, "Unsupported"
    # return halt!(500, "Quyền hạn không đủ!") if _cv_user.privi < 2
    # zhbook = load_zhbook
    # chidx = params.fetch_int("chidx") { 1 }

    # label = params.fetch_str("label")
    # label = "" if label == "正文"

    # input = params.fetch_str("input")
    # lines = TextUtils.split_text(input, false)

    # chaps = split_chaps(lines, label)

    # chmax = zhbook.chap_count + 1
    # chidx = chmax if chidx < 1 || chidx > chmax

    # infos = chaps.map_with_index(chidx - 1) do |chap, index|
    #   schid = zhbook.get_schid(index)
    #   zhbook.chtext(index, schid).set_zh!(chap.lines)
    #   zhbook.set_chap!(index, schid, chap.title, chap.label).not_nil!
    # end

    # chmax = chidx + chaps.size - 1

    # if chmax > zhbook.chap_count
    #   zhbook.bumped = Time.utc.to_unix
    #   zhbook.mftime = zhbook.bumped if zhbook.zseed == 0
    #   zhbook.last_schid = infos.last[0]
    #   zhbook.chap_count = chmax
    #   zhbook.save!
    # end

    # zhbook.reset_trans!(chmax, chidx)

    # render_json({msg: "ok", chidx: chidx.to_s, uslug: infos.first[3]})
  rescue err
    puts "- Error loading chtext: #{err}"
    halt!(500, err.message)
  end

  struct Chap
    getter label : String
    getter lines = [] of String
    getter title : String { lines.first? || "" }

    def initialize(@label)
    end
  end

  LINE_RE = /^\/{4,}(.*)^/

  private def split_chaps(input : Array(String), label = "")
    chaps = [Chap.new(label)]

    input.each do |line|
      if line =~ /^\s*\/{4,}/
        extra = line.gsub("/", "")
        label = extra unless extra.empty? || extra == "正文"
        chaps << Chap.new(label)
      else
        line = line.strip
        chaps.last.lines << line unless line.empty?
      end
    end

    chaps.shift if chaps.first.lines.empty?
    chaps
  end
end
