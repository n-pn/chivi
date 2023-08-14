require "./_wn_ctrl_base"
require "../../_util/hash_util"

class WN::ChinfoCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    # TODO: restrict user access
    render json: wnseed.get_chaps(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32, load_mode : Int32 = 1)
    wnseed = get_wnseed(wn_id, sname)
    chinfo = get_chinfo(wnseed, ch_no)

    read_privi = wnseed.read_privi(_uname)
    read_privi &-= 1 if ch_no <= wnseed.lower_read_privi_count

    # if _privi >= read_privi
    #   ztext = load_ztext(wnseed, chinfo, load_mode)
    #   parts = write_ztext_to_tmp_dir(ztext)
    # else
    #   parts = [] of String
    # end

    load_mode = -1 if _privi < read_privi

    ztext = Zctext.new(wnseed, chinfo)
    cksum = ztext.get_cksum!(_uname, _mode: load_mode)

    render json: {
      chinfo: chinfo,
      chdata: {
        privi: read_privi,
        rlink: chinfo.rlink,
        sizes: chinfo.sizes,
        cbase: ztext.cbase,
        cksum: cksum,
        _prev: wnseed.find_prev(ch_no).try(&._href(-1)),
        _next: wnseed.find_succ(ch_no).try(&._href(1)),
      },
    }
  end

  private def load_ztext(wnseed : Wnseed, chinfo : Chinfo, load_mode = 0)
    zh_text = chinfo.body

    # auto reload remote texts
    if load_mode > 1 || (load_mode > 0 && zh_text.size < 2)
      zh_text = TextFetch.fetch(wnseed, chinfo, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless zh_text.size < 2 || chinfo.on_txt_dir?
      spawn chinfo.save_body_copy!(seed: wnseed, _flag: 2)
    end

    zh_text
  end

  TMP_DIR = "tmp/chaps"

  private def write_ztext_to_tmp_dir(ztext : Array(String))
    return [] of String if ztext.size < 2

    title = ztext[0]

    ztext[1..].map do |body_part|
      text_hash = HashUtil.uniq_hash(title, body_part)

      File.open("#{TMP_DIR}/#{_uname}-#{text_hash}.txt", "w") do |file|
        file << title << '\n' << body_part
      end

      text_hash
    end
  end

  private def prev_url(seed, chap : Chinfo)
    return if chap.ch_no < 2
    seed.get_chap(chap.ch_no &- 1).try(&._href(-1))
  end

  private def next_url(seed, chap : Chinfo)
    return if chap.ch_no >= seed.chap_total
    seed.get_chap(chap.ch_no &+ 1).try(&._href(1))
  end
end
