require "./generic_info"

class CV::RmInfoZhwenpg < CV::RmInfoGeneric
  def btitle : String
    @info.text(".cbooksingle h2")
  end

  def author : String
    @info.text(".fontwt")
  end

  def genres : Array(String)
    [] of String
  end

  def bintro : Array(String)
    @info.text_para("tr:nth-of-type(3)")
  end

  def bcover : String
    @info.attr(".cover_wrapper_m img", "data-src")
  end

  def status : {Int32, String}
    {0, "0"}
  end

  def update_str : String
    ""
  end

  def extract_schid(href : String)
    href.sub("r.php?id=", "")
  end

  def last_schid_href : String
    @info.attr(".fontwt0 + a", "href")
  end

  def chapters : Array(ChInfo)
    chaps = extract_chapters_plain(".clistitem > a")

    # reverse the list if chap list is reversed
    if chaps.first.schid == last_schid
      chaps.reverse!
      chaps.each_with_index(1) { |chinfo, chidx| chinfo.chidx = chidx }
    end

    chaps
  end
end
