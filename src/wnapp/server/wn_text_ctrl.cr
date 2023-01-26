require "./_wn_ctrl_base"
require "../data/viuser/ch_text_edit"
require "../data/viuser/ch_line_edit"

require "../../_util/diff_util"

class WN::TextCtrl < AC::Base
  base "/_wn/texts/:sname/:s_bid"

  @[AC::Route::GET("/:ch_no")]
  def show(sname : String, s_bid : Int32,
           ch_no : Int32, part_no : Int32? = nil,
           load_mode : Int32 = 0)
    wn_seed = get_wn_seed(sname, s_bid)
    zh_chap = get_zh_chap(wn_seed, ch_no)

    ch_body = zh_chap.body

    # auto reload remote texts
    if !no_text?(ch_body) && should_auto_fetch?(load_mode)
      wn_seed.fetch_text!(zh_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    # unless no_text?(ch_body) || zh_chap.on_temp_dir?
    #   spawn zh_chap.save_body_copy!(seed: wn_seed)
    # end

    # put extra metadata
    response.headers["X-TITLE"] = zh_chap.title
    response.headers["X-CHDIV"] = zh_chap.chdiv
    response.headers["Content-Type"] = "text/plain; charset=UTF-8"

    if part_no && (text_part = ch_body[part_no]?)
      render text: "#{ch_body[0]}\n#{text_part}"
    else
      render text: ch_body.join('\n')
    end
  end

  @[AlwaysInline]
  private def no_text?(body : Array(String))
    body.size < 2
  end

  @[AlwaysInline]
  private def should_auto_fetch?(load_mode : Int32)
    _privi > 0 && (load_mode > 0 || cookies["auto_load"]?)
  end

  def guard_sname_privi(sname : String)
    case sname
    when "-"
      guard_privi min: 1, action: "thêm chương tiết cho nguồn chính"
    when .starts_with?('@')
      guard_owner sname, min: 2, action: "thêm chương tiết cho nguồn cá nhân"
    else
      guard_privi min: 3, action: "thêm chương tiết cho các nguồn phụ"
    end
  end

  @[AC::Route::POST("/")]
  def upsert_batch(sname : String, s_bid : Int32, start : Int32 = 0)
    guard_sname_privi sname: sname

    wn_seed = get_wn_seed(sname, s_bid)

    input = request.body.not_nil!.gets_to_end
    chaps = TextSplit.split_multi(input)
  end

  struct EntryForm
    include JSON::Serializable
    getter input : String
    getter title : String
    getter chdiv : String

    def after_initialize
      @input = TextUtil.clean_spaces(@input)
      @title = TextUtil.clean_spaces(@title)
      @chdiv = TextUtil.clean_spaces(@chdiv)
    end
  end

  @[AC::Route::PUT("/:ch_no", body: :form)]
  def upsert_entry(form : EntryForm, sname : String, s_bid : Int32, ch_no : Int32)
    guard_sname_privi sname: sname

    wn_seed = get_wn_seed(sname, s_bid)
    zh_chap = get_zh_chap(wn_seed, ch_no)

    spawn do
      ChTextEdit.new({
        sname: wn_seed.sname, s_bid: wn_seed.s_bid,
        s_cid: zh_chap.s_cid, ch_no: zh_chap.ch_no,
        patch: form.input, uname: _uname,
      }).save!
    rescue ex
      Log.error(exception: ex) { ex.message.colorize.red }
    end

    zh_chap.title = form.title
    zh_chap.chdiv = form.chdiv

    zh_chap.save_body!(form.input, seed: wn_seed, uname: _uname)

    render json: zh_chap
  end
end
