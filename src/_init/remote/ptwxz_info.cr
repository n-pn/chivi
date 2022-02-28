require "./generic_info"

class CV::RmInfoPtwxz < CV::RmInfoGeneric
  def btitle : String
    @info.text("h1")
  end

  getter table : Lexbor::Node do
    @info.css("table[width=\"100%\"]", &.first)
  end

  getter rows_1 : Array(Lexbor::Node) do
    table.css("tr:nth-child(2) > td").to_a
  end

  getter rows_2 : Array(Lexbor::Node) do
    table.css("tr:nth-child(3) > td").to_a
  end

  def author : String
    inner_text(rows_1[1])
  end

  def genres : Array(String)
    [inner_text(rows_1[0])]
  end

  def bintro : Array(String)
    return [""] unless node = @info.find("div[style=\"float:left;width:390px;\"]")
    node.children.each do |tag|
      tag.remove! if {"span", "a"}.includes?(tag.tag_name)
    end

    TextUtil.split_html(node.inner_text)
  end

  def bcover : String
    @info.attr("img[width=\"100\"]", "src")
  end

  def status_str
    inner_text(rows_2[1])
  end

  def update_str
    inner_text(rows_2[0])
  end

  def updated_at(update_str = self.update_str) : Time
    fix_update(super(update_str))
  end

  def chapters
    extract_chapters_plain(".centent li > a")
  end

  def last_schid_href
    @info.css(".grid a[target]") { |x| x[0].attributes["href"]? || "" }
  end

  private def inner_text(node : Lexbor::Node)
    node.inner_text.sub(/^.+：/, "").strip
  end
end
