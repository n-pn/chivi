require "./_wn_ctrl_base"
require "../data/viuser/chtext_anlz_ulog"

class WN::ChanlztCtrl < AC::Base
  base "/_wn/anlzs"

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
      con_path = "#{DIR}/#{@wn_id}/#{@ch_no}-#{@cksum}-#{p_idx}.con"

      File.open(con_path, "a") do |file|
        @con_text.each_line.with_index do |con, idx|
          file << idx << '\t' << @_algo << '\t' << con << '\n'
        end
      end
    end

    def save_log!(uname : String)
      ChtextAnlzUlog.new(
        wn_id: @wn_id,
        ch_no: @ch_no,
        cksum: @cksum,
        p_idx: @p_idx,
        uname: uname,
        _algo: @_algo,
      ).insert!
    end
  end

  @[AC::Route::POST("/chaps", body: :form)]
  def upload_anlz_data(form : AnlzForm)
    form.save_mtl!
    form.save_con!

    spawn form.save_log!(_uname)

    render text: "ok!"
  end
end
