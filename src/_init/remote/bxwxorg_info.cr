class CV::RmInfoBxwxorg < CV::RmInfoGeneric
  def bintro : Array(String)
    @info.text_para("#intro > p:first-child")
  end
end
