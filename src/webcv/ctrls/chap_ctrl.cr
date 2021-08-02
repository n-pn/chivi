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

    chidx = params.fetch_str("chidx")
    index = chidx.to_i

    unless curr = zhbook.chinfo.get_info(index - 1)
      return halt!(404, "Chương tiết không tồn tại!")
    end

    if cu_privi >= 0
      bhash = zhbook.cvbook.bhash
      ViMark.mark_chap(cu_uname, bhash, zhbook.sname, chidx, curr[1], curr[3])
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object {
          jb.field "sname", zhbook.sname

          jb.field "total", zhbook.chap_count
          jb.field "chidx", chidx
          jb.field "schid", curr[0]

          jb.field "title", curr[1]
          jb.field "label", curr[2]

          jb.field "prev_url", zhbook.chinfo.url_for(index - 2)
          jb.field "next_url", zhbook.chinfo.url_for(index)
        }
      end
    end
  end

  def text
    zhbook = load_zhbook
    bhash = zhbook.cvbook.bhash

    chidx = params.fetch_int("chidx") { 1 }
    schid = params["schid"]

    chtext = ChText.load(bhash, zhbook.sname, zhbook.snvid, chidx - 1, schid)

    zh_mode = params.fetch_int("mode")
    zh_mode = cu_privi if zh_mode > cu_privi
    zh_text = chtext.get_zh!(cu_privi, reset: zh_mode > 1) || [""]

    response.headers.add("Cache-Control", "public, min-fresh=60")
    response.content_type = "text/plain; charset=utf-8"
    context.content = chtext.trans!(zh_text, mode: cu_tlmode)
  end

  def upsert
    return halt!(500, "Quyền hạn không đủ!") if cu_privi < 2

    zhbook = load_zhbook
    chidx = params.fetch_int("chidx") { 1 }

    label = params.fetch_str("label")
    label = "" if label == "正文"

    input = params.fetch_str("input")
    lines = TextUtils.split_text(input, false)

    chmax = zhbook.chap_count + 1
    chidx = chmax if chidx < 1 || chidx > chmax

    schid = params.fetch_str("schid") { chidx.to_s.rjust(4, '0') }
    infos = zhbook.chinfo.put_chap!(chidx - 1, schid, lines[0], label).not_nil!

    chtext = ChText.load("", sname, snvid, chidx - 1, schid)
    chtext.set_zh!(lines)

    if chidx > zhbook.chap_count
      if zhbook.zseed == 0
        zhbook.cvbook.update!({chap_count: chidx})
      else
        zhbook.update!({chap_count: chidx})
      end
    end

    render_json({msg: "ok", chidx: chidx.to_s, uslug: infos[3]})
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end
end
