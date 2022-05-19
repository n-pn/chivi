class CV::UbmemoCtrl < CV::BaseCtrl
  def cvbook
    send_json("Chưa có chức năng")
  end

  def access
    _pgidx, limit, offset = params.page_info(min: 15, max: 30)
    query = Ubmemo.query.where("cvuser_id = #{_cvuser.id}")

    case params["kind"]?
    when "marked" then query.where("locked = true")
    when "stored" then query.where("status > 0")
    end

    query = query.order_by(utime: :desc).limit(limit).offset(offset)
    send_json(query.with_nvinfo.map { |x| UbmemoView.new(x, true) })
  end

  def show : Nil
    if _cvuser.privi < 0
      return halt! 403, "Người dùng chưa đăng nhập!"
    end

    nvinfo_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo_id)
    send_json(UbmemoView.new(ubmemo))
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
    send_json(UbmemoView.new(ubmemo))
  end

  def update_status
    raise "Người dùng chưa đăng nhập!" if _cvuser.privi < 0

    nvinfo_id = params["book_id"].to_i64
    status = params.fetch_str("status", "default")

    ubmemo = Ubmemo.find_or_new(_cvuser.id, nvinfo_id)
    ubmemo.update!({status: status})
    send_json(UbmemoView.new(ubmemo))
  end
end
