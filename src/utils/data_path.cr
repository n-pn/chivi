module Utils
  BOOK_DIR = "data/books"

  SITES = {
    "hetushu", "jx_la", "rengshu",
    "xbiquge", "nofff", "duokan8",
    "paoshu8", "69shu", "zhwenpg",
  }

  def self.zh_info_path(site : String, bsid : String)
    File.join(BOOK_DIR, "zh_infos", site, "#{bsid}.json")
  end
end
