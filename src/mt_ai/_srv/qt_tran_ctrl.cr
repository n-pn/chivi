# require "../../../libcv/qtran_data"
require "./_mt_ctrl_base"

class MT::QtTranCtrl < AC::Base
  base "/_ai"

  TEXT_DIR = "var/wnapp/chtext"

  @[AC::Route::GET("/hviet")]
  def hviet_file(fpath : String)
    mcore = QtCore.hv_word

    hviet = String.build do |io|
      File.each_line("var/texts/#{fpath}.raw.txt", chomp: true) do |line|
        io << mcore.to_mtl(line.gsub('　', "")) << '\n'
      end
    end

    add_etag fpath
    render text: hviet
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end

  @[AC::Route::POST("/hviet")]
  def hviet_text
    mcore = QtCore.hv_word
    ztext = self._read_body

    hviet = String.build do |io|
      ztext.each_line { |line| io << mcore.to_mtl(line) << '\n' }
    end

    render text: hviet
  rescue ex
    Log.error(exception: ex) { ex.message }
    render 500, text: ex.message
  end
end
