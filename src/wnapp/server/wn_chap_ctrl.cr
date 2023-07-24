require "./_wn_ctrl_base"
require "../../_util/hash_util"

class WN::ChapCtrl < AC::Base
  base "/_wn/chaps"

  @[AC::Route::GET("/:wn_id/:sname")]
  def index(wn_id : Int32, sname : String, pg pg_no : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    # TODO: restrict user access
    render json: wn_seed.chaps.all(pg_no)
  end

  @[AC::Route::GET("/:wn_id/:sname/:ch_no")]
  def show(wn_id : Int32, sname : String, ch_no : Int32, load_mode : Int32 = 1)
    wn_seed = get_wn_seed(wn_id, sname)
    wn_chap = get_wn_chap(wn_seed, ch_no)

    read_privi = wn_seed.read_privi(_uname)
    read_privi &-= 1 if ch_no <= wn_seed.lower_read_privi_count

    if _privi >= read_privi
      ztext = load_ztext(wn_seed, wn_chap, load_mode)
      parts = write_ztext_to_tmp_dir(ztext)
    else
      parts = [] of String
    end

    render json: {
      ch_no: wn_chap.ch_no,
      parts: parts,
      # p_max: wn_chap.p_len,

      title: wn_chap.vtitle,
      chdiv: wn_chap.vchdiv,

      uslug: wn_chap.uslug,
      privi: read_privi,

      _prev: prev_url(wn_seed, wn_chap),
      _next: next_url(wn_seed, wn_chap),

      _href: wn_chap._path,
    }
  end

  private def load_ztext(wn_seed : WnSeed, wn_chap : WnChap, load_mode = 0)
    zh_text = wn_chap.body

    # auto reload remote texts
    if load_mode > 1 || (load_mode > 0 && zh_text.size < 2)
      zh_text = wn_seed.fetch_text!(wn_chap, _uname, force: load_mode == 2)
    end

    # save chap text directly to `temps` folder
    unless zh_text.size < 2 || wn_chap.on_txt_dir?
      spawn wn_chap.save_body_copy!(seed: wn_seed, _flag: 2)
    end

    zh_text
  end

  TMP_DIR = "/www/chivi/tmp"

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

  private def prev_url(seed, chap : WnChap)
    return if chap.ch_no < 2
    seed.get_chap(chap.ch_no &- 1).try(&._href(-1))
  end

  private def next_url(seed, chap : WnChap)
    return if chap.ch_no >= seed.chap_total
    seed.get_chap(chap.ch_no &+ 1).try(&._href(1))
  end
end
