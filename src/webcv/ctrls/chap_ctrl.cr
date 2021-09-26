require "./base_ctrl"

class CV::ChapCtrl < CV::BaseCtrl
  def load_zhbook
    cvbook_id = params["book"].to_i64
    zname = Zhseed.index(params["sname"])
    Zhbook.load!(cvbook_id, zname)
  end

  def index
    zhbook = load_zhbook
    pgidx = params.fetch_int("page", min: 1)

    mode = params.fetch_int("mode", min: 0, max: cu_privi)
    utime, total = zhbook.refresh!(cu_privi, mode)

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
              zhbook.chinfo.last_chaps.each do |chidx, infos|
                chap_json(jb, chidx, infos)
              end
            end
          end

          jb.field "chaps" do
            jb.array do
              zhbook.chinfo.chaps_page(pgidx).each do |chidx, infos|
                chap_json(jb, chidx, infos)
              end
            end
          end
        end
      end
    end
  end

  private def chap_json(jb : JSON::Builder, chidx, infos)
    jb.object do
      jb.field "chidx", chidx
      jb.field "schid", infos[0]
      jb.field "title", infos[1]
      jb.field "label", infos[2]
      jb.field "uslug", infos[3]
    end
  end

  def show
    zhbook = load_zhbook
    chidx = params.fetch_int("chidx")

    unless curr = zhbook.chinfo.get_info(chidx - 1)
      return halt!(404, "Chương tiết không tồn tại!")
    end

    json_view do |jb|
      jb.object {
        jb.field "sname", zhbook.sname
        jb.field "clink", zhbook.clink(curr[0])

        jb.field "total", zhbook.chap_count
        jb.field "chidx", chidx
        jb.field "schid", curr[0]

        jb.field "title", curr[1]
        jb.field "label", curr[2]
        jb.field "uslug", curr[3]

        jb.field "prev_url", zhbook.chinfo.url_for(chidx - 2)
        jb.field "next_url", zhbook.chinfo.url_for(chidx)
      }
    end
  end

  def text
    zhbook = load_zhbook
    bhash = zhbook.cvbook.bhash

    chidx = params.fetch_int("chidx") { 1 }
    schid = params["schid"]

    chtext = ChText.load(bhash, zhbook.sname, zhbook.snvid, chidx - 1, schid)

    zh_mode = params.fetch_int("mode")
    zh_mode = _cv_user.privi if zh_mode > _cv_user.privi

    fetchable = zhbook.remote_text?(chidx, _cv_user.privi)
    zh_text = chtext.get_zh!(fetchable, reset: zh_mode > 1)
    tl_mode = _cv_user.tlmode

    response.headers.add("Cache-Control", "private, min-fresh=60")
    response.content_type = "text/plain; charset=utf-8"
    context.content = zh_text ? convert(bhash, zh_text, mode: tl_mode) : ""
  end

  private def convert(dname, lines : Array(String), mode = 2)
    cvmtl = MtCore.generic_mtl(dname, _cv_user.uname)

    String.build do |io|
      cvmtl.cv_title_full(lines[0], mode: mode).to_str(io)

      1.upto(lines.size - 1) do |i|
        io << "\n"
        para = lines.unsafe_fetch(i)
        cvmtl.cv_plain(para, mode: mode).to_str(io)
      end
    end
  end

  def upsert
    return halt!(500, "Quyền hạn không đủ!") if _cv_user.privi < 2

    zhbook = load_zhbook
    chidx = params.fetch_int("chidx") { 1 }

    label = params.fetch_str("label")
    label = "" if label == "正文"

    input = params.fetch_str("input")
    lines = TextUtils.split_text(input, false)

    chaps = split_chaps(lines, label)

    chmax = zhbook.chap_count + 1
    chidx = chmax if chidx < 1 || chidx > chmax

    infos = chaps.map_with_index(chidx - 1) do |chap, index|
      schid = zhbook.get_schid(index)
      zhbook.chtext(index, schid).set_zh!(chap.lines)
      zhbook.set_chap!(index, schid, chap.title, chap.label).not_nil!
    end

    chmax = chidx + chaps.size - 1

    if chmax > zhbook.chap_count
      zhbook.bumped = Time.utc.to_unix
      zhbook.mftime = zhbook.bumped if zhbook.zseed == 0
      zhbook.last_schid = infos.last[0]
      zhbook.chap_count = chmax
      zhbook.save!
    end

    zhbook.reset_trans!(chmax, chidx)

    render_json({msg: "ok", chidx: chidx.to_s, uslug: infos.first[3]})
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
