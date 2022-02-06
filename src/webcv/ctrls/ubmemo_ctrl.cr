require "./_base_ctrl"

class CV::UbmemoCtrl < CV::BaseCtrl
  def cvbook
    send_json("Chưa có chức năng")
  end

  def access
    pgidx, limit, offset = params.page_info(min: 15, max: 30)

    query = Ubmemo.query.where("cvuser_id = #{_cvuser.id}")
    query = query.limit(limit).offset(offset).order_by(utime: :desc)

    send_json do |jb|
      jb.array do
        query.with_nvinfo.each do |ubmemo|
          jb.object {
            jb.field "bname", ubmemo.nvinfo.vname
            jb.field "bslug", ubmemo.nvinfo.bslug

            jb.field "status", ubmemo.status_s
            jb.field "locked", ubmemo.locked

            jb.field "sname", ubmemo.lr_sname
            jb.field "chidx", ubmemo.lr_chidx
            jb.field "cpart", ubmemo.lr_cpart

            jb.field "title", ubmemo.lc_title
            jb.field "uslug", ubmemo.lc_uslug
          }
        end
      end
    end
  end

  def show : Nil
    if _cvuser.privi < 0
      return halt! 403, "Người dùng chưa đăng nhập!"
    end

    nvinfo_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo_id)
    send_json { |jb| UbmemoView.render(jb, ubmemo) }
  end

  def update_access
    raise "Người dùng chưa đăng nhập!" if _cvuser.privi < 0

    nvinfo_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo_id)

    ubmemo.mark!(
      params.fetch_str("sname"),
      params.fetch_int("chidx"),
      params.fetch_int("cpart"),
      params.fetch_str("title"),
      params.fetch_str("uslug"),
      params["locked"]? == "true" ? 1 : 0
    )
    send_json { |jb| UbmemoView.render(jb, ubmemo) }
  end

  def update_status
    raise "Người dùng chưa đăng nhập!" if _cvuser.privi < 0

    nvinfo_id = params["book_id"].to_i64
    status = params.fetch_str("status", "default")

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo_id)
    ubmemo.update!({status: status})
    send_json { |jb| UbmemoView.render(jb, ubmemo) }
  end
end
