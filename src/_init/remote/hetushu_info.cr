require "./generic_info"

class CV::RmInfoHetushu < CV::RmInfoGeneric
  def btitle : String
    @info.text("h2")
  end

  def author : String
    @info.text(".book_info a:first-child")
  end

  def genres : Array(String)
    bgenre = @info.text(".title > a:last-child")
    labels = @info.text_list(".tag a")
    [bgenre].concat(labels).uniq
  end

  def bintro : Array(String)
    @info.text_list(".intro > p")
  end

  def bcover : String
    "https://www.hetushu.com" + @info.attr(".book_info img", "src")
  end

  getter status_str do
    @info.attr(".book_info", "class").includes?("finish") ? "1" : "0"
  end

  def map_status(status : String)
    status.to_i? || 0
  end

  def update_str
    ""
  end

  def update_int
    0_i64
  end

  def last_schid_href : String
    @mulu.attr("#dir :last-child a:last-of-type", "href")
  end

  def chapters
    extract_chapters_chvol("#dir")
  end

  def clean_chvol(chvol : String)
    chvol.strip
  end
end
