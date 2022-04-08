class CV::RmInfoBiqu5200 < CV::RmInfoGeneric
  getter update_str : String do
    @info.text("#info > p:last-child").sub("最后更新：", "")
  end

  def updated_at : Time
    super(fix: true)
  end

  def last_schid_href : String
    @info.attr("#list a:first-of-type", "href")
  end
end
