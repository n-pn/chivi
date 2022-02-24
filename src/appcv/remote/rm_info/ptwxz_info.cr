require "./generic_info"

class CV::RmInfoPtwxz < CV::RmInfoGeneric
  def btitle : String
    @info.text("h1")
  end

  def author : String
    @info.text("td[width=\"25%\"]:nth-child(2)").sub(/作\s+者：/, "").strip
  end

  def genres : Array(String)
    [@info.text("td[width=\"25%\"]:nth-child(1)").sub(/类\s+别：/, "").strip]
  end

  def bintro : Array(String)
    return [""] unless node = @info.find("div[style=\"float:left;width:390px;\"]")
    node.children.each do |tag|
      tag.remove! if {"span", "a"}.includes?(tag.tag_name)
    end

    TextUtils.split_html(node.inner_text)
  end

  def bcover : String
    @info.attr("img[width=\"100\"]", "src")
  end

  def chapters
    extract_chapters_plain(".centent li > a")
  end
end
