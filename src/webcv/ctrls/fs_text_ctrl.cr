require "./base_ctrl"

class CV::FsTextCtrl < CV::BaseCtrl
  def show
    bname = params["bname"]
    sname = params["sname"]
    snvid = params["snvid"]

    chidx = params.fetch_str("chidx")
    index = chidx.to_i

    chinfo = ChInfo.load(bname, sname, snvid)
    unless curr = chinfo.get_info(index - 1)
      return halt!(404, "Chương tiết không tồn tại!")
    end

    if cu_privi >= 0
      ViMark.mark_chap(cu_uname, bname, sname, chidx, curr[1], curr[3])
    end

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "total", chinfo.seeds.size
          jb.field "chidx", chidx
          jb.field "schid", curr[0]
          jb.field "title", curr[1]
          jb.field "label", curr[2]
          jb.field "prev_url", chinfo.url_for(index - 2)
          jb.field "next_url", chinfo.url_for(index)
        end
      end
    end
  rescue err
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end

  def convert
    bname = params["bname"]
    sname = params["sname"]
    snvid = params["snvid"]

    chidx = params.fetch_int("chidx")
    schid = params["schid"]

    chtext = ChText.load(bname, sname, snvid, chidx - 1, schid)

    zh_mode = params.fetch_int("mode")
    zh_mode = cu_privi if zh_mode > cu_privi
    zh_text = chtext.get_zh!(cu_privi, reset: zh_mode > 1) || [""]

    tl_mode = ViUser.get_tlmode(cu_uname)

    response.headers.add("Cache-Control", "public, min-fresh=60")
    response.content_type = "text/plain; charset=utf-8"
    context.content = chtext.trans!(zh_text, mode: tl_mode)
  rescue err
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end

  def upsert
    return halt!(500, "Quyền hạn không đủ!") if cu_privi < 2

    bname = params["bname"]
    sname = params["sname"]
    snvid = params["snvid"]

    chidx = params.fetch_int("chidx", min: 1)

    label = params.fetch_str("label")
    label = "" if label == "正文"

    input = params.fetch_str("input")
    lines = TextUtils.split_text(input, false)

    chinfo = ChInfo.load(bname, sname, snvid)

    chmax = chinfo.seeds.size + 1
    chidx = chmax if chidx < 1 || chidx > chmax

    # schid = chinfo.origs.fval(chidx.to_s) || chidx.to_s.rjust(4, '0')

    schid = chidx.to_s.rjust(4, '0')
    infos = chinfo.put_chap!(chidx - 1, schid, lines[0], label).not_nil!

    chtext = ChText.load(bname, sname, snvid, chidx - 1, schid)
    chtext.set_zh!(lines)

    NvInfo.load(bname).set_chseed("chivi", bname, Time.utc.to_unix, chinfo.seeds.size)
    render_json({msg: "ok", chidx: chidx.to_s, uslug: infos[3]})
  rescue err
    puts "- Error loading chap_text: #{err}"
    message = err.message || "Không rõ lỗi!"
    halt!(500, message)
  end
end
