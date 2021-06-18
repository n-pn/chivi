require "./base_ctrl"

class CV::MarkCtrl < CV::BaseCtrl
  def show
    uname = cu_uname.downcase
    bname = params["bname"]
    blist = ViMark.book_map(uname).fval(bname) || "default"

    render_json({bmark: blist})
  end

  def update
    uname = cu_uname.downcase
    return halt!(404, "Người dùng chưa đăng nhập") if uname == "khách"

    bname = params["bname"]
    blist = params["bmark"]? || ""

    ViMark.mark_book(uname, bname, blist)
    render_json({bmark: blist})
  end

  def history
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    chap_mark = ViMark.chap_map(cu_uname.downcase)
    iter = chap_mark._idx.reverse_each
    skip.times { break unless iter.next }

    render_json do |res|
      JSON.build(res) do |json|
        json.array do
          take.times do
            break unless node = iter.next

            nvinfo = NvInfo.load(node.key)
            next unless vals = chap_mark.get(nvinfo.bhash)
            atime, sname, chidx, title, uslug = vals

            json.object {
              json.field "bname", nvinfo.btitle[2]
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
