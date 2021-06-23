require "./base_ctrl"

class CV::TextCtrl < CV::BaseCtrl
  def show
    bname = params["bname"]
    zseed = params["zseed"]
    snvid = params["snvid"]

    index = params.fetch_int("chidx", min: 1)
    index -= 1

    chinfo = ChInfo.load(bname, zseed, snvid)
    unless curr_chap = chinfo.infos[index]?
      return halt!(404, "Chương tiết không tồn tại!")
    end

    chidx, infos = curr_chap

    if cu_privi >= 0
      ViMark.mark_chap(cv_uname, bname, zseed, chidx, infos[1], infos[3])
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "total", chinfo.infos.size
          jb.field "chidx", chidx
          jb.field "schid", infos[0]
          jb.field "title", infos[1]
          jb.field "label", infos[2]
          jb.field "prev_url", chinfo.url_for(index - 1)
          jb.field "next_url", chinfo.url_for(index + 1)
        end
      end
    end
  rescue err
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end

  def convert
    bname = params["bname"]
    zseed = params["zseed"]
    snvid = params["snvid"]

    chidx = params.fetch_int("chidx")
    schid = params["schid"]

    chtext = ChText.load(bname, zseed, snvid, chidx - 1, schid)

    mode = params.fetch_int("mode")
    mode = cu_privi if mode > cu_privi
    text = chtext.get_cv!(cu_privi, mode: mode)

    response.headers.add("Cache-Control", "public, min-fresh=60")
    response.content_type = "text/plain; charset=utf-8"
    context.content = text
  rescue err
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end

  def upsert
    return halt!(500, "Quyền hạn không đủ!") if cu_privi < 2

    bname = params["bname"]
    zseed = params["zseed"]
    snvid = params["snvid"]

    chidx = params.fetch_int("chidx", min: 1)

    label = params.fetch_str("label")
    label = "" if label == "正文"

    input = params.fetch_str("input")
    lines = TextUtils.split_text(input, false)

    chinfo = ChInfo.load(bname, zseed, snvid)

    chmax = chinfo.seeds.size + 1
    chidx = chmax if chidx < 1 || chidx > chmax

    # schid = chinfo.origs.fval(chidx.to_s) || chidx.to_s.rjust(4, '0')

    schid = chidx.to_s.rjust(4, '0')
    chinfo.set!(chidx.to_s, schid, lines[0], label)
    NvInfo.load(bname).set_chseed("chivi", bname, Time.utc.to_unix, chinfo.seeds.size)

    chtext = ChText.load(bname, zseed, snvid, chidx - 1, schid)
    chtext.set_zh!(lines)

    index, infos = chinfo.infos[chidx - 1]
    render_json({msg: "ok", chidx: index, uslug: infos[3]})
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end
end
