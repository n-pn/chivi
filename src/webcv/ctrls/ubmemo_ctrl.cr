class CV::UbmemoCtrl < CV::BaseCtrl
  def cvbook
    serv_text("Chưa có chức năng")
  end

  def access
    _pgidx, limit, offset = params.page_info(min: 15, max: 30)
    query = Ubmemo.query.where("viuser_id = #{_viuser.id}")

    case params["kind"]?
    when "marked" then query.where("locked = true")
    when "stored" then query.where("status > 0")
    end

    query = query.order_by(utime: :desc).limit(limit).offset(offset)
    serv_json(query.with_nvinfo.map { |x| UbmemoView.new(x, true) })
  end

  def show : Nil
    if _viuser.privi < 0
      return halt! 403, "Người dùng chưa đăng nhập!"
    end

    nvinfo_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_viuser.id, nvinfo_id)
    serv_json(UbmemoView.new(ubmemo))
  end

  def update_access
    raise "Người dùng chưa đăng nhập!" if _viuser.privi < 0

    nvinfo_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_viuser.id, nvinfo_id)

    ubmemo.mark!(
      params.read_str("sname"),
      params.read_i16("chidx", min: 1_i16),
      params.read_i16("cpart"),
      params.read_str("title"),
      params.read_str("uslug"),
      params["locked"]? == "true" ? 1 : 0
    )
    serv_json(UbmemoView.new(ubmemo))
  end

  def update_status
    if _viuser.privi < 0
      raise Unauthorized.new("Người dùng chưa đăng nhập!")
    end

    nvinfo_id = params["book_id"].to_i64
    status = params.read_str("status", "default")

    ubmemo = Ubmemo.find_or_new(_viuser.id, nvinfo_id)
    ubmemo.update!({status: status})
    serv_json(UbmemoView.new(ubmemo))
  end
end
