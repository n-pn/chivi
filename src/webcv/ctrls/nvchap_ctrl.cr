require "./base_ctrl"

class CV::NvchapCtrl < CV::BaseCtrl
  private def load_zhbook
    nvinfo_id = params["book"].to_i64
    sname = params["sname"]

    Zhbook.load!(nvinfo_id, NvSeed.map_id(sname))
  end

  def index
    zhbook = load_zhbook
    mode = u_privi > 0 && params["force"]? ? 1 : 0

    is_remote = NvSeed::REMOTES.includes?(zhbook.sname)
    mode += 2 if is_remote && seed_outdated?(zhbook)

    total = zhbook.count_chap!(mode, ttl: 5.minutes)

    if is_remote
      base_zhbook = Zhbook.load!(zhbook.nvinfo, 0)
      base_zhbook.copy_newers!([zhbook]) if base_zhbook.chap_count < total
    end

    pgidx = params.fetch_int("page", min: 1)

    render_json do |res|
      JSON.build(res) do |jb|
        jb.object do
          jb.field "_seed", is_remote
          jb.field "sname", zhbook.sname

          jb.field "utime", zhbook.utime
          jb.field "atime", zhbook.atime

          jb.field "wlink", zhbook.wlink
          # jb.field "crawl", zhbook.remote?(u_privi)

          jb.field "total", total
          jb.field "pgidx", pgidx
          jb.field "pgmax", (total - 1) // 32 + 1

          jb.field "lasts" do
            jb.array { zhbook.lastpg.each(&.to_json(jb)) }
          end

          jb.field "chaps" do
            jb.array { zhbook.chpage(pgidx - 1).each(&.to_json(jb)) }
          end
        end
      end
    end
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, "Internal error!"
  end

  private def seed_outdated?(zhbook : Zhbook)
    utime = Time.unix(zhbook.atime)

    case zhbook.status
    when 0 then Time.utc - 2.**(4 - u_privi).hours > utime
    when 1 then Time.utc - 2.*(4 - u_privi).days > utime
    when 2 then Time.utc - 3.*(4 - u_privi).weeks > utime
    else        false
    end
  end

  def show
    chidx = params.fetch_int("chidx")
    cpart = params.fetch_int("cpart") { 0 }

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    if remote_chap?(zhbook, chinfo)
      mode = params["redo"]? ? 2 : 1
    else
      mode = 0
    end

    lines = zhbook.chtext(chinfo, cpart, mode: mode)

    ubmemo = Ubmemo.find_or_new(_cvuser.id, zhbook.nvinfo_id)
    if _cvuser.privi > -1
      ubmemo.mark!(zhbook.sname, chidx, cpart, chinfo.title, chinfo.uslug)
    end

    json_view do |jb|
      jb.object {
        jb.field "chmeta" {
          jb.object {
            jb.field "sname", zhbook.sname
            jb.field "total", zhbook.chap_count

            jb.field "clink", zhbook.clink(chinfo.schid)
            jb.field "cpart", cpart

            jb.field "_prev", cpart == 0 ? zhbook.chap_url(chidx - 1, -1) : chinfo.chap_url(cpart - 1)
            jb.field "_next", cpart + 1 < chinfo.parts ? chinfo.chap_url(cpart + 1) : zhbook.chap_url(chidx + 1)
          }
        }

        jb.field "chinfo" { chinfo.to_json(jb) }
        jb.field "ubmemo" { UbmemoView.render(jb, ubmemo) }

        jb.field "zhtext", lines

        strio = String::Builder.new
        start = Time.monotonic

        convert(zhbook, chinfo, lines, cpart, strio)
        tspan = (Time.monotonic - start).total_milliseconds.round.to_i

        jb.field "cvdata" { jb.string(strio.to_s) }
        jb.field "tlspan", tspan
      }
    end
  end

  def remote_chap?(zhbook, chinfo)
    sname = zhbook.zseed == 0 ? chinfo.o_sname : zhbook.sname
    NvSeed.remote?(sname, _cvuser.privi) do
      chinfo.chidx <= 40 || chinfo.chidx + 3 >= zhbook.chap_count
    end
  end

  def text : Nil
    chidx = params.fetch_int("chidx") { 1 }
    cpart = params.fetch_int("cpart") { 0 }

    zhbook = load_zhbook
    return text_not_found! unless chinfo = zhbook.chinfo(chidx - 1)

    min_fresh = _cvuser.privi < 2 ? 60 : 20
    response.headers.add("Cache-Control", "private, min-fresh=#{min_fresh}")
    response.content_type = "text/plain; charset=utf-8"

    lines = zhbook.chtext(chinfo, cpart, mode: 0, uname: _cvuser.uname)
    convert(zhbook, chinfo, lines, cpart, response)
  end

  private def text_not_found!(status = 404)
    halt! 404, "Chương tiết không tồn tại!"
  end

  private def convert(zhbook, chinfo, lines : Array(String), cpart : Int32, strio : IO)
    return if lines.empty?

    dname = zhbook.nvinfo.bhash
    cvmtl = MtCore.generic_mtl(dname, _cvuser.uname)

    cvmtl.cv_title_full(lines[0]).to_str(strio)
    strio << "\t" << " (#{cpart + 1}/#{chinfo.parts})" if chinfo.parts > 1

    1.upto(lines.size - 1) do |i|
      line = lines.unsafe_fetch(i)
      # File.write("tmp/nvchap.txt", "#{dname}\n#{line}")

      strio << "\n"
      cvmtl.cv_plain(line).to_str(strio)
    rescue err
      Log.error { err.message }
      strio << "\t[[Máy dịch gặp lỗi, mời liên hệ ban quản trị]]"
    end
  rescue err
    puts err
    puts err.inspect_with_backtrace
  end

  def upsert
    if _cvuser.privi < 2 || params["sname"] != "users"
      return halt!(500, "Quyền hạn không đủ!")
    end

    zhbook = load_zhbook
    chidx = params.fetch_int("chidx") { 1 }

    input = params.fetch_str("input")
    lines = TextUtils.split_text(input, false)

    chaps = split_chaps(lines, "")
    chidx = zhbook.chap_count + 1 if chidx < 1

    infos = chaps.map_with_index(chidx) do |chap, chidx|
      if chinfo = zhbook.chinfo(chidx - 1)
        chinfo.bump_version!
      else
        chinfo = ChInfo.new(chidx, (chidx * 10).to_s)
      end

      chinfo.utime = Time.utc.to_unix
      chinfo.uname = _cvuser.uname

      chtext = Chtext.load(zhbook.sname, zhbook.snvid, chinfo)
      chtext.save!(chap.lines, mkdir: true)

      zhbook.upsert_chinfo!(chinfo, chap.title, chap.chvol)
      chinfo.make_copy!(zhbook.sname, zhbook.snvid)
    end

    # copy new uploaded chapters to "chivi" source
    Zhbook.load!(zhbook.nvinfo, 0).upsert_chinfos!(infos)

    chmax = chidx + chaps.size - 1

    if chmax > zhbook.chap_count
      zhbook.utime = Time.utc.to_unix
      zhbook.last_schid = infos.last.schid
      zhbook.chap_count = chmax
      zhbook.nvinfo.update_utime(zhbook.utime)
      zhbook.save!
    end

    render_json({msg: "ok", chidx: chidx, uslug: infos.first.uslug})
  rescue err
    puts "- Error loading chtext: #{err}"
    halt!(500, err.message)
  end

  struct Chap
    getter chvol : String
    getter lines = [] of String
    getter title : String { lines.first? || "" }

    def initialize(@chvol)
    end
  end

  LINE_RE = /^\/{4,}(.*)^/

  private def split_chaps(input : Array(String), chvol = "")
    chaps = [Chap.new(chvol)]

    input.each do |line|
      if line =~ /^\s*\/{4,}/
        extra = line.gsub("/", "")
        chvol = extra unless extra.empty? || extra == "正文"
        chaps << Chap.new(chvol)
      else
        line = line.strip
        chaps.last.lines << line unless line.empty?
      end
    end

    chaps.shift if chaps.first.lines.empty?
    chaps
  end
end
