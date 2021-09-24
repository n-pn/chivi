require "./base_ctrl"

class CV::MemoCtrl < CV::BaseCtrl
  def cvbook
  end

  def access
    skip = params.fetch_int("skip", min: 0)
    take = params.fetch_int("take", min: 15, max: 30)

    query = Ubmemo.query.where("cvuser_id = #{_cv_user.id}")
    query = query.limit(take).offset(skip).order_by(bumped: :desc)

    json_view do |jb|
      jb.array do
        query.with_cvbook.each do |ubmemo|
          jb.object {
            jb.field "bname", ubmemo.cvbook.bname
            jb.field "bslug", ubmemo.cvbook.bslug

            jb.field "status", ubmemo.status_s
            jb.field "locked", ubmemo.locked

            jb.field "sname", ubmemo.lr_sname
            jb.field "chidx", ubmemo.lr_chidx

            jb.field "title", ubmemo.lc_title
            jb.field "uslug", ubmemo.lc_uslug
          }
        end
      end
    end
  rescue err
    puts err
    halt! 500, err.message
  end

  def show : Nil
    raise "Người dùng chưa đăng nhập!" if _cv_user.privi < 0

    cvbook_id = params["book_id"].to_i64
    ubmemo = Ubmemo.find_or_new(_cv_user.id, cvbook_id)
    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    halt!(500, err.message)
  end

  def update_access
    raise "Người dùng chưa đăng nhập!" if _cv_user.privi < 0

    cvbook_id = params["book_id"].to_i64

    ubmemo = Ubmemo.upsert!(_cv_user.id, cvbook_id) do |memo|
      memo.bumped = Time.utc.to_unix
      memo.locked = params["locked"]? == "true"

      memo.lr_zseed = Zhseed.index(params.fetch_str("sname", "chivi"))
      memo.lr_chidx = params.fetch_int("chidx")

      memo.lc_title = params.fetch_str("title")
      memo.lc_uslug = params.fetch_str("uslug")
    end

    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    puts err
    halt! 500, err.message
  end

  def update_status
    raise "Người dùng chưa đăng nhập!" if _cv_user.privi < 0

    cvbook_id = params["book_id"].to_i64
    status = Ubmemo.status(params.fetch_str("status", "default"))

    ubmemo = Ubmemo.upsert!(_cv_user.id, cvbook_id, &.status = status)
    json_view { |jb| UbmemoView.render(jb, ubmemo) }
  rescue err
    halt!(500, err.message)
  end
end
