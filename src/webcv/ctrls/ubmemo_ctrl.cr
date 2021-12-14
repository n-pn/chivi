require "./base_ctrl"

class CV::UbmemoCtrl < CV::BaseCtrl
  def cvbook
    json_view({msg: "TODO!"})
  end

  def access
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubmemo.query.where("cvuser_id = #{_cvuser.id}")
    query = query.limit(take).offset(skip).order_by(utime: :desc)

    json_view do |jb|
      jb.array do
        query.with_nvinfo.each do |ubmemo|
          jb.object {
            jb.field "bname", ubmemo.nvinfo.bname
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
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  def show : Nil
    if _cvuser.privi < 0
      return halt! 403, "Người dùng chưa đăng nhập!"
    end

    cvbook_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cvuser.id, cvbook_id)
    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt!(500, err.message)
  end

  def update_access
    raise "Người dùng chưa đăng nhập!" if _cvuser.privi < 0

    cvbook_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cvuser.id, cvbook_id)

    ubmemo.mark!(
      params.fetch_str("sname"),
      params.fetch_int("chidx"),
      params.fetch_int("cpart"),
      params.fetch_str("title"),
      params.fetch_str("uslug"),
      params["locked"]? == "true" ? 1 : 0
    )
    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    Log.error { err.inspect_with_backtrace }
    halt! 500, err.message
  end

  def update_status
    raise "Người dùng chưa đăng nhập!" if _cvuser.privi < 0

    cvbook_id = params["book_id"].to_i64
    status = params.fetch_str("status", "default")

    ubmemo = Ubmemo.find_or_new(_cvuser.id, cvbook_id)
    ubmemo.update!({status: status})
    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    halt!(500, err.message)
  end
end
