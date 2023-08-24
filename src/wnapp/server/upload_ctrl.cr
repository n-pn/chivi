require "./_wn_ctrl_base"
require "../data/viuser/chtext_anlz_ulog"

class WN::UploadCtrl < AC::Base
  base "/_wn"

  struct AnlzForm
    include JSON::Serializable

    getter wn_id : Int32
    getter ch_no : Int32

    getter p_idx : Int32 = 0
    getter cksum : String

    getter mtl_json : String
    getter con_text : String

    getter _algo = "electra_base"

    DIR = "var/wnapp/chtext"

    def save_mtl!
      path = "#{DIR}/#{@wn_id}/#{@ch_no}-#{@cksum}-#{p_idx}.#{@_algo}.mtl"
      File.write(path, @mtl_json)
    end

    def save_con!
      path = "#{DIR}/#{@wn_id}/#{@ch_no}-#{@cksum}-#{p_idx}.#{@_algo}.con"
      File.write(path, @con_text)
    end

    def save_log!(uname : String)
      ChtextAnlzUlog.new(
        ch_no: @ch_no, p_idx: @p_idx,
        uname: uname, cksum: @cksum,
        _algo: @_algo,
      ).create!(@wn_id)
    end
  end

  @[AC::Route::POST("/anlzs/chaps", body: :form)]
  def upload_anlz_data(form : AnlzForm)
    form.save_mtl!
    form.save_con!

    spawn form.save_log!(_uname)

    render text: "ok!"
  end
end
