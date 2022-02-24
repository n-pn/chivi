class CV::RmInfoBiqu5200 < CV::RmInfoGeneric
  def update_str : String
    @info.text("#info > p:last-child").sub("最后更新：", "")
  end

  def updated_at(update_str = self.update_str) : Time
    fix_update(super(update_str))
  end

  def last_schid_href : String
    @info.attr("#list a:first-of-type", "href")
  end
end
