require "./base_ctrl"

class CV::FsMarkCtrl < CV::BaseCtrl
  def show
    bname = params["bname"]
    blist = ViMark.book_map(cu_uname).fval(bname) || "default"

    render_json({bmark: blist})
  end

  def update
    return halt!(404, "Người dùng chưa đăng nhập!") if cu_uname == "khách"

    bname = params["bname"]
    blist = params["bmark"]? || ""

    ViMark.mark_book(cu_uname, bname, blist)
    render_json({bmark: blist})
  end

  def history
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    chap_mark = ViMark.chap_map(cu_uname)
    iter = chap_mark._idx.reverse_each
    skip.times { break unless iter.next }

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          take.times do
            break unless node = iter.next

            nvinfo = Cvbook.load!(node.key)
            next unless vals = chap_mark.get(nvinfo.bhash)
            atime, sname, chidx, title, uslug = vals

            json.object {
              json.field "bname", nvinfo.bname
              json.field "bslug", nvinfo.bslug

              json.field "atime", atime
              json.field "sname", sname

              json.field "chidx", chidx
              json.field "title", title
              json.field "uslug", uslug
            }
          end
        end
      end
    end
  end
end
