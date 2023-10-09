require "./_wn_ctrl_base"

class WN::WnstemCtrl < AC::Base
  base "/_wn/seeds"

  @[AC::Route::GET("/:wn_id/:sname/brief")]
  def brief(wn_id : Int32, sname : String)
    wnseed = get_wnseed(wn_id, sname)

    tdiff = Time.utc - Time.unix(wnseed.rtime)
    # FIXME: change timespan according to `_flag`
    # fresh = tdiff < 24.hours

    render json: {
      chap_count: wnseed.chap_total,
      chap_avail: wnseed.chap_avail,
      track_link: wnseed.rlink,
    }
  end

  # @[AC::Route::GET("/:wn_id/:sname")]
  # def show(wn_id : Int32, sname : String)
  #   wnseed = get_wnseed(wn_id, sname)

  #   tdiff = Time.utc - Time.unix(wnseed.rtime)
  #   # FIXME: change timespan according to `_flag`
  #   fresh = tdiff < 24.hours

  #   render json: {
  #     curr_seed: wnseed,
  #     seed_data: {
  #       rlink: wnseed.rlink,
  #       rtime: wnseed.rtime,
  #       ##
  #       _flag: wnseed._flag,
  #       fresh: fresh,
  #       # extra
  #       read_privi: wnseed.plock,
  #       edit_privi: wnseed.plock,
  #       gift_chaps: wnseed.gift_chaps,
  #     },
  #   }
  # end

  struct UpdateForm
    include JSON::Serializable

    getter rm_link : String?
    getter cut_from : Int32?
    getter read_privi : Int32?
  end

  @[AC::Route::PATCH("/:wn_id/:sname", body: :form)]
  def update_seed(form : UpdateForm, wn_id : Int32, sname : String)
    guard_privi 1, "cập nhật nguồn"
    wnseed = get_wnseed(wn_id, sname)

    if rlink = form.rm_link
      wnseed.rlink = rlink
      spawn wnseed.reload_chlist!(mode: 0)
    end

    if cut_from = form.cut_from
      wnseed.delete_chaps!(cut_from)
    end

    if privi = form.read_privi
      wnseed.privi = privi.to_i16
    end

    wnseed.upsert!

    render json: wnseed
  end
end
